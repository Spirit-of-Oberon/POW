#ifndef __MYCOLL_H__
#include "MyColl.hpp"
#endif

IMPLEMENT_DYNAMIC(CMyMapStringToPtr, CMapStringToPtr)

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMapStringToPtr::CMyMapStringToPtr(int nBlockSize)
{
	m_pHashTable = NULL;
	m_nHashTableSize = 17;  // default size
	m_nCount = 0;
	m_pFreeList = NULL;
	m_pBlocks = NULL;
	m_nBlockSize = nBlockSize;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline UINT CMyMapStringToPtr::HashKey(LPCTSTR key) const
{
	UINT nHash = 0;
	while (*key)
		nHash = (nHash<<5) + nHash + *key++;
	return nHash;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToPtr::InitHashTable(UINT nHashSize, BOOL bAllocNow)
//
// Used to force allocation of a hash table or to override the default
//   hash table size of (which is fairly small)
{
	if (m_pHashTable != NULL)
	{
		// free hash table
		free(m_pHashTable);
  m_pHashTable = NULL;
	}

	if (bAllocNow)
	{
		m_pHashTable= (CMyAssoc **) malloc(sizeof(CMyAssoc*) * nHashSize);
  memset(m_pHashTable, 0, sizeof(CMyAssoc*) * nHashSize);
	}
	m_nHashTableSize = nHashSize;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToPtr::RemoveAll()
{
	if (m_pHashTable != NULL)
	{
		// free hash table
		free(m_pHashTable);
  m_pHashTable = NULL;
	}

	m_nCount = 0;
	m_pFreeList = NULL;
	m_pBlocks->FreeDataChain();
	m_pBlocks = NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMapStringToPtr::~CMyMapStringToPtr()
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

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMapStringToPtr::CMyAssoc *CMyMapStringToPtr::NewAssoc()
{
	if (m_pFreeList == NULL)
	{
		// add another block
		CMyPlex* newBlock = CMyPlex::Create(m_pBlocks, m_nBlockSize,	sizeof(CMyMapStringToPtr::CMyAssoc));
		// chain them into free list
		CMyMapStringToPtr::CMyAssoc* pAssoc=	(CMyMapStringToPtr::CMyAssoc*) newBlock->data();
		// free in reverse order to make it easier to debug
		pAssoc += m_nBlockSize - 1;
		for (int i = m_nBlockSize-1; i >= 0; i--, pAssoc--)
		{
			pAssoc->pNext = m_pFreeList;
			m_pFreeList = pAssoc;
		}
	}
	
	CMyMapStringToPtr::CMyAssoc* pAssoc = m_pFreeList;
	m_pFreeList = m_pFreeList->pNext;
	m_nCount++;
 memset(&pAssoc->value, 0, sizeof(void*));

	return pAssoc;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToPtr::FreeAssoc(CMyMapStringToPtr::CMyAssoc* pAssoc)
{
	pAssoc->pNext = m_pFreeList;
	m_pFreeList = pAssoc;
	m_nCount--;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMapStringToPtr::CMyAssoc *CMyMapStringToPtr::GetAssocAt(LPCTSTR key, UINT& nHash) const
// find association (or return NULL)
{
	nHash = HashKey(key) % m_nHashTableSize;

	if (m_pHashTable == NULL)
		return NULL;

	// see if it exists
	CMyAssoc* pAssoc;
	for (pAssoc = m_pHashTable[nHash]; pAssoc != NULL; pAssoc = pAssoc->pNext)
	{
		if (!(strcmp(pAssoc->key, key)))
			return pAssoc;
	}
	return NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyMapStringToPtr::CMyAssoc *CMyMapStringToPtr::GetIncludeStringAssocAt(LPCTSTR key, UINT& nHash) const
// find association (or return NULL)
{
	nHash = HashKey(key) % m_nHashTableSize;

	if (m_pHashTable == NULL)
		return NULL;

	// see if it exists
	CMyAssoc* pAssoc;
	for (pAssoc = m_pHashTable[nHash]; pAssoc != NULL; pAssoc = pAssoc->pNext)
	{
		if (!(strncmp(pAssoc->key, key, strlen(key))))
			return pAssoc;
	}
	return NULL;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CMyMapStringToPtr::Lookup(LPCTSTR key, void*& rValue) const
{
	UINT nHash;
	CMyAssoc* pAssoc = GetAssocAt(key, nHash);
	if (pAssoc == NULL)
		return FALSE;  // not in map

	rValue = pAssoc->value;
	return TRUE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CMyMapStringToPtr::LookupIncludeString(LPCTSTR key, void*& rValue) const
{
	UINT nHash;
	CMyAssoc* pAssoc = GetIncludeStringAssocAt(key, nHash);
	if (pAssoc == NULL)
		return FALSE;  // not in map

	rValue = pAssoc->value;
	return TRUE;
}

/**************************************************************************************************/
/*** Durchsucht die Hashtabelle sequteniell, ob die angegebene Zeichenkette Teil eines Schlüs-  ***/
/*** sels ist.	Das nächste Zeichen muß '@' sein, um TRUE zurückzugeben. Wird beim Suchen nach   ***/					
/*** exportierten Funktionssymbolen verwendet, die keine Parameterangabe aufweisen. 												***/
/**************************************************************************************************/

BOOL CMyMapStringToPtr::StringIsKeyPart(LPCTSTR key, void*& rValue)
{
	POSITION		mapPos;
	LPCTSTR			keyNam;
	void						*keyVal;	

	mapPos= GetStartPosition();

	while(mapPos)
	{
		GetNextAssoc(mapPos, keyNam, (void *&)keyVal);

		if (!(strncmp(key, keyNam, strlen(key))))
		{
			if (keyNam[strlen(key)] == '@')
			{
				rValue= keyVal;
				return TRUE;
			}
		}
	}

	return FALSE;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void*& CMyMapStringToPtr::operator[](LPCTSTR key)
{
	UINT nHash;
	CMyAssoc* pAssoc;
	if ((pAssoc = GetAssocAt(key, nHash)) == NULL)
	{
		if (m_pHashTable == NULL)
			InitHashTable(m_nHashTableSize);

		// it doesn't exist, add a new Association
		pAssoc = NewAssoc();
		pAssoc->nHashValue = nHash;
		pAssoc->key = key;
		// 'pAssoc->value' is a constructed object, nothing more

		// put into hash table
		pAssoc->pNext = m_pHashTable[nHash];
		m_pHashTable[nHash] = pAssoc;
	}
	return pAssoc->value;  // return new reference
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

BOOL CMyMapStringToPtr::RemoveKey(LPCTSTR key)
// remove key - return TRUE if removed
{
	if (m_pHashTable == NULL)
		return FALSE;  // nothing in the table

	CMyAssoc** ppAssocPrev;
	ppAssocPrev = &m_pHashTable[HashKey(key) % m_nHashTableSize];

	CMyAssoc* pAssoc;
	for (pAssoc = *ppAssocPrev; pAssoc != NULL; pAssoc = pAssoc->pNext)
	{
		if (!(strcmp(pAssoc->key, key)))
		{
			// remove it
			*ppAssocPrev = pAssoc->pNext;  // remove from list
			FreeAssoc(pAssoc);
			return TRUE;
		}
		ppAssocPrev = &pAssoc->pNext;
	}
	return FALSE;  // not found
}

/////////////////////////////////////////////////////////////////////////////
// Iterating

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToPtr::GetNextAssoc(POSITION& rNextPosition, LPCTSTR &rKey, void *&rValue) const
{
	CMyAssoc* pAssocRet = (CMyAssoc*)rNextPosition;
	
	if (pAssocRet == (CMyAssoc*) BEFORE_START_POSITION)
	{
		// find the first association
		for (UINT nBucket = 0; nBucket < m_nHashTableSize; nBucket++)
			if ((pAssocRet = m_pHashTable[nBucket]) != NULL)
				break;	
	}

	// find next association
	CMyAssoc* pAssocNext;
	if ((pAssocNext = pAssocRet->pNext) == NULL)
	{
		// go to next bucket
		for (UINT nBucket = pAssocRet->nHashValue + 1;
		  nBucket < m_nHashTableSize; nBucket++)
			if ((pAssocNext = m_pHashTable[nBucket]) != NULL)
				break;
	}

	rNextPosition = (POSITION) pAssocNext;

	// fill in return data
	rKey = pAssocRet->key;
	rValue = pAssocRet->value;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

int CMyMapStringToPtr::GetCount() const
	{ return m_nCount; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline BOOL CMyMapStringToPtr::IsEmpty() const
	{ return m_nCount == 0; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyMapStringToPtr::SetAt(LPCTSTR key, void* newValue)
	{ (*this)[key] = newValue; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

POSITION CMyMapStringToPtr::GetStartPosition() const
	{ return (m_nCount == 0) ? NULL : BEFORE_START_POSITION; }

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline UINT CMyMapStringToPtr::GetHashTableSize() const
	{ return m_nHashTableSize; }

