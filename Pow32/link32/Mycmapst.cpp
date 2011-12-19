#ifndef __MYCOLL_H__
#include "MyColl.hpp"
#endif

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyPlex* PASCAL CMyPlex::Create(CMyPlex*& pHead, UINT nMax, UINT cbElement)
{
 CMyPlex* p = (CMyPlex *) malloc(sizeof(CMyPlex) + nMax * cbElement);
			// may throw exception
	p->nMax = nMax;
	p->nCur = 0;
	p->pNext = pHead;
	pHead = p;  // change head (adds in reverse order for simplicity)
	return p;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyPlex::FreeDataChain()     // free this one and links
{
	CMyPlex* p = this;
	while (p)
	{
		BYTE* bytes = (BYTE*) p;
		CMyPlex* pNext = p->pNext;
		free(bytes);
		p = pNext;
	}
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

IMPLEMENT_DYNAMIC(CMyMapStringToOb, CMapStringToOb)

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMapStringToOb::CMyMapStringToOb(int nBlockSize)
{
	m_pHashTable = NULL;
	m_nHashTableSize = 50;  // default size
	m_nCount = 0;
	m_pFreeList = NULL;
	m_pBlocks = NULL;
	m_nBlockSize = nBlockSize;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline UINT CMyMapStringToOb::HashKey(LPCTSTR key) const
{
	UINT nHash = 0;
	while (*key)
		nHash = (nHash<<5) + nHash + *key++;
	return nHash;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToOb::InitHashTable(UINT nHashSize, BOOL bAllocNow)
//
// Used to force allocation of a hash table or to override the default
//   hash table size of (which is fairly small)
{
	if (m_pHashTable)
	{
		// free hash table
		free(m_pHashTable);
		m_pHashTable = NULL;
	}

	if (bAllocNow)
	{
  m_pHashTable= (CMyAssoc **) malloc(sizeof(CMyAssoc*) * nHashSize);
  //m_pHashTable= new CMyAssoc *[nHashSize];
		memset(m_pHashTable, 0, sizeof(CMyAssoc*) * nHashSize);
	}
	m_nHashTableSize = nHashSize;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToOb::RemoveAll()
{
	if (m_pHashTable)
	{
  free(m_pHashTable);
		m_pHashTable = NULL;
	}

	m_nCount = 0;
	m_pFreeList = NULL;
	m_pBlocks-> FreeDataChain();
	m_pBlocks = NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMapStringToOb::~CMyMapStringToOb()
{
	RemoveAll();	
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/////////////////////////////////////////////////////////////////////////////
// Assoc helpers
// same as CList implementation except we store CMyAssoc's not CNode's
//    and CMyAssoc's are singly linked all the time

CMyMapStringToOb::CMyAssoc *CMyMapStringToOb::NewAssoc()
{
	if (!m_pFreeList)
	{
		// add another block
		CMyPlex* newBlock= CMyPlex::Create(m_pBlocks, m_nBlockSize,	sizeof(CMyMapStringToOb::CMyAssoc));
		// chain them into free list
		CMyMapStringToOb::CMyAssoc* pAssoc= (CMyMapStringToOb::CMyAssoc*) newBlock->data();
		// free in reverse order to make it easier to debug
		pAssoc+= m_nBlockSize - 1;
		for (int i= m_nBlockSize-1; i >= 0; i--, pAssoc--)
		{
			pAssoc-> pNext= m_pFreeList;
			m_pFreeList= pAssoc;
		}
	}

	CMyMapStringToOb::CMyAssoc *pAssoc= m_pFreeList;
	m_pFreeList= m_pFreeList-> pNext;
	m_nCount++;
	memset(&pAssoc-> value, 0, sizeof(CObject*));
	return pAssoc;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToOb::FreeAssoc(CMyMapStringToOb::CMyAssoc* pAssoc)
{
	pAssoc-> key= NULL;  // free up string data
	pAssoc-> pNext= m_pFreeList;
	m_pFreeList= pAssoc;
	m_nCount--;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMapStringToOb::CMyAssoc *CMyMapStringToOb::GetAssocAt(LPCTSTR key, UINT& nHash) const
{ 
	nHash = HashKey(key) % m_nHashTableSize; // find association (or return NULL)
 
 if (!m_pHashTable)
		return NULL;

	CMyAssoc* pAssoc;  // see if it exists
 pAssoc= m_pHashTable[nHash];	
	for (pAssoc= m_pHashTable[nHash]; pAssoc != NULL; pAssoc= pAssoc-> pNext)
	{
		if (!strcmp(pAssoc->key, key))
			return pAssoc;
	}
	return NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CMyMapStringToOb::Lookup(LPCTSTR key, CObject*& rValue) const
{
	UINT nHash;
	CMyAssoc* pAssoc= GetAssocAt(key, nHash);
	if (pAssoc == NULL)
		return FALSE;  // not in map
 rValue= pAssoc->value;
	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject*& CMyMapStringToOb::operator[](LPCTSTR key)
{
	UINT nHash;
	CMyAssoc* pAssoc;
	
	if ((pAssoc= GetAssocAt(key, nHash)) == NULL)
	{
		if (m_pHashTable == NULL)
			InitHashTable(m_nHashTableSize); 

		pAssoc= NewAssoc();            // it doesn't exist, add a new Association
		pAssoc-> nHashValue= nHash;
  pAssoc-> key= key;
		// 'pAssoc->value' is a constructed object, nothing more

		pAssoc->pNext= m_pHashTable[nHash];  // put into hash table
		m_pHashTable[nHash]= pAssoc;
	}
	return pAssoc-> value;  // return new reference
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CMyMapStringToOb::RemoveKey(LPCTSTR key)
// remove key - return TRUE if removed
{
	if (!m_pHashTable)
		return FALSE;  // nothing in the table

	CMyAssoc** ppAssocPrev;
	ppAssocPrev= &m_pHashTable[HashKey(key) % m_nHashTableSize];

	CMyAssoc* pAssoc;
	for (pAssoc= *ppAssocPrev; pAssoc != NULL; pAssoc= pAssoc->pNext)
	{
		if (!strcmp(pAssoc-> key, key)) // remove it
		{
			*ppAssocPrev= pAssoc->pNext;  // remove from list
			FreeAssoc(pAssoc);
			return TRUE;
		}
		ppAssocPrev= &pAssoc->pNext;
	}
	return FALSE;  // not found
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

/////////////////////////////////////////////////////////////////////////////
// Iterating

void CMyMapStringToOb::GetNextAssoc(POSITION& rNextPosition, CString& rKey, CObject*& rValue) const
{
 // Diese Methode wird durch die unten gezeigte ersetzt
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToOb::GetNextAssoc(POSITION& rNextPosition, LPCTSTR &rKey, CObject*& rValue) const
{
	CMyAssoc* pAssocRet = (CMyAssoc*)rNextPosition;
	
	if (pAssocRet == (CMyAssoc*) BEFORE_START_POSITION)
	{
		// find the first association
		for (UINT nBucket= 0; nBucket < m_nHashTableSize; nBucket++)
			if ((pAssocRet= m_pHashTable[nBucket]) != NULL)
				break;	
	}

	// find next association
	CMyAssoc* pAssocNext;
	if ((pAssocNext= pAssocRet->pNext) == NULL)
	{
		// go to next bucket
		for (UINT nBucket= pAssocRet->nHashValue + 1; nBucket < m_nHashTableSize; nBucket++)
			if ((pAssocNext= m_pHashTable[nBucket]) != NULL)
				break;
	}

	rNextPosition= (POSITION) pAssocNext;
	rKey= pAssocRet->key;  // fill in return data
	rValue= pAssocRet->value;
}


/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

int CMyMapStringToOb::GetCount() const
{ 
 return m_nCount; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline BOOL CMyMapStringToOb::IsEmpty() const
{ 
 return m_nCount == 0; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToOb::SetAt(LPCTSTR key, CObject* newValue)
{ 
 (*this)[key] = newValue; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyMapStringToOb::GetStartPosition() const
{ 
 return (m_nCount == 0) ? NULL : BEFORE_START_POSITION; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline UINT CMyMapStringToOb::GetHashTableSize() const
{ 
 return m_nHashTableSize; 
}
