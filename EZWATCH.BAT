@ECHO OFF
ECHO [33m---------------------------------------------------------------------------
ECHO [33mEZWatch - This is the watchdog application for EZBoards.
ECHO [33mIt will watch for modifications of your briefing file
ECHO [33m and subsequently run EZBoards to regenerate your kneeboards automatically.
ECHO [33m---------------------------------------------------------------------------[0m

REM /// Get BASEDIR and PILOTBIN from Registry.
REM /// Note: This part will need to be updated in future versions of BMS.
SET REGPATH="HKLM\SOFTWARE\WOW6432Node\Benchmark Sims\Falcon BMS 4.37"

REM /// delims is a TAB followed by a space
FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY %REGPATH% /v baseDir') DO SET BASEDIR=%%B
ECHO BASEDIR=%BASEDIR%

FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY %REGPATH% /v PilotCallsign') DO SET PILOTBIN=%%B
ECHO PILOTBIN=%PILOTBIN%

REM /// Convert the REG_BINARY callsign from Registry to a string
SETLOCAL EnableDelayedExpansion
ECHO !PILOTBIN!> temp.hex
CALL certutil -decodehex temp.hex str.txt >nul
ENDLOCAL
SET /p PILOTCALLSIGN=<str.txt
( DEL temp.hex & DEL str.txt )>nul

ECHO PILOTCALLSIGN=%PILOTCALLSIGN%

SET BRIEFINGTXT="%BASEDIR%\User\Briefings\briefing.txt"
ECHO BRIEFINGTXT=%BRIEFINGTXT%

ECHO [33m---------------------------------------------------------------------------[0m

REM /// Now call the real watchdog application
REM CALL bin\when_changed.exe %BRIEFINGTXT% EZBOARDS.BAT "/a > nul 2>&1"
CALL bin\when_changed.exe %BRIEFINGTXT% EZ2PAGES.BAT "/a > nul 2>&1"
