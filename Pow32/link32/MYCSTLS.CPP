
// This is a part of the Microsoft Foundation Classes C++ library.
// Copyright (C) 1992-1994 Microsoft Corporation
// All rights reserved.
//
// This source code is only intended as a supplement to the
// Microsoft Foundation Classes Reference and Microsoft
// QuickHelp and/or WinHelp documentation provided with the library.
// See these sources for detailed information regarding the
// Microsoft Foundation Classes product.

/////////////////////////////////////////////////////////////////////////////
//
// Implementation of parameterized List
//
/////////////////////////////////////////////////////////////////////////////

#ifndef __MYCOLL_HPP__
#include "MyColl.hpp"
#endif

IMPLEMENT_DYNAMIC(CMyStringList, CStringList)

/////////////////////////////////////////////////////////////////////////////
// Special implementations for CStrings
// it is faster to bit-wise copy a CString than to call an official
//   constructor - since an empty CString can be bit-wise copied
/*
static inline void ConstructElement(char* pNewData)
{
	memcpy(pNewData, &afxEmptyString, sizeof(CString));
}

static inline void DestructElement(CString* pOldData)
{
	pOldData->Empty();
}
*/
/////////////////////////////////////////////////////////////////////////////


/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CMyStringList::CMyStringList(int nBlockSize)
{
	m_nCount= 0;
	m_pNodeHead= m_pNodeTail= m_pNodeFree= NULL;
	m_pBlocks= NULL;
	m_nBlockSize= nBlockSize;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyStringList::RemoveAll()
{
	CMyNode* pNode;
	//for (pNode= m_pNodeHead; pNode != NULL; pNode= pNode->pNext)
	//	DestructElement(&pNode->data);

	m_nCount= 0;
	m_pNodeHead= m_pNodeTail = m_pNodeFree = NULL;
	m_pBlocks-> FreeDataChain();
	m_pBlocks= NULL;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CMyStringList::~CMyStringList()
{
	RemoveAll();
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

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

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CMyStringList::CMyNode* CMyStringList::NewNode(CMyStringList::CMyNode* pPrev, CMyStringList::CMyNode* pNext)
{
	if (m_pNodeFree == NULL)
	{
		// add another block
		CMyPlex *pNewBlock = CMyPlex::Create(m_pBlocks, m_nBlockSize, sizeof(CMyNode));
  		// chain them into free list
		CMyNode *pNode= (CMyNode *)pNewBlock-> data();
		// free in reverse order to make it easier to debug
		pNode+= m_nBlockSize - 1;
		for (int i= m_nBlockSize - 1; i >= 0; i--, pNode--)
		{
			pNode->pNext = m_pNodeFree;
			m_pNodeFree = pNode;
		}
	}
	CMyStringList::CMyNode *pNode= m_pNodeFree;
	m_pNodeFree= m_pNodeFree-> pNext;
	pNode-> pPrev= pPrev;
	pNode-> pNext= pNext;
	m_nCount++;
	//ConstructElement(&pNode->data);
	return pNode;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyStringList::FreeNode(CMyStringList::CMyNode *pNode)
{
	pNode->pNext = m_pNodeFree;
	m_pNodeFree = pNode;
	m_nCount--;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

POSITION CMyStringList::AddHead(LPCTSTR newElement)
{
	CMyNode *pNewNode= NewNode(NULL, m_pNodeHead);
	pNewNode-> data= newElement;
	if (m_pNodeHead != NULL)
		m_pNodeHead->pPrev= pNewNode;
	else
		m_pNodeTail= pNewNode;
	m_pNodeHead= pNewNode;
	return (POSITION) pNewNode;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

POSITION CMyStringList::AddTail(LPCTSTR newElement)
{
	CMyNode *pNewNode= NewNode(m_pNodeTail, NULL);
	pNewNode-> data= newElement;
	if (m_pNodeTail != NULL)
		m_pNodeTail-> pNext= pNewNode;
	else
		m_pNodeHead= pNewNode;
	m_pNodeTail= pNewNode;
	return (POSITION) pNewNode;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyStringList::AddHead(CMyStringList* pNewList)
{
	// add a list of same elements to head (maintain order)
	POSITION pos= pNewList-> GetTailPosition();
	while (pos != NULL)
		AddHead(pNewList-> GetPrev(pos));
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyStringList::AddTail(CMyStringList* pNewList)
{
	// add a list of same elements
	POSITION pos= pNewList-> GetHeadPosition();
	while (pos != NULL)
		AddTail(pNewList-> GetNext(pos));
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

LPCTSTR CMyStringList::RemoveHead()
{
	CMyNode *pOldNode= m_pNodeHead;
	LPCTSTR returnValue= pOldNode-> data;

	m_pNodeHead= pOldNode->pNext;
	if (m_pNodeHead != NULL)
		m_pNodeHead-> pPrev= NULL;
	else
		m_pNodeTail= NULL;
	FreeNode(pOldNode);
	return returnValue;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

LPCTSTR CMyStringList::RemoveTail()
{
	CMyNode *pOldNode= m_pNodeTail;
	LPCTSTR returnValue= pOldNode->data;

	m_pNodeTail= pOldNode-> pPrev;
	if (m_pNodeTail != NULL)
		m_pNodeTail-> pNext= NULL;
	else
		m_pNodeHead= NULL;
	FreeNode(pOldNode);
	return returnValue;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

POSITION CMyStringList::InsertBefore(POSITION position, LPCTSTR newElement)
{
	if (position == NULL)
		return AddHead(newElement); // insert before nothing -> head of the list

	// Insert it before position
	CMyNode *pOldNode= (CMyNode *) position;
	CMyNode *pNewNode= NewNode(pOldNode-> pPrev, pOldNode);
	pNewNode-> data= newElement;

	if (pOldNode-> pPrev != NULL)
		pOldNode-> pPrev-> pNext= pNewNode;
	else
		m_pNodeHead= pNewNode;
	
	pOldNode-> pPrev= pNewNode;
	return (POSITION) pNewNode;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

POSITION CMyStringList::InsertAfter(POSITION position, LPCTSTR newElement)
{
	if (position == NULL)
		return AddTail(newElement); // insert after nothing -> tail of the list

	// Insert it before position
	CMyNode *pOldNode= (CMyNode *) position;
	CMyNode *pNewNode= NewNode(pOldNode, pOldNode-> pNext);
	pNewNode-> data= newElement;

	if (pOldNode-> pNext != NULL)
		pOldNode-> pNext-> pPrev= pNewNode;
	else
		m_pNodeTail= pNewNode;
	pOldNode-> pNext= pNewNode;
	return (POSITION) pNewNode;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyStringList::RemoveAt(POSITION position)
{
	CMyNode *pOldNode= (CMyNode *)position;
	
	// remove pOldNode from list
	if (pOldNode == m_pNodeHead)
		m_pNodeHead= pOldNode-> pNext;
	else
		pOldNode-> pPrev-> pNext= pOldNode-> pNext;
	if (pOldNode == m_pNodeTail)
		m_pNodeTail= pOldNode-> pPrev;
	else
		pOldNode-> pNext-> pPrev= pOldNode-> pPrev;
	FreeNode(pOldNode);
}


/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

// slow operations

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

POSITION CMyStringList::FindIndex(int nIndex) const
{
	if (nIndex >= m_nCount)
		return NULL;  // went too far

	CMyNode *pNode= m_pNodeHead;
	while (nIndex--)
		pNode = pNode-> pNext;
	return (POSITION) pNode;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

POSITION CMyStringList::Find(LPCTSTR searchValue, POSITION startAfter) const
{
	CMyNode *pNode= (CMyNode *) startAfter;
	if (pNode == NULL)
		pNode = m_pNodeHead;  // start at head
	else
		pNode = pNode-> pNext;  // start after the one specified
	
	for (; pNode != NULL; pNode= pNode-> pNext)
		if (pNode-> data == searchValue)
			return (POSITION) pNode;
	return NULL;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

int CMyStringList::GetCount() const
{ return m_nCount; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline BOOL CMyStringList::IsEmpty() const
{ return m_nCount == 0; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline LPCTSTR CMyStringList::GetHead()
{ return m_pNodeHead-> data; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline LPCTSTR CMyStringList::GetTail()
{ return m_pNodeTail->data; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline POSITION CMyStringList::GetHeadPosition() const
{ return (POSITION) m_pNodeHead; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline POSITION CMyStringList::GetTailPosition() const
{ return (POSITION) m_pNodeTail; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline LPCTSTR CMyStringList::GetNext(POSITION& rPosition) // return *Position++
{ CMyNode* pNode = (CMyNode*) rPosition;
		rPosition = (POSITION) pNode->pNext;
 	return pNode->data; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline LPCTSTR CMyStringList::GetNext(POSITION& rPosition) const // return *Position++
{ CMyNode* pNode = (CMyNode*) rPosition;
		rPosition = (POSITION) pNode->pNext;
		return pNode->data; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline LPCTSTR CMyStringList::GetPrev(POSITION& rPosition) // return *Position--
{ CMyNode* pNode = (CMyNode*) rPosition;
		rPosition = (POSITION) pNode->pPrev;
		return pNode->data; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline LPCTSTR CMyStringList::GetPrev(POSITION& rPosition) const // return *Position--
{ CMyNode* pNode = (CMyNode*) rPosition;
		rPosition = (POSITION) pNode->pPrev;
		return pNode->data; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline LPCTSTR CMyStringList::GetAt(POSITION position)
{ CMyNode* pNode = (CMyNode*) position;
		return pNode->data; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline LPCTSTR CMyStringList::GetAt(POSITION position) const
{ CMyNode* pNode = (CMyNode*) position;
		return pNode->data; }

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

inline void CMyStringList::SetAt(POSITION pos, LPCTSTR newElement)
{ CMyNode* pNode = (CMyNode*) pos;
		pNode->data = newElement; }

