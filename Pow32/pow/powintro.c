/***************************************************************************
 *                                                                         *
 *  MODULE    : PowIntro.c                                                 *
 *                                                                         *
 *  PURPOSE   : Contains the Splash Screen functionf for Pow!              *
 *                                                                         *
 *  FUNCTIONS : ShowIntroScreen - Display the startup screen               *
 *              HideIntroScreen - Remove the startup screen                *
 *                                                                         *
 ***************************************************************************/

#include <string.h>
#include <windows.h>

#include "pow.h"
#include "powintro.h"
#include "resource.h"

/* globals */
BOOL introScreen= FALSE;
HWND hwndIntro;
HBITMAP hIntro;

/* defines */
#define INTROCLASS "PowIntroWnd"     // intro window class name

/*********************************
 * intro screen window procedure *
 *********************************/

LRESULT CALLBACK IntroWndProc (HWND hwnd,WORD msg,WPARAM wParam,LPARAM lParam )
{
    if (msg==WM_PAINT) {
        RECT r;
        HDC dc,memdc;
	    HBITMAP oldmap;
	    PAINTSTRUCT ps;

	    if (hIntro) {
            GetClientRect(hwnd,&r);
	        dc=BeginPaint(hwnd,(LPPAINTSTRUCT)&ps);
  		    memdc=CreateCompatibleDC(dc);
		    oldmap=SelectObject(memdc,hIntro);
		    BitBlt(dc,(r.right-INTRODX)/2,(r.bottom-INTRODY)/2,INTRODX,INTRODY,memdc,0,0,SRCCOPY);
            SelectObject(memdc,oldmap);
		    DeleteDC(memdc);
		    EndPaint(hwnd,(LPPAINTSTRUCT)&ps);
		}
        return 0;
    }
    else if (msg==WM_LBUTTONDOWN) {
        HideIntroScreen();
        return 0;
    }
    return DefWindowProc(hwnd,msg,wParam,lParam);
}


/******************************
 * display the startup screen *
 ******************************/

void ShowIntroScreen (void)
{
    int x,y,dx,dy;
    WNDCLASS wc;

    // Register the frame class
    wc.style         = CS_NOCLOSE;
    wc.lpfnWndProc   = (WNDPROC) IntroWndProc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.hInstance     = hInst;
    wc.hIcon         = NULL;
    wc.hCursor       = NULL;
    wc.hbrBackground = (HBRUSH)(COLOR_APPWORKSPACE+1);
    wc.lpszMenuName  = NULL;
    wc.lpszClassName = INTROCLASS;

    if (RegisterClass(&wc)) {
        // Load Splashscreen Bitmap
        hIntro=LoadBitmap(hInst,MAKEINTRESOURCE(IDB_INTRO));
        if (hIntro) {
            // Create the frame
            dx=INTRODX;
            dy=INTRODY;
            x=(GetSystemMetrics(SM_CXSCREEN)-dx)/2;
            y=(GetSystemMetrics(SM_CYSCREEN)-dy)/2;
            hwndIntro=CreateWindow(INTROCLASS,NULL,WS_CHILD|WS_VISIBLE|WS_BORDER,x,y,dx,dy,GetDesktopWindow(),NULL,hInst,NULL);
            if (hwndIntro) {
                ShowWindow(hwndIntro,SW_NORMAL);
                UpdateWindow(hwndIntro);
                BringWindowToTop(hwndIntro);
                #ifdef _WIN32
                    SetWindowPos(hwndIntro,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE|SWP_NOSIZE);
                #endif
                introScreen=TRUE;
            }
        }
        if (!introScreen) {
            UnregisterClass(INTROCLASS,hInst);
            if (hIntro) DeleteObject(hIntro);
        }
    }
}

/*****************************
 * remove the startup screen *
 *****************************/

void HideIntroScreen (void)
{
    if (introScreen) {
        DestroyWindow(hwndIntro);
        DeleteObject(hIntro);
        UnregisterClass(INTROCLASS,hInst);
    }
    introScreen=FALSE;
}

/*****************************
 * bring intro screen to top *
 *****************************/

void IntroScreenToTop (void)
{
    if (introScreen) {
        BringWindowToTop(hIntro);
        InvalidateRect(hIntro,NULL,FALSE);
        UpdateWindow(hIntro);
    }
}