/***************************************************************************
 *                                                                         *
 *  MODULE    : PowStat.c                                                  *
 *                                                                         *
 *  PURPOSE   : Contains the code for drawing the status bar               *
 *                                                                         *
 *  FUNCTIONS : InitStatus    - Initializes the status bar resources       *
 *                                                                         *
 *              DestroyStatus - Frees bar resources (pen,brush,bitmaps)    *
 *                                                                         *
 *              ShowBar       - Resizes the bar after window has changed   *
 *                                                                         *
 *              ShowLineNr    - Draws line/column of edit window in bar    *
 *                                                                         *
 *              ShowModified  - Views edit-modification flag               *
 *                                                                         *
 *              ShowInsert    - Views Insert/Overwrite mode                *
 *                                                                         *
 *              ShowMessage   - Environment messages are put there         *
 *                                                                         *
 *              EraseStatus   - Erase status bar                           *
 *                                                                         *
 *              NewLineNr     - Update edit position                       *
 *                                                                         *
 *              NewModified   - Update edit-modification flag              *
 *                                                                         *
 *              NewMessage    - Use a new environment message              *
 *                                                                         *
 *              NewInsertMode - Update insert mode                         *
 *                                                                         *
 *              ToggleInsert  - Toggle insert/overwrite mode               *
 *                                                                         *
 ***************************************************************************/

#include <windows.h>
#include <string.h>
#include <stdlib.h>
                
#include "pow.h"
                
/* window position parameters */
#define POSOFFSET 3
#define POSCENTER 40
#define POSLEN    76
#define INSOFFSET 90
#define INSLEN    67
#define MODOFFSET 170
#define MODLEN    67
#define MSGOFFSET 250

/* globals */
int barMsgX;
int barMsgY;
int barCol;
int barRow=-1;
int insMode=1;
RECT msgRct;
BOOL barRed=FALSE;
BOOL modified=FALSE;
char insText[2][20]= {"Overwrite","Insert"};
char barMsg[80]="";

COLORREF red;

/* resources */
HBITMAP hStatBar;                /* status bar bitmap: connection */
HBITMAP hStatMap;                /* status bar bitmap: background */
HBITMAP hGreyMap;                /* grey pixel bitmap */

/* externals */
extern HWND hwndFrame;
extern HANDLE hInst;
extern HFONT smallFont;

/***************************************************************************
 *                                                                         *
 * FUNCTION    : InitStatus ()                                             *
 *                                                                         *
 * PURPOSE     : Initialize pens, brushes and bitmaps for status bar       *
 *                                                                         *
 ***************************************************************************/

VOID FAR InitStatus ()
{
    /* get colors */
    red=RGB(128,0,0);

    /* load Status bar bitmaps */
    hStatMap=LoadBitmap(hInst,"statmap");
    hStatBar=LoadBitmap(hInst,"statbar");
    hGreyMap=LoadBitmap(hInst,"greymap");
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : DestroyStatus ()                                          *
 *                                                                         *
 * PURPOSE     : Destroy pens, brushes and bitmaps for status bar          *
 *                                                                         *
 ***************************************************************************/

VOID FAR DestroyStatus ()
{
    /* purge bitmaps */
    DeleteObject(hStatMap);
    DeleteObject(hStatBar);
    DeleteObject(hGreyMap);
}

/***************************************************************************
 *                                                                         *
 * FUNCTION    : EraseStatus (linNr,insMod,msgStr)                         *
 *                                                                         *
 * PURPOSE     : Removes the parts of the status bar set as TRUE           *
 *                                                                         *
 ***************************************************************************/

void FAR EraseStatus (BOOL linNr,BOOL insMod,BOOL msgStr,BOOL edtMod)
{
    char c='x';
    RECT r;
	RECT fillRect;
    int dy;
    TEXTMETRIC tm;
    HDC hDC;
//	HDC hMemDC;                             
//	BOOL res;
	HBRUSH greyBrush;

    hDC=GetDC(hwndFrame);

    if (!IsIconic(hwndFrame)) {

        #ifdef _WIN32
            SIZE size;
            GetTextExtentPoint32(hDC,&c,1,&size);
            dy=(int)size.cy;
        #else
            dy=HIWORD(GetTextExtent(hDC,&c,1));
        #endif

        GetTextMetrics(hDC,&tm);
        dy-=tm.tmDescent;
        GetClientRect(hwndFrame,(LPRECT)&r);
        barMsgX=r.right;
        barMsgY=r.bottom-STATHIGH+(STATHIGH>>1)-(dy>>1);
        fillRect.top=r.bottom-STATHIGH+(STATHIGH>>1)-(dy>>1);
		fillRect.bottom=fillRect.top+dy;
	}
    else dy=13;

//    hMemDC=CreateCompatibleDC(hDC);

//    SelectObject(hMemDC,hGreyMap);
	greyBrush=GetStockObject(LTGRAY_BRUSH);

    if (linNr) {
	    fillRect.left=POSOFFSET;
        fillRect.right=fillRect.left+POSLEN;
        FillRect(hDC,&fillRect,greyBrush);
//        res=StretchBlt(hDC,POSOFFSET,barMsgY,POSLEN,dy,hMemDC,0,0,1,1,SRCCOPY);
	}
    if (insMod) {
	    fillRect.left=INSOFFSET;
        fillRect.right=fillRect.left+INSLEN;
        FillRect(hDC,&fillRect,greyBrush);
//        StretchBlt(hDC,INSOFFSET,barMsgY,INSLEN,dy,hMemDC,0,0,1,1,SRCCOPY);
	}
    if (edtMod) {
	    fillRect.left=MODOFFSET;
        fillRect.right=fillRect.left+MODLEN;
        FillRect(hDC,&fillRect,greyBrush);
//        StretchBlt(hDC,MODOFFSET,barMsgY,MODLEN,dy,hMemDC,0,0,1,1,SRCCOPY);
	}
    if (msgStr) {
	    fillRect.left=MSGOFFSET;
        fillRect.right=barMsgX-3;
        FillRect(hDC,&fillRect,greyBrush);
//        StretchBlt(hDC,MSGOFFSET,barMsgY,barMsgX-MSGOFFSET-3,dy,hMemDC,0,0,1,1,SRCCOPY);
	}

//    DeleteDC(hMemDC);
    ReleaseDC(hwndFrame,hDC);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ShowLineNr                                                *
 *                                                                         *
 *  PURPOSE    : Display line/column-number of active edit-window          *
 *                                                                         *
 ***************************************************************************/

void ShowLineNr ()
{
    HDC hDC;
    HFONT oldFont;
    char row[10],col[10];

    if (barRow==-1)
        return;

    hDC=GetDC(hwndFrame);

    itoa(barRow,row,10);
    strcat(row,":");
    itoa(barCol,col,10);

    oldFont=SelectObject(hDC,smallFont);
    SetBkMode(hDC,TRANSPARENT);

    SetTextAlign(hDC,TA_RIGHT);
    TextOut(hDC,POSCENTER,barMsgY,(LPSTR)row,strlen(row));

    SetTextAlign(hDC,TA_LEFT);
    TextOut(hDC,POSCENTER,barMsgY,(LPSTR)col,strlen(col));

    SelectObject(hDC,oldFont);
    ReleaseDC(hwndFrame,hDC);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ShowInsert                                                *
 *                                                                         *
 *  PURPOSE    : Display insert/overwrite in status-bar                    *
 *                                                                         *
 ***************************************************************************/

VOID FAR ShowInsert ()
{
    HDC hDC;
    HFONT oldFont;

    if (barRow==-1)
        return;

    hDC=GetDC(hwndFrame);

    SetBkMode(hDC,TRANSPARENT);
    oldFont=SelectObject(hDC,smallFont);
    TextOut(hDC,INSOFFSET,barMsgY,(LPSTR)&insText[insMode],
            strlen(insText[insMode]));
    SelectObject(hDC,oldFont);

    ReleaseDC(hwndFrame,hDC);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ShowModified                                              *
 *                                                                         *
 *  PURPOSE    : Display edit-modification flag                            *
 *                                                                         *
 ***************************************************************************/

void ShowModified ()
{
    HDC hDC;
    HFONT oldFont;

    if (!modified)
        return;

    hDC=GetDC(hwndFrame);

    SetBkMode(hDC,TRANSPARENT);
    oldFont=SelectObject(hDC,smallFont);
    TextOut(hDC,MODOFFSET,barMsgY,"Modified",8);
    SelectObject(hDC,oldFont);

    ReleaseDC(hwndFrame,hDC);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ShowMessage                                               *
 *                                                                         *
 *  PURPOSE    : Put text in message-area of the status-bar                *
 *               (color is either black or red)                            *
 *                                                                         *
 ***************************************************************************/

void ShowMessage ()
{
    HDC hDC;
    HFONT oldFont;

    if (strlen(barMsg)==0)
        return;

    hDC=GetDC(hwndFrame);

    if (barRed)
        SetTextColor(hDC,red);

    SetBkMode(hDC,TRANSPARENT);
    oldFont=SelectObject(hDC,smallFont);
    DrawText(hDC,(LPSTR)barMsg,strlen(barMsg),
             (LPRECT)&msgRct,DT_LEFT);
    SelectObject(hDC,oldFont);

    ReleaseDC(hwndFrame,hDC);
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ShowBar                                                   *
 *                                                                         *
 *  PURPOSE    : Resize the status bar, calculate width from current       *
 *               extent of the frame window                                *
 *                                                                         *
 ***************************************************************************/

VOID FAR ShowBar (HDC hDC)
{
    RECT r;              
    char c='x';
    int x,y,dy;
    HDC hMemDC;
    TEXTMETRIC tm;

    #ifdef _WIN32
        SIZE size;
    #endif

    if (IsIconic(hwndFrame))
        return;

    GetClientRect(hwndFrame,(LPRECT)&r);
    x=r.right;
    y=r.bottom-STATHIGH;
                             
    #ifdef _WIN32
        GetTextExtentPoint32(hDC,&c,1,&size);
        dy=(int)size.cy;
    #else
        dy=HIWORD(GetTextExtent(hDC,&c,1));
    #endif

    GetTextMetrics(hDC,&tm);
    barMsgX=x;
    barMsgY=y+(STATHIGH>>1)-((dy-tm.tmDescent)>>1);

    hMemDC=CreateCompatibleDC(hDC);
           
    SelectObject(hMemDC,hStatMap);
    StretchBlt(hDC,0,y,x,STATHIGH,hMemDC,0,0,1,STATHIGH,SRCCOPY);

    SelectObject(hMemDC,hStatBar);
    BitBlt(hDC,-3,y,6,STATHIGH,hMemDC,0,0,SRCCOPY);
    BitBlt(hDC, 80,y,6,STATHIGH,hMemDC,0,0,SRCCOPY);
    BitBlt(hDC,160,y,6,STATHIGH,hMemDC,0,0,SRCCOPY);
    BitBlt(hDC,240,y,6,STATHIGH,hMemDC,0,0,SRCCOPY);
    BitBlt(hDC,x-3,y,6,STATHIGH,hMemDC,0,0,SRCCOPY);

    msgRct.left=MSGOFFSET;
    msgRct.right=x-3;
    msgRct.top=barMsgY;
    msgRct.bottom=y+STATHIGH-4;

    /* restore device context */
    DeleteDC(hMemDC);

    ShowLineNr();
    ShowInsert();
    ShowModified();
    ShowMessage();
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : NewLineNr (int,int)                                       *
 *                                                                         *
 *  PURPOSE    : Set new edit positions in status bar                      *
 *                                                                         *
 ***************************************************************************/

VOID FAR NewLineNr (int row,int col)
{
    barRow=row;
    barCol=col;
    EraseStatus(TRUE,FALSE,FALSE,FALSE);
    ShowLineNr();
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : NewInsertMode (int)                                       *
 *                                                                         *
 *  PURPOSE    : Set new insert/overwrite mode                             *
 *                                                                         *
 ***************************************************************************/

VOID FAR NewInsertMode (int mode)
{
    insMode=mode;
    EraseStatus(FALSE,TRUE,FALSE,FALSE);
    ShowInsert();
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : NewModified (int)                                         *
 *                                                                         *
 *  PURPOSE    : Set edit-modification flag                                *
 *                                                                         *
 ***************************************************************************/

VOID FAR NewModified (BOOL edtMod)
{
    modified=edtMod;
    EraseStatus(FALSE,FALSE,FALSE,TRUE);
    ShowModified();
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : NewMessage (LPSTR)                                        *
 *                                                                         *
 *  PURPOSE    : Set new environment message                               *
 *                                                                         *
 ***************************************************************************/

VOID FAR NewMessage (LPSTR msg, BOOL red)
{
    barRed=red;
    lstrcpy((LPSTR)barMsg,msg);
    EraseStatus(FALSE,FALSE,TRUE,FALSE);
    ShowMessage();
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : ToggleInsert (int)                                        *
 *                                                                         *
 *  PURPOSE    : Toggle new insert/overwrite mode                          *
 *                                                                         *
 ***************************************************************************/

VOID FAR ToggleInsert ()
{
    insMode=!insMode;
    EraseStatus(FALSE,TRUE,FALSE,FALSE);
    ShowInsert();
}

/***************************************************************************
 *                                                                         *
 *  FUNCTION   : GetInsert ()                                              *
 *                                                                         *
 *  PURPOSE    : Returns insert/overwrite mode                             *
 *                                                                         *
 ***************************************************************************/

BOOL FAR GetInsertMode ()
{
    return insMode;
}

