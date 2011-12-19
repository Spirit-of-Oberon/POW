
#ifndef __MYCOLL_H__
#include "MyColl.hpp"
#endif

IMPLEMENT_DYNAMIC(CMyPtrList, CPtrList)

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyPtrList::CMyPtrList(int nBlockSize)
{
	m_nCount = 0;
	m_pNodeHead = m_pNodeTail = m_pNodeFree = NULL;
	m_pBlocks = NULL;
	m_nBlockSize = nBlockSize;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyPtrList::RemoveAll()
{
	m_nCount = 0;
	m_pNodeHead = m_pNodeTail = m_pNodeFree = NULL;
	m_pBlocks->FreeDataChain();
	m_pBlocks = NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyPtrList::~CMyPtrList()
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

CMyPtrList::CMyNode *CMyPtrList::NewNode(CMyPtrList::CMyNode* pPrev, CMyPtrList::CMyNode* pNext)
{
	if (m_pNodeFree == NULL)
	{
		// add another block
		CMyPlex* pNewBlock = CMyPlex::Create(m_pBlocks, m_nBlockSize, sizeof(CMyNode));

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
	CMyPtrList::CMyNode* pNode = m_pNodeFree;
	m_pNodeFree = m_pNodeFree->pNext;
	pNode->pPrev = pPrev;
	pNode->pNext = pNext;
	m_nCount++;
	
	memset(&pNode->data, 0, sizeof(void*));  // zero fill

	return pNode;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyPtrList::FreeNode(CMyPtrList::CMyNode* pNode)
{

	pNode->pNext = m_pNodeFree;
	m_pNodeFree = pNode;
	m_nCount--;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyPtrList::AddHead(void* newElement)
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

POSITION CMyPtrList::AddTail(void* newElement)
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

void CMyPtrList::AddHead(CMyPtrList* pNewList)
{
	// add a list of same elements to head (maintain order)
	POSITION pos = pNewList->GetTailPosition();
	while (pos != NULL)
		AddHead(pNewList->GetPrev(pos));
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyPtrList::AddTail(CMyPtrList* pNewList)
{
	// add a list of same elements
	POSITION pos = pNewList->GetHeadPosition();
	while (pos != NULL)
		AddTail(pNewList->GetNext(pos));
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void* CMyPtrList::RemoveHead()
{
	CMyNode* pOldNode = m_pNodeHead;
	void* returnValue = pOldNode->data;

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

void* CMyPtrList::RemoveTail()
{
	CMyNode* pOldNode = m_pNodeTail;
	void* returnValue = pOldNode->data;

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

POSITION CMyPtrList::InsertBefore(POSITION position, void* newElement)
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

POSITION CMyPtrList::InsertAfter(POSITION position, void* newElement)
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

void CMyPtrList::RemoveAt(POSITION position)
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

/////////////////////////////////////////////////////////////////////////////
// slow operations

POSITION CMyPtrList::FindIndex(int nIndex) const
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

POSITION CMyPtrList::Find(void* searchValue, POSITION startAfter) const
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

int CMyPtrList::GetCount() const
	{ return m_nCount; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CMyPtrList::IsEmpty() const
	{ return m_nCount == 0; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void*& CMyPtrList::GetHead()
	{ return m_pNodeHead->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void* CMyPtrList::GetHead() const
	{ return m_pNodeHead->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void*& CMyPtrList::GetTail()
	{ return m_pNodeTail->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void* CMyPtrList::GetTail() const
	{ return m_pNodeTail->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyPtrList::GetHeadPosition() const
	{ return (POSITION) m_pNodeHead; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline POSITION CMyPtrList::GetTailPosition() const
	{ return (POSITION) m_pNodeTail; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void*& CMyPtrList::GetNext(POSITION& rPosition) // return *Position++
	{ CMyNode* pNode = (CMyNode*) rPosition;
			rPosition = (POSITION) pNode->pNext;
		return pNode->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void* CMyPtrList::GetNext(POSITION& rPosition) const // return *Position++
	{ CMyNode* pNode = (CMyNode*) rPosition;
		rPosition = (POSITION) pNode->pNext;
		return pNode->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void*& CMyPtrList::GetPrev(POSITION& rPosition) // return *Position--
	{ CMyNode* pNode = (CMyNode*) rPosition;
		rPosition = (POSITION) pNode->pPrev;
		return pNode->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void* CMyPtrList::GetPrev(POSITION& rPosition) const // return *Position--
	{ CMyNode* pNode = (CMyNode*) rPosition;
		rPosition = (POSITION) pNode->pPrev;
		return pNode->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void*& CMyPtrList::GetAt(POSITION position)
	{ CMyNode* pNode = (CMyNode*) position;
		return pNode->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void* CMyPtrList::GetAt(POSITION position) const
	{ CMyNode* pNode = (CMyNode*) position;
		return pNode->data; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void CMyPtrList::SetAt(POSITION pos, void* newElement)
	{ CMyNode* pNode = (CMyNode*) pos;
		pNode->data = newElement; }

