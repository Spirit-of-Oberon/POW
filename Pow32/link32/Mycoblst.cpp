#ifndef __MYCOLL_H__
#include "MyColl.hpp"
#endif

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

IMPLEMENT_DYNAMIC(CMyObList, CObList)

CMyObList::CMyObList(int nBlockSize)
{
	m_nCount= 0;
	m_pNodeHead= m_pNodeTail = m_pNodeFree = NULL;
	m_pBlocks= NULL;
	m_nBlockSize= nBlockSize;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObList::RemoveAll()
{
	m_nCount= 0;
	m_pNodeHead= m_pNodeTail = m_pNodeFree = NULL;
	m_pBlocks-> FreeDataChain();
	m_pBlocks= NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyObList::~CMyObList()
{
	RemoveAll();
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/////////////////////////////////////////////////////////////////////////////
// Node helpers
/*
 * Implementation note: CMyNode's are stored in CMyPlex blocks and
 *  chained together. Free blocks are maintained in a singly linked list
 *  using the 'pNext' member of CMyNode with 'm_pNodeFree' as the head.
 *  Used blocks are maintained in a doubly linked list using both 'pNext'
 *  and 'pPrev' as links and 'm_pNodeHead' and 'm_pNodeTail'
 *   as the head/tail.
 *
 * We never free a CMyPlex block unless the List is destroyed or RemoveAll()
 *  is used - so the total number of CMyPlex blocks may grow large depending
 *  on the maximum past size of the list.
 */

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyObList::CMyNode *CMyObList::NewNode(CMyObList::CMyNode* pPrev, CMyObList::CMyNode* pNext)
{
	if (m_pNodeFree == NULL)
	{
		// add another block
		CMyPlex* pNewBlock= CMyPlex::Create(m_pBlocks, m_nBlockSize,	sizeof(CMyNode));

		// chain them into free list
		CMyNode* pNode = (CMyNode*) pNewBlock->data();
		// free in reverse order to make it easier to debug
		pNode += m_nBlockSize - 1;
		for (int i = m_nBlockSize-1; i >= 0; i--, pNode--)
		{
			pNode->pNext = m_pNodeFree;
			m_pNodeFree = pNode;
		}
	}
	CMyObList::CMyNode* pNode = m_pNodeFree;
	m_pNodeFree = m_pNodeFree->pNext;
	pNode->pPrev = pPrev;
	pNode->pNext = pNext;
	m_nCount++;
	memset(&pNode->data, 0, sizeof(CObject*));  // zero fill
	return pNode;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObList::FreeNode(CMyObList::CMyNode* pNode)
{
	pNode->pNext = m_pNodeFree;
	m_pNodeFree = pNode;
	m_nCount--;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyObList::AddHead(CObject* newElement)
{
	CMyNode* pNewNode = NewNode(NULL, m_pNodeHead);
	pNewNode->data = newElement;
	if (m_pNodeHead != NULL)
		m_pNodeHead->pPrev = pNewNode;
	else
		m_pNodeTail = pNewNode;
	m_pNodeHead = pNewNode;
	return (POSITION) pNewNode;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyObList::AddTail(CObject* newElement)
{
	CMyNode* pNewNode = NewNode(m_pNodeTail, NULL);
	pNewNode->data = newElement;
	if (m_pNodeTail != NULL)
		m_pNodeTail->pNext = pNewNode;
	else
		m_pNodeHead = pNewNode;
	m_pNodeTail = pNewNode;
	return (POSITION) pNewNode;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObList::AddHead(CMyObList* pNewList)
{
	POSITION pos = pNewList->GetTailPosition();
	while (pos != NULL)
		AddHead(pNewList->GetPrev(pos));
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObList::AddTail(CMyObList* pNewList)
{
	POSITION pos = pNewList->GetHeadPosition();
	while (pos != NULL)
		AddTail(pNewList->GetNext(pos));
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject* CMyObList::RemoveHead()
{
	CMyNode* pOldNode = m_pNodeHead;
	CObject* returnValue = pOldNode->data;

	m_pNodeHead = pOldNode->pNext;
	if (m_pNodeHead != NULL)
		m_pNodeHead->pPrev = NULL;
	else
		m_pNodeTail = NULL;
	FreeNode(pOldNode);
	return returnValue;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject* CMyObList::RemoveTail()
{
	CMyNode* pOldNode = m_pNodeTail;
	CObject* returnValue = pOldNode->data;

	m_pNodeTail = pOldNode->pPrev;
	if (m_pNodeTail != NULL)
		m_pNodeTail->pNext = NULL;
	else
		m_pNodeHead = NULL;
	FreeNode(pOldNode);
	return returnValue;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyObList::InsertBefore(POSITION position, CObject* newElement)
{
	if (position == NULL)
		return AddHead(newElement); // insert before nothing -> head of the list

	// Insert it before position
	CMyNode* pOldNode = (CMyNode*) position;
	CMyNode* pNewNode = NewNode(pOldNode->pPrev, pOldNode);
	pNewNode->data = newElement;

	if (pOldNode->pPrev != NULL)
		pOldNode->pPrev->pNext = pNewNode;
	else
		m_pNodeHead = pNewNode;
	pOldNode->pPrev = pNewNode;
	return (POSITION) pNewNode;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyObList::InsertAfter(POSITION position, CObject* newElement)
{
	if (position == NULL)
		return AddTail(newElement); // insert after nothing -> tail of the list

	// Insert it before position
	CMyNode* pOldNode = (CMyNode*) position;
	CMyNode* pNewNode = NewNode(pOldNode, pOldNode->pNext);
	pNewNode->data = newElement;

	if (pOldNode->pNext != NULL)
		pOldNode->pNext->pPrev = pNewNode;
	else
		m_pNodeTail = pNewNode;
	pOldNode->pNext = pNewNode;
	return (POSITION) pNewNode;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObList::RemoveAt(POSITION position)
{
	CMyNode* pOldNode = (CMyNode*) position;

	// remove pOldNode from list
	if (pOldNode == m_pNodeHead)
		m_pNodeHead = pOldNode->pNext;
	else
		pOldNode->pPrev->pNext = pOldNode->pNext;
	
	if (pOldNode == m_pNodeTail)
		m_pNodeTail = pOldNode->pPrev;
	else
		pOldNode->pNext->pPrev = pOldNode->pPrev;
	FreeNode(pOldNode);
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

// slow operations

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyObList::FindIndex(int nIndex) const
{
	if (nIndex >= m_nCount)
		return NULL;  // went too far

	CMyNode* pNode = m_pNodeHead;
	while (nIndex--)
		pNode = pNode->pNext;

	return (POSITION) pNode;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyObList::Find(CObject* searchValue, POSITION startAfter) const
{
	CMyNode* pNode = (CMyNode*) startAfter;
	if (pNode == NULL)
		pNode = m_pNodeHead;  // start at head
	else
		pNode = pNode->pNext;  // start after the one specified

	for (; pNode != NULL; pNode = pNode->pNext)
		if (pNode->data == searchValue)
			return (POSITION) pNode;
	return NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

int CMyObList::GetCount() const
{ 
 return m_nCount; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CMyObList::IsEmpty() const
{ 
 return m_nCount == 0; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject*& CMyObList::GetHead()
{
	return m_pNodeHead->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject* CMyObList::GetHead() const
{ 
	return m_pNodeHead->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject*& CMyObList::GetTail()
{ 
	return m_pNodeTail->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject* CMyObList::GetTail() const
{ 
	return m_pNodeTail->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyObList::GetHeadPosition() const
{ 
 return (POSITION) m_pNodeHead; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyObList::GetTailPosition() const
{ 
 return (POSITION) m_pNodeTail; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject*& CMyObList::GetNext(POSITION& rPosition) // return *Position++
{ 
 CNode* pNode = (CNode*) rPosition;
	rPosition = (POSITION) pNode->pNext;
	return pNode->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject* CMyObList::GetNext(POSITION& rPosition) const // return *Position++
{ 
 CNode* pNode = (CNode*) rPosition;
	rPosition = (POSITION) pNode->pNext;
	return pNode->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject*& CMyObList::GetPrev(POSITION& rPosition) // return *Position--
{ 
 CNode* pNode = (CNode*) rPosition;
	rPosition = (POSITION) pNode->pPrev;
	return pNode->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject* CMyObList::GetPrev(POSITION& rPosition) const // return *Position--
{ 
 CNode* pNode = (CNode*) rPosition;
	rPosition = (POSITION) pNode->pPrev;
	return pNode->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject*& CMyObList::GetAt(POSITION position)
{ 
 CNode* pNode = (CNode*) position;
	return pNode->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject* CMyObList::GetAt(POSITION position) const
{ 
 CNode* pNode = (CNode*) position;
	return pNode->data; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObList::SetAt(POSITION pos, CObject* newElement)
{ 
 CNode* pNode = (CNode*) pos;
	pNode->data = newElement; 
}

