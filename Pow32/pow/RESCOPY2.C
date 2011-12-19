#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <direct.h>

int res,exe,out;

int main()
{
    char resnam[80],exenam[80];

    printf("Enter resource file name or ENTER to quit: " );
    gets(resnam);
    if ((!resnam) || ((res=_lopen(resnam,OF_READ))==-1))
        break;

    printf("Enter executable file name or ENTER to quit: " );
    gets(exe);
    if ((!exe) || ((exe=_lopen(exenam,OF_READ))==-1)) {
        _lclose(res);
        break;
    }

    if ((out=_lcreat("out.exe",0))==-1)
        _lclose(res);
        _lclose(exe);
        break;



    _lclose(res);
    _lclose(exe);
    _lclose(out);
    return 0;
}


