@ECHO OFF
ECHO [33m-------------------------------------------------------------------------------
ECHO [33mEZBoards - Generate two page images from briefings for Falcon BMS.
ECHO [33mBy "Logic". See ReadMe.txt for documentation.
ECHO [33m-------------------------------------------------------------------------------[0m

REM /// Argument %1 [optional] is destination folder (without trailing \)
REM /// (Enclose in double-quotes for more robust behaviour)
SET DESTFOLDER=pages
IF _%1_ NEQ __ SET DESTFOLDER=%1
ECHO DESTFOLDER=%DESTFOLDER%
IF NOT EXIST %DESTFOLDER% MKDIR %DESTFOLDER%

REM /// Get BASEDIR and PILOTBIN from Registry.
REM /// Note: This part will need to be updated in future versions of BMS.
SET REGPATH="HKLM\SOFTWARE\WOW6432Node\Benchmark Sims\Falcon BMS 4.37"

REM /// delims is a TAB followed by a space
FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY %REGPATH% /v baseDir') DO SET BASEDIR=%%B
ECHO BASEDIR=%BASEDIR%

FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY %REGPATH% /v PilotCallsign') DO SET PILOTBIN=%%B
ECHO PILOTBIN=%PILOTBIN%

FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY %REGPATH% /v curTheater') DO SET THEATER=%%B
ECHO THEATER=%THEATER%

REM /// Convert the REG_BINARY callsign from Registry to a string
SETLOCAL EnableDelayedExpansion
ECHO !PILOTBIN!> temp.hex
CALL certutil -decodehex temp.hex str.txt >nul
ENDLOCAL
SET /p PILOTCALLSIGN=<str.txt
( DEL temp.hex & DEL str.txt )>nul

ECHO PILOTCALLSIGN=%PILOTCALLSIGN%

REM /// Note: Does not take into account "Falcon BMS (User).cfg" g_sBriefingsDirectory!
SET BRIEFINGTXT="%BASEDIR%\User\Briefings\briefing.txt"
ECHO BRIEFINGTXT=%BRIEFINGTXT%

IF NOT EXIST %BRIEFINGTXT% (
  ECHO [91mCould not find briefing.txt file. Did you press PRINT?[0m
  GOTO ERROR
)

SET CALLSIGNINI="%BASEDIR%\User\Config\%PILOTCALLSIGN%.ini"
ECHO CALLSIGNINI=%CALLSIGNINI%

IF NOT EXIST %CALLSIGNINI% (
  ECHO [91mCould not find callsign DTC file. You won't get target steerpoints.[0m
  SET CALLSIGNINI=
)

REM /// Step 1: Generate HTML version of briefing data to briefing.html .
ECHO [33mGenerating HTML version of briefing data to briefing.html.[0m
bin\xbrief.exe %BRIEFINGTXT% %CALLSIGNINI% > briefing.html
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO [32mOk.[0m

REM /// Step 2: Render the left and right pages
REM /// to a different png file, e.g. for use with OpenKneeboards.
ECHO [33mRendering HTML to left and right briefing images.[0m
bin\wkhtmltoimage.exe --width 1024 --height 1554 --disable-smart-width --enable-local-file-access briefing.html %DESTFOLDER%\briefing-1.png
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
bin\wkhtmltoimage.exe --width 2048 --height 1554 --crop-w 1024 --crop-x 1024 --disable-smart-width --enable-local-file-access briefing.html %DESTFOLDER%\briefing-2.png
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
GOTO SUCCESS

ECHO [32mOk.[0m

REM /// Successful exit.
:SUCCESS
ECHO [42m[97mSUCCESS.[0m
IF "%~1"=="" PAUSE
EXIT 0

REM /// Exit on error.
:ERROR
ECHO [41m[97m### ERROR ###[0m
IF "%~1"=="" PAUSE
EXIT 1
