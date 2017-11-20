@echo off
SET AHKPath=C:\Program Files\AutoHotkey
REM Takes a sinple optional command parameter, /t, which starts testing.
SET Param1=%1

if "%Param1%"=="/t" (
    Start "%AHKPath%\Autohotkey.exe" vim_onenote.ahk 
    "%AHKPath%\Autohotkey.exe" vim_onenote_testscript.ahk 
)
REM Return code from above (0 if tests all pass) is stored in %errorlevel%
if errorlevel 1 (
   echo Tests failed. Exe not built.
   exit /b %errorlevel%
)
REM You need intall ahk2exe, this script assumes it is at \bin_drop\ahk2exe
"%AHKPath%\compiler\ahk2exe.exe" /in vim_onenote.ahk /out vim_onenote.exe