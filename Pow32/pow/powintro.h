#ifndef INC_POWINTRO
#define INC_POWINTRO

#include <windows.h>

#define INTRODX    396               // width of intro bitmap
#define INTRODY    271               // height of intro bitmap

extern BOOL introScreen;

void ShowIntroScreen();
void HideIntroScreen();
void IntroScreenToTop();

#endif
