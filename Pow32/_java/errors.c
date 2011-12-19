//
// Implementierung des Moduls zur Fehlerausgabe
//

#include <string.h>
#include <windows.h>
#include <fcntl.h>
#include <windowsx.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <assert.h>
#include "errors.h"

HANDLE file;
char   buffer[10000], actualLine[120];
int    actualLineNo;
DWORD  bytesInBuffer, byteCtr;

void FillBuffer (void);
void ReadNextErrorMessage (void);
int IsError (void);


int StartAnalyze (LPSTR fileName)
{
  byteCtr = 0;
  file = CreateFile (fileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (file != INVALID_HANDLE_VALUE) {
	 FillBuffer ();
	 return TRUE;
  }
  else return FALSE;
}

void EndAnalyze (void)
{
  if (file != INVALID_HANDLE_VALUE)
     CloseHandle (file);
}

void GetLine (LPSTR retLine)
{
  if (actualLine)
    strcpy (retLine, actualLine);
  else
    *retLine = 0;
}

int GetLineNo (LPSTR message)
{
  LPSTR lpch;
  int   charCtr;
  int   ret;
  char  lineNo[10];
  
  ret = -1;
  charCtr = 0;

  lpch = actualLine;
  lpch = strchr (lpch, ':');
  while (lpch && (lpch[1]<'0' || lpch[1]>'9'))
     lpch = strchr (lpch+1, ':');

  if (lpch) {
	 lpch++;
	 while ((*lpch >= '0') && (*lpch <= '9') && (charCtr < sizeof(lineNo)-1)) {
		lineNo[charCtr++] = *lpch;
		lpch++;
	 }
     if (charCtr) {
        /* line number found -> decode */
        lineNo[charCtr] = 0;
        ret = atoi (lineNo);

        /* retrieve error text following line number */
        if (lpch && *lpch) {
            if (*lpch == ':') lpch++;
            if (*lpch == ' ') lpch++;
            strcpy (message, lpch);
        }
        else
            *message = 0;
     }
  }
  return ret;
}

int GetColumnNo (void)
{
  NextError ();
  NextError ();
  return (strlen (actualLine));
}

int NextError (void)
{
  if (bytesInBuffer > byteCtr) {
	 ReadNextErrorMessage ();
	 return TRUE;
  }
  return FALSE;
}

void ReadNextErrorMessage (void)
{
  int i;

  i = 0;
  *actualLine = 0;

  if (bytesInBuffer != 0) {
	 while (buffer[byteCtr] != '\n' && buffer[byteCtr] != 0) {
        if (buffer[byteCtr] >= ' ')
		    actualLine[i++] = buffer[byteCtr];
        byteCtr++;
     }
     actualLine[i] = 0;
  }
  else {
	actualLine[0] = '\n';
    actualLine[1] = 0;
	actualLineNo = -1;
  }
  byteCtr++;
}

void FillBuffer (void)
{
  if (!ReadFile (file, buffer, sizeof(buffer), &bytesInBuffer, NULL))
      bytesInBuffer = 0;
  byteCtr = 0;
}

