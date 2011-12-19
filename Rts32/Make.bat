@ECHO OFF

REM ---------------------------------------------------------------------------
REM Batchfile for creating the Oberon-2 run-time-system
REM ---------------------------------------------------------------------------
REM source files:
REM RTSDLL.OBJ ..... DLL initialisatiom
REM RTSOBERON.OBJ .. run-time system for Oberon-2
REM RTSSTR.OBJ ..... some string functions for the run-time system
REM RTSWIN.OBJ ..... Win32 API Definitionen for RTSOberon.mod
REM result files:
REM RTS32S.LIB .................. static run-time system without garbage coll.
REM RTS32D.LIB, RTS32D.DLL ...... dynamic run-time system without garbage coll.
REM RTS32SGC.LIB ................ static run-time system with garbage collector
REM RTS32DGC.LIB, RTS32GC.DLL ... dynamic run-time system with garbage collector
REM ---------------------------------------------------------------------------

rem -- description of this batch file --
cls
echo.
echo.
echo This batch file builds the run-time system for Oberon-2.
echo.
echo Please follow the presented steps.
echo.
echo.
pause

REM -- filename with path for lib command --
SET LIBCMD="Lib.exe"

REM -- Test Lib-Command --
%LIBCMD% > NUL
if not errorlevel 255 goto LabelContinue
  cls
  echo.
  echo.
  echo The lib command didn't work. 
  echo.
  echo Please modify the setting of the environment variable LIBCMD 
  echo in this batch file.
  echo.
  echo.
  pause
  goto LabelExit
:LabelContinue


rem -- description for dynamic run-time system without garbage collector --
cls
echo.
echo 1. Load the project Rts32d.prj.
echo 2. Set the constant START_GC in the module RTSOberon.mod to FALSE.
echo 3. Save the module RTSOberon.mod.
echo 4. Make the project.
echo.
pause

REM -- build static run-tim system without garbage collector --
%LIBCMD% /OUT:RTS32S.LIB rtsoberon.obj rtsstr.obj rtswin.obj
IF ERRORLEVEL 1 GOTO LabelExit

rem -- description for dynamic run-time system with garbage collector --
cls
echo.
echo 1. Load the project Rts32dgc.prj.
echo 2. Set the constant START_GC in the module RTSOberon.mod to TRUE.
echo 3. Save the module RTSOberon.mod.
echo 4. Make the project.
echo.
pause

REM -- build static run-time system with garbage collector --
%LIBCMD% /OUT:RTS32SGC.LIB rtsoberon.obj rtsstr.obj rtswin.obj
IF ERRORLEVEL 1 GOTO LabelExit

:LabelExit