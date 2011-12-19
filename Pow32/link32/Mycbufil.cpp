#include <io.h>
#include <fcntl.h>

#ifndef __MYFILE_HPP__
#include "MyCFile.hpp"
#endif

IMPLEMENT_DYNAMIC(CBuffFile, CFile)

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CBuffFile::CBuffFile()
{
 m_pStream= NULL;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CBuffFile::CBuffFile(FILE *pOpenStream)
{
	m_pStream= pOpenStream;
	m_hFile= (UINT) _get_osfhandle(_fileno(pOpenStream));
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CBuffFile::CBuffFile(LPCTSTR lpszFileName, UINT nOpenFlags)
{
	CFileException e;
	if (!Open(lpszFileName, nOpenFlags, &e))
		AfxThrowFileException(e.m_cause, e.m_lOsError);
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

CBuffFile::~CBuffFile()
{
	if (m_pStream != NULL && m_bCloseOnDelete)
		Close();
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

BOOL CBuffFile::Open(LPCTSTR lpszFileName, UINT nOpenFlags,	CFileException* pException)
{
	m_pStream = NULL;
	if (!OpenLikeCFile(lpszFileName, (nOpenFlags & ~typeText), pException))
		return FALSE;

	char szMode[4]; // C-runtime open string
	int nMode = 0;

	// determine read/write mode depending on CFile mode
	if (nOpenFlags & modeCreate)
		szMode[nMode++] = 'w';
	else if (nOpenFlags & modeWrite)
		szMode[nMode++] = 'a';
	else
		szMode[nMode++] = 'r';

	// will be inverted if not necessary
	int nFlags = _O_RDONLY|_O_TEXT;
	if (nOpenFlags & modeReadWrite)
		szMode[nMode++] = '+', nFlags ^= _O_RDONLY;

	if (nOpenFlags & typeBinary)
		szMode[nMode++] = 'b', nFlags ^= _O_TEXT;
	else
		szMode[nMode++] = 't';
	szMode[nMode++] = '\0';

 // open a C-runtime low-level file handle
	int nHandle = _open_osfhandle(m_hFile, nFlags);

	// open a C-runtime stream from that handle
	if (nHandle != -1)
		m_pStream = _fdopen(nHandle, szMode);

	if (m_pStream == NULL)
	{
		// an error somewhere along the way...
		if (pException != NULL)
		{
			pException->m_lOsError = _doserrno;
			pException->m_cause = CFileException::OsErrorToException(_doserrno);
		}
 	CFile::Abort(); // close m_hFile
		return FALSE;
	}

	return TRUE;
}



/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

UINT CBuffFile::Read(void* lpBuf, UINT nCount)
{
	UINT nRead = 0;

	if ((nRead = fread(lpBuf, sizeof(BYTE), nCount, m_pStream)) == 0 && !feof(m_pStream))
		AfxThrowFileException(CFileException::generic, _doserrno);
	if (ferror(m_pStream))
	{
		clearerr(m_pStream);
		AfxThrowFileException(CFileException::generic, _doserrno);
	}
	return nRead;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CBuffFile::Write(const void* lpBuf, UINT nCount)
{
	if (fwrite(lpBuf, sizeof(BYTE), nCount, m_pStream) != nCount)
		AfxThrowFileException(CFileException::generic, _doserrno);
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

LONG CBuffFile::Seek(LONG lOff, UINT nFrom)
{
	fpos_t pos;
	if (fseek(m_pStream, lOff, nFrom) != 0)
		AfxThrowFileException(CFileException::badSeek, _doserrno);
	fgetpos(m_pStream, &pos);
	return (DWORD)pos;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

DWORD CBuffFile::GetPosition() const
{
	fpos_t pos;
	if (fgetpos(m_pStream, &pos) != 0)
		AfxThrowFileException(CFileException::invalidFile, _doserrno);
	return (DWORD)pos;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CBuffFile::Flush()
{
	if (m_pStream != NULL && fflush(m_pStream) != 0)
		AfxThrowFileException(CFileException::diskFull, _doserrno);
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CBuffFile::Close()
{
	int nErr= 0;
	if (m_pStream != NULL)
		nErr = fclose(m_pStream);

	m_hFile = hFileNull;
	m_bCloseOnDelete = FALSE;
	m_pStream = NULL;

	if (nErr != 0)
		AfxThrowFileException(CFileException::diskFull, _doserrno);
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CBuffFile::Abort()
{
	if (m_pStream != NULL && m_bCloseOnDelete)
		fclose(m_pStream);  // close but ignore errors
	m_hFile = hFileNull;
	m_pStream = NULL;
	m_bCloseOnDelete = FALSE;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CBuffFile::LockRange(DWORD dwPos, DWORD dwCount)
{
 // Methode für diese Klasse nicht verfügbar
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CBuffFile::UnlockRange(DWORD dwPos, DWORD dwCount)
{
 // Methode für diese Klasse nicht verfügbar
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

void CBuffFile::SetLength(DWORD dwNewLen)
{
	Seek((LONG)dwNewLen, (UINT)begin);
 	if (!::SetEndOfFile((HANDLE)m_hFile))
		CFileException::ThrowOsError((LONG)::GetLastError());
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

DWORD CBuffFile::GetLength() const
{
	DWORD dwLen, dwCur;

	// Seek is a non const operation
	dwCur = ((CBuffFile*)this)->Seek(0L, current);
	dwLen = ((CBuffFile*)this)->SeekToEnd();
	VERIFY(dwCur == (DWORD)(((CBuffFile*)this)->Seek(dwCur, begin)));

	return dwLen;
}

/******************************************************************************************************/
/******************************************************************************************************/
/******************************************************************************************************/

BOOL CBuffFile::OpenLikeCFile(LPCTSTR lpszFileName, UINT nOpenFlags,	CFileException* pException)
{
	// CFile objects are always binary and CreateFile does not need flag
	nOpenFlags &= ~(UINT)typeBinary;

	m_bCloseOnDelete = FALSE;
	m_hFile = (UINT)hFileNull;

	// map read/write mode
	DWORD dwAccess;
	switch (nOpenFlags & 3)
	{
	case modeRead:
		dwAccess = GENERIC_READ;
		break;
	case modeWrite:
		dwAccess = GENERIC_WRITE;
		break;
	case modeReadWrite:
		dwAccess = GENERIC_READ|GENERIC_WRITE;
		break;
	default:
		ASSERT(FALSE);  // invalid share mode
	}

	// map share mode
	DWORD dwShareMode;
	switch (nOpenFlags & 0x70)
	{
		case shareCompat:       // map compatibility mode to exclusive
		case shareExclusive:
			dwShareMode = 0;
			break;
		case shareDenyWrite:
			dwShareMode = FILE_SHARE_READ;
			break;
		case shareDenyRead:
			dwShareMode = FILE_SHARE_WRITE;
			break;
		case shareDenyNone:
			dwShareMode = FILE_SHARE_WRITE|FILE_SHARE_READ;
			break;
		default:
			ASSERT(FALSE);  // invalid share mode?
	}

	// Note: typeText and typeBinary are used in derived classes only.

	// map modeNoInherit flag
	SECURITY_ATTRIBUTES sa;
	sa.nLength = sizeof(sa);
	sa.lpSecurityDescriptor = NULL;
	sa.bInheritHandle = (nOpenFlags & modeNoInherit) == 0;

	// map creation flags
	DWORD dwCreateFlag;
	if (nOpenFlags & modeCreate)
		dwCreateFlag = CREATE_ALWAYS;
	else
		dwCreateFlag = OPEN_EXISTING;

	// attempt file creation
	HANDLE hFile = ::CreateFile(lpszFileName, dwAccess, dwShareMode, &sa,
		dwCreateFlag, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
	{
		if (pException != NULL)
		{
			pException->m_lOsError = ::GetLastError();
			pException->m_cause =
				CFileException::OsErrorToException(pException->m_lOsError);
		}
		return FALSE;
	}
	m_hFile = (HFILE)hFile;
	m_bCloseOnDelete = TRUE;
	return TRUE;
}


