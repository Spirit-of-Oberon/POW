/**************************************************************************************************/
/*** Hier werden sind alle überschriebenen Microsoft Foundation Collection Classes definiert.   ***/  
/**************************************************************************************************/

#ifndef __MYCOLLECTIONS_H__
#define __MYCOLLECTIONS_H__

#ifndef __LINKER_H__
#include "Linker.h"
#endif

struct CMyPlex    // warning variable length structure
{
	CMyPlex* pNext;
	UINT nMax;
	UINT nCur;
	/* BYTE data[maxNum*elementSize]; */

	void* data() { return this+1; }

	static CMyPlex* PASCAL Create(CMyPlex*& head, UINT nMax, UINT cbElement);
			// like 'calloc' but no zero fill
			// may throw memory exceptions

	void FreeDataChain();       // free this one and links
};

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CMyObArray : public CObArray
{
	DECLARE_DYNAMIC(CMyObArray)
 
 public:
  CMyObArray();

 	int GetSize() const;
 	int GetUpperBound() const;
 	void SetSize(int nNewSize, int nGrowBy = -1);
 	void FreeExtra();
 	void RemoveAll();
 	CObject* GetAt(int nIndex) const;
 	void SetAt(int nIndex, CObject* newElement);
 	CObject*& ElementAt(int nIndex);
  void SetAtGrow(int nIndex, CObject* newElement);
	 int Add(CObject* newElement);
  CObject* operator[](int nIndex) const;
	 CObject*& operator[](int nIndex);
  void InsertAt(int nIndex, CObject* newElement, int nCount = 1);
	 void RemoveAt(int nIndex, int nCount = 1);
	 void InsertAt(int nStartIndex, CMyObArray* pNewArray);

 protected:
 	CObject** m_pData;   // the actual array of data
 	int m_nSize;     // # of elements (upperBound - 1)
 	int m_nMaxSize;  // max allocated
 	int m_nGrowBy;   // grow amount

 public:
	 ~CMyObArray();

	typedef CObject* BASE_TYPE;
	typedef CObject* BASE_ARG_TYPE;
};

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CMyPtrList : public CPtrList
{
	DECLARE_DYNAMIC(CMyPtrList)

 protected:
	 struct CMyNode
	 {
	 	CMyNode *pNext;
	 	CMyNode *pPrev;
	 	void *data;
	 };

 public:
 	CMyPtrList(int nBlockSize = 10);

 	int GetCount() const;
 	BOOL IsEmpty() const;
 	void*& GetHead();
 	void* GetHead() const;
 	void*& GetTail();
 	void* GetTail() const;
 	void* RemoveHead();
 	void* RemoveTail();
 	POSITION AddHead(void* newElement);
 	POSITION AddTail(void* newElement);
  void AddHead(CMyPtrList* pNewList);
	 void AddTail(CMyPtrList* pNewList);
 	void RemoveAll();
 	POSITION GetHeadPosition() const;
 	POSITION GetTailPosition() const;
 	void*& GetNext(POSITION& rPosition); // return *Position++
 	void* GetNext(POSITION& rPosition) const; // return *Position++
 	void*& GetPrev(POSITION& rPosition); // return *Position--
 	void* GetPrev(POSITION& rPosition) const; // return *Position--
 	void*& GetAt(POSITION position);
 	void* GetAt(POSITION position) const;
 	void SetAt(POSITION pos, void* newElement);
 	void RemoveAt(POSITION position);
  POSITION InsertBefore(POSITION position, void* newElement);
	 POSITION InsertAfter(POSITION position, void* newElement);

 	// helper functions (note: O(n) speed)
	 POSITION Find(void* searchValue, POSITION startAfter = NULL) const;
 	POSITION FindIndex(int nIndex) const;
	
 // Implementation
 protected:
 	CMyNode* m_pNodeHead;
 	CMyNode* m_pNodeTail;
	 int m_nCount;
	 CMyNode* m_pNodeFree;
	 struct CMyPlex* m_pBlocks;
	 int m_nBlockSize;
 	CMyNode* NewNode(CMyNode*, CMyNode*);
	 void FreeNode(CMyNode*);

 public:
	 ~CMyPtrList();

	typedef void* BASE_TYPE;
	typedef void* BASE_ARG_TYPE;
};

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CMyObList : public CObList
{
	DECLARE_DYNAMIC(CMyObList)

 protected:
 	struct CMyNode
 	{
 		CMyNode* pNext;
 		CMyNode* pPrev;
 		CObject* data;
 	};

 public:
  CMyObList(int nBlockSize = 10);
 
 	int GetCount() const;
 	BOOL IsEmpty() const;
  CObject*& GetHead();
 	CObject* GetHead() const;
 	CObject*& GetTail();
 	CObject* GetTail() const;
  CObject* RemoveHead();
 	CObject* RemoveTail();
 	POSITION AddHead(CObject* newElement);
 	POSITION AddTail(CObject* newElement);
 	void AddHead(CMyObList* pNewList);
 	void AddTail(CMyObList* pNewList);
 	void RemoveAll();

 	POSITION GetHeadPosition() const;
 	POSITION GetTailPosition() const;
 	CObject*& GetNext(POSITION& rPosition); // return *Position++
 	CObject* GetNext(POSITION& rPosition) const; // return *Position++
 	CObject*& GetPrev(POSITION& rPosition); // return *Position--
 	CObject* GetPrev(POSITION& rPosition) const; // return *Position--
 	CObject*& GetAt(POSITION position);
 	CObject* GetAt(POSITION position) const;
 	void SetAt(POSITION pos, CObject* newElement);
 	void RemoveAt(POSITION position);
 	POSITION InsertBefore(POSITION position, CObject* newElement);
 	POSITION InsertAfter(POSITION position, CObject* newElement);
 
	 POSITION Find(CObject* searchValue, POSITION startAfter = NULL) const;
	 POSITION FindIndex(int nIndex) const;

 protected:
	 CMyNode* m_pNodeHead;
	 CMyNode* m_pNodeTail;
	 int m_nCount;
	 CMyNode* m_pNodeFree;
	 struct CMyPlex* m_pBlocks;
	 int m_nBlockSize;

	 CMyNode* NewNode(CMyNode*, CMyNode*);
	 void FreeNode(CMyNode*);

 public:
	 ~CMyObList();

	typedef CObject* BASE_TYPE;
	typedef CObject* BASE_ARG_TYPE;
};

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CMyStringList : public CStringList
{
 DECLARE_DYNAMIC(CMyStringList);

 protected:
	 struct CMyNode
 	{
 		CMyNode *pNext;
 		CMyNode *pPrev;
 		LPCTSTR data;
 	};

 public:
	 CMyStringList(int nBlockSize = 10);

 	int GetCount() const;
 	BOOL IsEmpty() const;
 	LPCTSTR GetHead();
	 LPCTSTR GetTail();
  LPCTSTR RemoveHead();
	 LPCTSTR RemoveTail();
  POSITION AddHead(LPCTSTR newElement);
	 POSITION AddTail(LPCTSTR newElement);
  void AddHead(CMyStringList* pNewList);
	 void AddTail(CMyStringList* pNewList);
  void RemoveAll();
 	POSITION GetHeadPosition() const;
 	POSITION GetTailPosition() const;
 	LPCTSTR GetNext(POSITION& rPosition); 
  LPCTSTR GetNext(POSITION& rPosition) const; 
 	LPCTSTR GetPrev(POSITION& rPosition); // return *Position--
  LPCTSTR GetPrev(POSITION& rPosition) const; 
	 LPCTSTR GetAt(POSITION position);
  LPCTSTR GetAt(POSITION position) const;
	 void SetAt(POSITION pos, LPCTSTR newElement);
	 void RemoveAt(POSITION position);
  POSITION InsertBefore(POSITION position, LPCTSTR newElement);
	 POSITION InsertAfter(POSITION position, LPCTSTR newElement);

	// helper functions (note: O(n) speed)
	 POSITION Find(LPCTSTR searchValue, POSITION startAfter = NULL) const;
  POSITION FindString(LPCTSTR searchValue, POSITION startAfter = NULL) const;
		POSITION FindIndex(int nIndex) const;
		
 protected:
	 CMyNode *m_pNodeHead;
	 CMyNode *m_pNodeTail;
	 int      m_nCount;
	 CMyNode *m_pNodeFree;
	 struct CMyPlex* m_pBlocks;
	 int m_nBlockSize;

	CMyNode* NewNode(CMyNode*, CMyNode*);
	void FreeNode(CMyNode*);

 public:
	 ~CMyStringList();

	// local typedefs for class templates
	typedef LPCTSTR BASE_TYPE;
	typedef LPCTSTR BASE_ARG_TYPE;
};

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CMyMapStringToPtr : public CMapStringToPtr
{
 DECLARE_DYNAMIC(CMyMapStringToPtr)

 protected:
	 
	 struct CMyAssoc
	 {
	 	CMyAssoc *pNext;
	 	UINT     nHashValue;  
	 	LPCTSTR  key;
		 void     *value;
	 };

 public:
  CMyMapStringToPtr(int nBlockSize = 10);

 	int GetCount() const;
 	BOOL IsEmpty() const;
  BOOL Lookup(LPCTSTR key, void*& rValue) const;
  BOOL LookupIncludeString(LPCTSTR key, void*& rValue) const;
 	void*& operator[](LPCTSTR key);
  void SetAt(LPCTSTR key, void* newValue);
  BOOL RemoveKey(LPCTSTR key);
	 void RemoveAll();
  POSITION GetStartPosition() const;
 	void GetNextAssoc(POSITION& rNextPosition, LPCTSTR& rKey, void*& rValue) const;
  UINT GetHashTableSize() const;
	 void InitHashTable(UINT hashSize, BOOL bAllocNow = TRUE);
  UINT HashKey(LPCTSTR key) const;

 // Implementation
 protected:
	 CMyAssoc** m_pHashTable;
	 UINT m_nHashTableSize;
	 int m_nCount;
	 CMyAssoc* m_pFreeList;
	 struct CMyPlex* m_pBlocks;
	 int m_nBlockSize;

	 CMyAssoc* NewAssoc();
	 void FreeAssoc(CMyAssoc*);
	 CMyAssoc* GetAssocAt(LPCTSTR, UINT&) const;
  CMyAssoc* GetIncludeStringAssocAt(LPCTSTR, UINT&) const;

 public:
	 ~CMyMapStringToPtr();

		// Neue Methode zum Suchen von Exportsymbolen ohne Parameteranzahl (@..)

		BOOL StringIsKeyPart(LPCTSTR key, void*& rValue);	

 protected:
	 typedef LPCTSTR BASE_KEY;
	 typedef LPCTSTR BASE_ARG_KEY;
	 typedef void* BASE_VALUE;
	 typedef void* BASE_ARG_VALUE;
};

/**************************************************************************************************/
/**************************************************************************************************/
/**************************************************************************************************/

class CMyMapStringToOb : public CMapStringToOb
{
	DECLARE_DYNAMIC(CMyMapStringToOb)

 protected:
		/* Association */
	 struct CMyAssoc
	 {
		 CMyAssoc  *pNext;
	 	UINT      nHashValue;  // needed for efficient iteration
		 LPCTSTR   key;
	 	CObject   *value;
	 };

 public:
  CMyMapStringToOb(int nBlockSize = 10);

	 int GetCount() const;
	 BOOL IsEmpty() const;
  BOOL Lookup(LPCTSTR key, CObject*& rValue) const;
		CObject*& operator[](LPCTSTR key);
  void SetAt(LPCTSTR key, CObject* newValue); 
  BOOL RemoveKey(LPCTSTR key);
	 void RemoveAll();
  POSITION GetStartPosition() const; 
	 void GetNextAssoc(POSITION& rNextPosition, CString& rKey, CObject*& rValue) const;
  void GetNextAssoc(POSITION& rNextPosition, LPCTSTR &rKey, CObject*& rValue) const;
  UINT GetHashTableSize() const;
	 void InitHashTable(UINT hashSize, BOOL bAllocNow = TRUE);
  UINT HashKey(LPCTSTR key) const;

 protected:
	 CMyAssoc** m_pHashTable;
	 UINT m_nHashTableSize;
	 int m_nCount;
	 CMyAssoc* m_pFreeList;
	 struct CMyPlex* m_pBlocks;
	 int m_nBlockSize;

	 CMyAssoc* NewAssoc();
	 void FreeAssoc(CMyAssoc*);
	 CMyAssoc* GetAssocAt(LPCTSTR, UINT&) const;

 public:
	 ~CMyMapStringToOb();

	protected:
		// local typedefs for CTypedPtrMap class template
		typedef LPCTSTR BASE_KEY;
		typedef LPCTSTR BASE_ARG_KEY;
		typedef CObject* BASE_VALUE;
		typedef CObject* BASE_ARG_VALUE;
};

#endif
