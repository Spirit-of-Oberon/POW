#ifndef __MYCOLL_HPP__
#include "MyColl.hpp"
#endif

IMPLEMENT_DYNAMIC(CMyObArray, CObArray)

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyObArray::CMyObArray()
{
	m_pData= NULL;
	m_nSize= m_nMaxSize = m_nGrowBy = 0;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CMyObArray::~CMyObArray()
{
	free((BYTE *)m_pData);
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObArray::SetSize(int nNewSize, int nGrowBy)
{
	if (nGrowBy != -1)
		m_nGrowBy= nGrowBy;  // set new size

	if (nNewSize == 0)
	{
		// shrink to nothing
		free((BYTE *)m_pData);
		m_pData= NULL;
		m_nSize= m_nMaxSize = 0;
	}
	else if (m_pData == NULL)
	{
		m_pData= (CObject**) malloc(nNewSize * sizeof(CObject*));
		memset(m_pData, 0, nNewSize * sizeof(CObject*));  // zero fill
		m_nSize= m_nMaxSize = nNewSize;
	}
	else if (nNewSize <= m_nMaxSize)
	{
		if (nNewSize > m_nSize)
			memset(&m_pData[m_nSize], 0, (nNewSize-m_nSize) * sizeof(CObject*));
		m_nSize= nNewSize;
	}
	else
	{
		int nGrowBy= m_nGrowBy;
		if (nGrowBy == 0)
		{
			// heuristically determine growth when nGrowBy == 0
			//  (this avoids heap fragmentation in many situations)
			nGrowBy = min(1024, max(4, m_nSize / 8));
		}
		int nNewMax;
		if (nNewSize < m_nMaxSize + nGrowBy)
			nNewMax= m_nMaxSize + nGrowBy;  // granularity
		else
			nNewMax= nNewSize;  // no slush
		CObject** pNewData = (CObject**) malloc(nNewMax * sizeof(CObject*));
		// copy new data from old
		memcpy(pNewData, m_pData, m_nSize * sizeof(CObject*));
		memset(&pNewData[m_nSize], 0, (nNewSize-m_nSize) * sizeof(CObject*));

		// get rid of old stuff (note: no destructors called)
		free((BYTE *)m_pData);
		m_pData= pNewData;
		m_nSize= nNewSize;
		m_nMaxSize= nNewMax;
	}
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObArray::FreeExtra()
{
	if (m_nSize != m_nMaxSize)
	{
		CObject** pNewData= NULL;
		if (m_nSize != 0)
		{
			pNewData= (CObject**) malloc(m_nSize * sizeof(CObject*));
			// copy new data from old
			memcpy(pNewData, m_pData, m_nSize * sizeof(CObject*));
		}

		// get rid of old stuff (note: no destructors called)
		free((BYTE *)m_pData);
		m_pData= pNewData;
		m_nMaxSize= m_nSize;
	}
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObArray::SetAtGrow(int nIndex, CObject* newElement)
{
	if (nIndex >= m_nSize)
		SetSize(nIndex+1);
	m_pData[nIndex]= newElement;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObArray::InsertAt(int nIndex, CObject* newElement, int nCount)
{
	if (nIndex >= m_nSize)
	{
		// adding after the end of the array
		SetSize(nIndex + nCount);  // grow so nIndex is valid
	}
	else
	{
		// inserting in the middle of the array
		int nOldSize= m_nSize;
		SetSize(m_nSize + nCount);  // grow it to new size
		// shift old data up to fill gap
		memmove(&m_pData[nIndex+nCount], &m_pData[nIndex], (nOldSize-nIndex) * sizeof(CObject*));
  // re-init slots we copied from
  memset(&m_pData[nIndex], 0, nCount * sizeof(CObject*));
	}
	while (nCount--)
		m_pData[nIndex++] = newElement;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObArray::RemoveAt(int nIndex, int nCount)
{
	// just remove a range
	int nMoveCount= m_nSize - (nIndex + nCount);

	if (nMoveCount)
		memcpy(&m_pData[nIndex], &m_pData[nIndex + nCount], nMoveCount * sizeof(CObject*));
	m_nSize -= nCount;
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObArray::InsertAt(int nStartIndex, CMyObArray* pNewArray)
{
	if (pNewArray-> GetSize() > 0)
	{
		InsertAt(nStartIndex, pNewArray->GetAt(0), pNewArray->GetSize());
		for (int i= 0; i < pNewArray-> GetSize(); i++)
			SetAt(nStartIndex + i, pNewArray-> GetAt(i));
	}
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

int CMyObArray::GetSize() const
{ 
 return m_nSize; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

int CMyObArray::GetUpperBound() const
{ 
 return m_nSize - 1; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline void CMyObArray::RemoveAll()
{ 
 SetSize(0); 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

CObject* CMyObArray::GetAt(int nIndex) const
{
	return m_pData[nIndex]; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

void CMyObArray::SetAt(int nIndex, CObject* newElement)
{ 
	m_pData[nIndex] = newElement; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline CObject*& CMyObArray::ElementAt(int nIndex)
{ 
	return m_pData[nIndex]; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline int CMyObArray::Add(CObject* newElement)
{ 
 int nIndex= m_nSize;
	SetAtGrow(nIndex, newElement);
	return nIndex; 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline CObject* CMyObArray::operator[](int nIndex) const
{ 
 return GetAt(nIndex); 
}

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

inline CObject*& CMyObArray::operator[](int nIndex)
{ 
 return ElementAt(nIndex); 
}





