#ifndef __MYFILE_HPP__
#include "MyCFile.hpp"
#endif

IMPLEMENT_DYNAMIC(CMyMemFile, CFile)

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CMyMemFile::CMyMemFile(UINT nGrowBytes)
{
	m_hFile = hFileNull;
	m_nGrowBytes = nGrowBytes;
	m_nPosition = 0;
	m_nBufferSize = 0;
	m_nFileSize = 0;
	m_lpBuffer = NULL;
	m_nBufferSize = 0;
 ownAllMem= FALSE;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CMyMemFile::~CMyMemFile()
{
	// Close should have already been called, but we check anyway
	if (m_lpBuffer)
		Close();

	m_nGrowBytes = 0;
	m_nPosition = 0;
	m_nBufferSize = 0;
	m_nFileSize = 0;
 ownAllMem= FALSE;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

BYTE* CMyMemFile::Alloc(DWORD nBytes)
{
	return (BYTE*)malloc((UINT)nBytes);
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

BYTE* CMyMemFile::Realloc(BYTE* lpMem, DWORD nBytes)
{
	return (BYTE*)realloc(lpMem, (UINT)nBytes);
}


/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

#pragma intrinsic(memcpy)
BYTE* CMyMemFile::Memcpy(BYTE* lpMemTarget, const BYTE* lpMemSource,	UINT nBytes)
{
	return (BYTE*)memcpy(lpMemTarget, lpMemSource, nBytes);
}
#pragma function(memcpy)

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::Free(BYTE* lpMem)
{
	free(lpMem);
}


/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

DWORD CMyMemFile::GetPosition() const
{
	return (DWORD)m_nPosition;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::GrowFile(DWORD dwNewLen)
{
	if (dwNewLen > m_nBufferSize)
	{
		// grow the buffer
		DWORD dwNewBufferSize = (DWORD)m_nBufferSize;

		while (dwNewBufferSize < dwNewLen)
			dwNewBufferSize += m_nGrowBytes;

		BYTE* lpNew;
		if (m_lpBuffer == NULL)
			lpNew = Alloc(dwNewBufferSize);
		else
			lpNew = Realloc(m_lpBuffer, dwNewBufferSize);

		m_lpBuffer = lpNew;
		m_nBufferSize = dwNewBufferSize;
  ownAllMem= TRUE; // Memory wurde selbst allokiert, muß selbst wieder freigegeben werden
	}
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::SetLength(DWORD dwNewLen)
{
	if (dwNewLen > m_nBufferSize)
		GrowFile(dwNewLen);

	if (dwNewLen < m_nPosition)
		m_nPosition = dwNewLen;

	m_nFileSize = dwNewLen;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

UINT CMyMemFile::Read(void* lpBuf, UINT nCount)
{
	if (nCount == 0)
		return 0;

	if (m_nPosition > m_nFileSize)
		return 0;

	UINT nRead;
	if (m_nPosition + nCount > m_nFileSize)
		nRead = (UINT)(m_nFileSize - m_nPosition);
	else
		nRead = nCount;

	Memcpy((BYTE*)lpBuf, (BYTE*)m_lpBuffer + m_nPosition, nRead);
	m_nPosition += nRead;

	return nRead;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::Write(const void* lpBuf, UINT nCount)
{
	if (nCount == 0)
		return;

	if (m_nPosition + nCount > m_nBufferSize)
		GrowFile(m_nPosition + nCount);

	Memcpy((BYTE*)m_lpBuffer + m_nPosition, (BYTE*)lpBuf, nCount);

	m_nPosition += nCount;

	if (m_nPosition > m_nFileSize)
		m_nFileSize = m_nPosition;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::SetBufferDirect(void *lpBuf, UINT nCount)
{       
 m_lpBuffer= (BYTE *)lpBuf;
 m_nFileSize= m_nBufferSize= nCount; 
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

UINT CMyMemFile::ReadWithoutMemcpy(void **lpBuf, UINT nCount)
{
 if (nCount == 0)
		return 0;

	if (m_nPosition > m_nFileSize)
		return 0;

	UINT nRead;
	if (m_nPosition + nCount > m_nFileSize)
		nRead = (UINT)(m_nFileSize - m_nPosition);
	else
		nRead = nCount;

	*lpBuf=  (BYTE *)m_lpBuffer + m_nPosition;
	m_nPosition += nRead;

	return nRead;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void *CMyMemFile::ReadWithoutMemcpy(UINT nCount)
{
 void *lpBuf;

 if (m_nPosition > m_nFileSize)
		return NULL;
 
	UINT nRead;
	if (m_nPosition + nCount > m_nFileSize)
		nRead = (UINT)(m_nFileSize - m_nPosition);
	else
		nRead = nCount;

	lpBuf=  (BYTE *)m_lpBuffer + m_nPosition;
	m_nPosition += nRead;
	return lpBuf;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

LONG CMyMemFile::Seek(LONG lOff, UINT nFrom)
{
	LONG lNewPos = m_nPosition;

	if (nFrom == begin)
		lNewPos = lOff;
	else if (nFrom == current)
		lNewPos += lOff;
	else if (nFrom == end)
		lNewPos = m_nFileSize + lOff;
	else
		return -1;

	m_nPosition = lNewPos;

	return m_nPosition;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::Flush()
{
	//ASSERT_VALID(this);
}


/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::Close()
{
	m_nGrowBytes = 0;
	m_nPosition = 0;
	m_nBufferSize = 0;
	m_nFileSize = 0;
	if (ownAllMem && m_lpBuffer)
	 Free(m_lpBuffer);
	m_lpBuffer = NULL;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::Abort()
{
	Close();
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::LockRange(DWORD /* dwPos */, DWORD /* dwCount */)
{
	//ASSERT_VALID(this);
	//AfxThrowNotSupportedException();
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CMyMemFile::UnlockRange(DWORD /* dwPos */, DWORD /* dwCount */)
{
	//ASSERT_VALID(this);
	//AfxThrowNotSupportedException();
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CFile* CMyMemFile::Duplicate() const
{
	return NULL;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

// only CMyMemFile supports "direct buffering" interaction with CArchive
UINT CMyMemFile::GetBufferPtr(UINT nCommand, UINT nCount, void** ppBufStart, void**ppBufMax)
{
	if (nCommand == bufferCheck)
		return 1;   // just a check for direct buffer support

	if (nCommand == bufferCommit)
	{
		// commit buffer
		m_nPosition += nCount;
		if (m_nPosition > m_nFileSize)
			m_nFileSize = m_nPosition;
		return 0;
	}

	// when storing, grow file as necessary to satisfy buffer request
	if (nCommand == bufferWrite && m_nPosition + nCount > m_nBufferSize)
		GrowFile(m_nPosition + nCount);

	// store buffer max and min
	*ppBufStart = m_lpBuffer + m_nPosition;
	*ppBufMax = m_lpBuffer + min(m_nBufferSize, m_nPosition + nCount);

	// advance current file position only on read
	if (nCommand == bufferRead)
		m_nPosition += LPBYTE(*ppBufMax) - LPBYTE(*ppBufStart);

	// return number of bytes in returned buffer space (may be <= nCount)
	return LPBYTE(*ppBufMax) - LPBYTE(*ppBufStart);
}

