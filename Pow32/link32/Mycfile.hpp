/**************************************************************************************************/
/*** Es werden alle überschrieben Microsoft Foundation File Classes definiert.																		***/
/**************************************************************************************************/

#ifndef __MYFILE_HPP__
#define __MYFILE_HPP__

#ifndef __LINKER_H__
#include "Linker.h"
#endif

class CBuffFile : public CFile
{
	DECLARE_DYNAMIC(CBuffFile)

 public:
  FILE *m_pStream;

 	CBuffFile();
 	CBuffFile(FILE *pOpenStream);
 	CBuffFile(LPCTSTR lpszFileName, UINT nOpenFlags);

  virtual DWORD GetPosition() const;
  virtual BOOL Open(LPCTSTR lpszFileName, UINT nOpenFlags,	CFileException* pError = NULL);
 	virtual LONG Seek(LONG lOff, UINT nFrom);
	 virtual void SetLength(DWORD dwNewLen);
	 virtual DWORD GetLength() const;
	 virtual UINT Read(void* lpBuf, UINT nCount);
	 virtual void Write(const void* lpBuf, UINT nCount);
 	virtual void LockRange(DWORD dwPos, DWORD dwCount);
 	virtual void UnlockRange(DWORD dwPos, DWORD dwCount);
 	virtual void Abort();
 	virtual void Flush();
 	virtual void Close();

 public:
 	virtual ~CBuffFile();

 private:
  BOOL OpenLikeCFile(LPCTSTR lpszFileName, UINT nOpenFlags,	CFileException* pException);
};

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CMyMemFile : public CFile
{
	DECLARE_DYNAMIC(CMyMemFile)

public:
// Constructors
	CMyMemFile(UINT nGrowBytes = 1024);

// Advanced Overridables
protected:
	virtual BYTE* Alloc(DWORD nBytes);
	virtual BYTE* Realloc(BYTE* lpMem, DWORD nBytes);
	virtual BYTE* Memcpy(BYTE* lpMemTarget, const BYTE* lpMemSource, UINT nBytes);
	virtual void Free(BYTE* lpMem);
	virtual void GrowFile(DWORD dwNewLen);

// Implementation
protected:
	UINT m_nGrowBytes;
	DWORD m_nPosition;
	DWORD m_nBufferSize;
	DWORD m_nFileSize;
	BYTE* m_lpBuffer;

public:
 BOOL ownAllMem;
 

public:
	virtual ~CMyMemFile();

 virtual DWORD GetPosition() const;
	BOOL GetStatus(CFileStatus& rStatus) const;
	virtual LONG Seek(LONG lOff, UINT nFrom);
	virtual void SetLength(DWORD dwNewLen);
	virtual UINT Read(void* lpBuf, UINT nCount);
	virtual void Write(const void* lpBuf, UINT nCount);
	virtual void Abort();
	virtual void Flush();
	virtual void Close();
	virtual UINT GetBufferPtr(UINT nCommand, UINT nCount = 0,	void** ppBufStart = NULL, void** ppBufMax = NULL);
 
 /* New, Linker specific Method's */
 virtual void SetBufferDirect(void *lpBuf, UINT nCount);
 virtual UINT ReadWithoutMemcpy(void **lpBufStart, UINT nCount); 
 virtual void *ReadWithoutMemcpy(UINT nCount= 0); 

	// Unsupported APIs
	virtual CFile* Duplicate() const;
	virtual void LockRange(DWORD dwPos, DWORD dwCount);
	virtual void UnlockRange(DWORD dwPos, DWORD dwCount);
};

#endif
