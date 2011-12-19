#include <string.h>
#include <stdlib.h>
#include <windows.h>
                    
#include "pow.h"
#include "powopts.h"  
#include "powed.h"
#include "powCompiler.h"

typedef int FAR PASCAL InterfaceVersionProc (void);
typedef void FAR PASCAL NewEditWindowProc (HWND,BOOL);
typedef void FAR PASCAL CloseEditWindowProc (HWND);
typedef int FAR PASCAL HasChangedProc (HWND);
typedef int FAR PASCAL LoadFileProc (HWND,LPSTR);
typedef int FAR PASCAL SaveFileProc (HWND,LPSTR);
typedef void FAR PASCAL GetCursorposProc (HWND,LPLONG,LPLONG);
typedef int FAR PASCAL CopyProc (HWND);
typedef int FAR PASCAL PasteProc (HWND);
typedef int FAR PASCAL CutProc (HWND);
typedef int FAR PASCAL ClearProc (HWND);
typedef void FAR PASCAL UndoProc (HWND);
typedef void FAR PASCAL RedoProc (HWND);
typedef void FAR PASCAL GotoPosProc (HWND,long,long);
typedef int FAR PASCAL SearchProc (HWND,LPSTR,int,int,int);
typedef int FAR PASCAL ReplaceProc (HWND,LPSTR,LPSTR,int,int,int,int,int);
typedef void FAR PASCAL EditOptionsProc (void);
typedef void FAR PASCAL KeywordsProc (int,LPSTR);
typedef void FAR PASCAL SetCommandProcedureProc (FARPROC);
typedef void FAR PASCAL CommentsProcOld (LPSTR,LPSTR);
typedef void FAR PASCAL CommentsProc (int,LPSTR,LPSTR,LPSTR);
typedef void FAR PASCAL SetHelpFileProc (LPSTR);
typedef long FAR PASCAL GetFirstBufferProc (HWND,LPSTR,long);
typedef long FAR PASCAL GetNextBufferProc (HWND,LPSTR,long);
typedef HGLOBAL FAR PASCAL GetTextProc (HWND);
typedef int FAR PASCAL GeneratesAsciiProc (void);
typedef long FAR PASCAL LoadNextBufferProc (LPHANDLE,LPSTR,long);
typedef int FAR PASCAL CanUndoProc (void);
typedef int FAR PASCAL PrintWindowProc (HWND);
typedef int FAR PASCAL AddTextProc (HWND,LPSTR);
typedef int FAR PASCAL InsertTextProc (HWND,LPSTR);
typedef void FAR PASCAL ResizeWindowProc (HWND,int,int);
typedef int FAR PASCAL HasSelectionProc (HWND);
typedef void FAR PASCAL ResetContentProc (HWND);
typedef int FAR PASCAL GetLineProc (HWND,int,int,LPSTR);
typedef void FAR PASCAL ShowHelpProc (HWND);
typedef void FAR PASCAL UnloadEditorProc (void);

/*
typedef void FAR PASCAL CommentProc (HANDLE,LPLONG,LPSTR,LPSTR,LPSTR);
typedef void FAR PASCAL KeywordProc (HANDLE,LPLONG,FARPROC);
*/

FARPROC getFirstBufferProc=0;
FARPROC getNextBufferProc=0;
FARPROC editLoadOpenProc=0;
FARPROC editLoadReadProc=0;
FARPROC editLoadCloseProc=0;
FARPROC editReplaceProc=0;

static FARPROC interfaceVersionProc=0;
static FARPROC newEditWindowProc=0;
static FARPROC closeEditWindowProc=0;
static FARPROC hasChangedProc=0;
static FARPROC loadFileProc=0;
static FARPROC saveFileProc=0;
static FARPROC getCursorposProc=0;
static FARPROC copyProc=0;
static FARPROC pasteProc=0;
static FARPROC cutProc=0;
static FARPROC clearProc=0;
static FARPROC undoProc=0;
static FARPROC redoProc=0;
static FARPROC gotoPosProc=0;
static FARPROC searchProc=0;
static FARPROC editOptionsProc=0;
static FARPROC keywordsProc=0;
static FARPROC setCommandProcedureProc=0;
static FARPROC commentsProc=0;
static FARPROC setHelpFileProc=0;
static FARPROC generatesAsciiProc=0;
static FARPROC canUndoProc=0;
static FARPROC printWindowProc=0;
static FARPROC addTextProc=0;
static FARPROC insertTextProc=0;
static FARPROC resizeWindowProc=0;
static FARPROC hasSelectionProc=0;
static FARPROC resetContentProc=0;
static FARPROC getTextProc=0;
static FARPROC getLineProc=0;
static FARPROC showHelpProc=0;
static FARPROC unloadEditorProc=0;

static HINSTANCE hInstEdit=0;
static int error;
static char errorProc[100];
static int wasEditorMessage= 0;

void GetProcedure (HINSTANCE hInst,FARPROC *proc,LPSTR name)
{
    if (!error) {
        *proc=GetProcAddress(hInst,name);
        if (!*proc) {
            error=TRUE;
            strcpy(errorProc,name);
        }
    }
}    
    
void GetAdditionalProcedure (HINSTANCE hInst,FARPROC *proc,LPSTR name)
{
    if (!error)
        *proc=GetProcAddress(hInst,name);
}

BOOL far CloseEditor (void)
{    
    if (QueryCloseAllChildren()) {
        CloseAllChildren();
        ShowWindow(hwndMDIClient,SW_SHOW);
        if (hInstEdit) {
            EditUnloadEditor();
            FreeLibrary(hInstEdit);
            hInstEdit=0;
        }
        return TRUE;
    }
    return FALSE;
}

BOOL far UseNewEditor (void)
{               
    DWORD ret;
    HINSTANCE h;
    FARPROC test;
    char editor[MAXPATHLENGTH];      
    
    wasEditorMessage=0;
    lstrcpy(editor,defaultDir);
    if (editor[lstrlen(defaultDir)-1]!='\\') lstrcat(editor,"\\");
    lstrcat(editor,actConfig.editor);
                   
    h=LoadLibrary(editor);
#ifdef _WIN32
    if (h) {     
#else
    if (h>=HINSTANCE_ERROR) {     
#endif
        error=FALSE;              
        GetProcedure(h,&test,"InterfaceVersion");
        GetProcedure(h,&test,"NewEditWindow");
        GetProcedure(h,&test,"CloseEditWindow");
        GetProcedure(h,&test,"HasChanged");
        GetProcedure(h,&test,"LoadFile");
        GetProcedure(h,&test,"SaveFile");
        GetProcedure(h,&test,"GetCursorpos");
        GetProcedure(h,&test,"Copy");
        GetProcedure(h,&test,"Paste");
        GetProcedure(h,&test,"Cut");
        GetProcedure(h,&test,"Clear");
        GetProcedure(h,&test,"Undo");
        GetProcedure(h,&test,"Redo");
        GetProcedure(h,&test,"GotoPos");
        GetProcedure(h,&test,"Search");
        GetProcedure(h,&test,"Replace");
        GetProcedure(h,&test,"EditOptions");
        GetProcedure(h,&test,"Keywords");
        GetProcedure(h,&test,"SetCommandProcedure");
        GetProcedure(h,&test,"Comments");
        GetProcedure(h,&test,"SetHelpFile");
        GetProcedure(h,&test,"GetFirstBuffer");
        GetProcedure(h,&test,"GetNextBuffer");
        GetProcedure(h,&test,"GeneratesAscii");
        GetProcedure(h,&test,"LoadOpen");
        GetProcedure(h,&test,"LoadRead");
        GetProcedure(h,&test,"LoadClose");
        GetProcedure(h,&test,"CanUndo");
        GetProcedure(h,&test,"PrintWindow");
        GetProcedure(h,&test,"AddText");
        GetProcedure(h,&test,"InsertText");
        GetProcedure(h,&test,"ResizeWindow");
        GetProcedure(h,&test,"HasSelection");
        GetProcedure(h,&test,"ResetContent");
        GetProcedure(h,&test,"GetText");
        GetProcedure(h,&test,"GetLine");
        GetProcedure(h,&test,"ShowHelp");
        GetAdditionalProcedure(h,&test,"UnloadEditor");
        
        if (error) {
            FreeLibrary(h);
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITORPROCEDURE,errorProc);
        }
        else {
            if (CloseEditor()) {
                GetProcedure(h,&interfaceVersionProc,"InterfaceVersion");
                GetProcedure(h,&newEditWindowProc,"NewEditWindow");
                GetProcedure(h,&closeEditWindowProc,"CloseEditWindow");
                GetProcedure(h,&hasChangedProc,"HasChanged");
                GetProcedure(h,&loadFileProc,"LoadFile");
                GetProcedure(h,&saveFileProc,"SaveFile");
                GetProcedure(h,&getCursorposProc,"GetCursorpos");
                GetProcedure(h,&copyProc,"Copy");
                GetProcedure(h,&pasteProc,"Paste");
                GetProcedure(h,&cutProc,"Cut");
                GetProcedure(h,&clearProc,"Clear");
                GetProcedure(h,&undoProc,"Undo");
                GetProcedure(h,&redoProc,"Redo");
                GetProcedure(h,&gotoPosProc,"GotoPos");
                GetProcedure(h,&searchProc,"Search");
                GetProcedure(h,&editReplaceProc,"Replace");
                GetProcedure(h,&editOptionsProc,"EditOptions");
                GetProcedure(h,&keywordsProc,"Keywords");
                GetProcedure(h,&setCommandProcedureProc,"SetCommandProcedure");
                GetProcedure(h,&commentsProc,"Comments");
                GetProcedure(h,&setHelpFileProc,"SetHelpFile");
                GetProcedure(h,&getFirstBufferProc,"GetFirstBuffer");
                GetProcedure(h,&getNextBufferProc,"GetNextBuffer");
                GetProcedure(h,&generatesAsciiProc,"GeneratesAscii");
                GetProcedure(h,&editLoadOpenProc,"LoadOpen");
                GetProcedure(h,&editLoadReadProc,"LoadRead");
                GetProcedure(h,&editLoadCloseProc,"LoadClose");
                GetProcedure(h,&canUndoProc,"CanUndo");
                GetProcedure(h,&printWindowProc,"PrintWindow");
                GetProcedure(h,&addTextProc,"AddText");
                GetProcedure(h,&insertTextProc,"InsertText");
                GetProcedure(h,&resizeWindowProc,"ResizeWindow");
                GetProcedure(h,&hasSelectionProc,"HasSelection");
                GetProcedure(h,&resetContentProc,"ResetContent");
                GetProcedure(h,&getTextProc,"GetText");
                GetProcedure(h,&getLineProc,"GetLine");
                GetProcedure(h,&showHelpProc,"ShowHelp");
                GetAdditionalProcedure(h,&unloadEditorProc,"UnloadEditor");
                hInstEdit=h;
                if (*compilerHelpfile)
                    EditSetHelpFile(compilerHelpfile);
                EditSetSyntax();
            }
            else {
                Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_USEOLDEDITOR);
                return FALSE;
            }
        }
    }
    else {
        long  size;
        char buf[1000];

        Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_CANNOTLOADEDITOR,editor);
        ret = GetLastError();
        size = FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,NULL,ret,GetSystemDefaultLangID(),buf,sizeof(buf),NULL);
        MessageBox(0,buf,"Error Message",MB_OK|MB_ICONEXCLAMATION);
    }
    return TRUE;
}
                                  
BOOL far EditorIsOpen (void)
{
    return (hInstEdit!=0);
}

BOOL far IsEditWindow (HWND hwnd)
{
    return (GetWindowWord(hwnd,GWW_EDITWIN)!=0);
}

int far EditInterfaceVersion (void)
{        
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(InterfaceVersionProc*)interfaceVersionProc)();
}

void far EditNewEditWindow (HWND parent,BOOL readOnly)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(NewEditWindowProc*)newEditWindowProc)(parent,readOnly);
}

void far EditCloseEditWindow (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(CloseEditWindowProc*)closeEditWindowProc)(edit);
}

int far EditHasChanged (HWND edit)
{   
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(HasChangedProc*)hasChangedProc)(edit);
}

int far EditLoadFile (HWND edit,LPSTR name)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(LoadFileProc*)loadFileProc)(edit,name);
}

int far EditSaveFile (HWND edit,LPSTR name)
{                                                    
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(SaveFileProc*)saveFileProc)(edit,name);
}

void far EditGetCursorpos (HWND edit,LPLONG row,LPLONG col)
{                                                    
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(GetCursorposProc*)getCursorposProc)(edit,row,col);
}

int far EditCopy (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(CopyProc*)copyProc)(edit);
}

int far EditPaste (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(PasteProc*)pasteProc)(edit);
}

int far EditCut (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(CutProc*)cutProc)(edit);
}

int far EditClear (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(ClearProc*)clearProc)(edit);
}

void far EditUndo (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(UndoProc*)undoProc)(edit);
}

void far EditRedo (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(RedoProc*)redoProc)(edit);
}

void far EditGotoPos (HWND edit,long row,long col)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(GotoPosProc*)gotoPosProc)(edit,row,col);
}

int far EditSearch (HWND edit,LPSTR text,int matchcase,int down,int words)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(SearchProc*)searchProc)(edit,text,matchcase,down,words);
}

int far EditReplace (HWND edit,LPSTR text,LPSTR newtext,int matchcase,int down,int words,int all,int ask)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(ReplaceProc*)editReplaceProc)(edit,text,newtext,matchcase,down,words,all,ask);
}

void far EditEditOptions (void)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(EditOptionsProc*)editOptionsProc)();
}

void far EditKeywords (int caseSensitive,LPSTR words)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(KeywordsProc*)keywordsProc)(caseSensitive,words);
}

void far EditSetCommandProcedure (FARPROC command)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(SetCommandProcedureProc*)setCommandProcedureProc)(command);
}

void far EditComments (int nested,LPSTR on,LPSTR off,LPSTR strings)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    
    if (EditInterfaceVersion()<160)
        (*(CommentsProcOld*)commentsProc)(on,off);
    else
        (*(CommentsProc*)commentsProc)(nested,on,off,strings);
}

void far EditSetHelpFile (LPSTR name)
{
    if (!hInstEdit) 
        // no error message!
        return;
    (*(SetHelpFileProc*)setHelpFileProc)(name);
}

long far EditGetFirstBuffer (HWND edit,LPSTR buf,long size)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(GetFirstBufferProc*)getFirstBufferProc)(edit,buf,size);
}

long far EditGetNextBuffer (HWND edit,LPSTR buf,long size)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(GetNextBufferProc*)getNextBufferProc)(edit,buf,size);
}

int far EditGeneratesAscii (void)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(GeneratesAsciiProc*)generatesAsciiProc)();
}

int far EditCanUndo (void)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(CanUndoProc*)canUndoProc)();
}

int far EditPrint (HWND edit)
{              
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(PrintWindowProc*)printWindowProc)(edit);
}

int far EditAddText (HWND edit,LPSTR text)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(AddTextProc*)addTextProc)(edit,text);
}

int far EditInsertText (HWND edit,LPSTR text)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(InsertTextProc*)insertTextProc)(edit,text);
}

void far EditResizeWindow (HWND edit,int dx,int dy)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(ResizeWindowProc*)resizeWindowProc)(edit,dx,dy);
}

int far EditHasSelection (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(HasSelectionProc*)hasSelectionProc)(edit);
}

void far EditResetContent (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(ResetContentProc*)resetContentProc)(edit);
}

HGLOBAL far EditGetText (HWND edit)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(GetTextProc*)getTextProc)(edit);
}

int far EditGetLine (HWND edit,int line,int max,LPSTR buf)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return FALSE;
    }
    return (*(GetLineProc*)getLineProc)(edit,line,max,buf);
}

void far EditShowHelp (HWND powwnd)
{
    if (!hInstEdit) {
        if (!wasEditorMessage) {
            Message(0,MB_OK|MB_ICONEXCLAMATION,IDS_NOEDITOR);
            wasEditorMessage=1;
        }
        return;
    }
    (*(ShowHelpProc*)showHelpProc)(powwnd);
}
           
static char words[1000];           
                                 
void FAR PASCAL _export EnumerateKeywords (LPSTR word)
{                
    char s[2]={1,0};

    strcat(words,word);
    strcat(words,s);
}                                 
                                 
void far EditSetSyntax (void)
{
    LPSTR p;
    long caseSensitive,nested;
    char commentOn[100],commentOff[100],strings[100];
    FARPROC enumProc;
    
    if (IsCompilerInterfaceLoaded() && hInstEdit) {
        *words=0;
        nested=0;
        caseSensitive=0;

//        commentProc=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_EDITORCOMMENT));
        (*compComment)(hCompData,(LPLONG)&nested,(LPSTR)commentOn,(LPSTR)commentOff,(LPSTR)strings);
        EditComments((int)nested,(LPSTR)commentOn,(LPSTR)commentOff,(LPSTR)strings);
                                 
//        keywordProc=GetProcAddress(actDLL,MAKEINTRESOURCE(DLL_EDITORSYNTAX));
        enumProc=MakeProcInstance((FARPROC)EnumerateKeywords,hInst);
        (*compKeyword)(hCompData,(LPLONG)&caseSensitive,enumProc);
        p=words;
        while (*p) {
            if (*p==1) *p=0;  // reset placeholders
            p++;
        }
        FreeProcInstance(enumProc);
        EditKeywords((int)caseSensitive,(LPSTR)words);
    }
}

void far EditUnloadEditor (void)
{
    if (unloadEditorProc)
        (*(UnloadEditorProc*)unloadEditorProc)();
}