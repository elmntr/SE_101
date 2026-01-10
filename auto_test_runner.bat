@echo off
title Auto Flutter Test Runner
color 0A

echo.
echo ========================================
echo   Auto Flutter Test Runner
echo ========================================
echo.
echo   Running flutter test every 30 seconds
echo   Press Ctrl+C to stop
echo.
echo ========================================
echo.

set counter=1

:loop
echo [Run #%counter%] Starting flutter test... %time%
echo ----------------------------------------

flutter test --reporter=compact

echo.
echo [Run #%counter%] Completed. Waiting 30 seconds...
echo.
timeout /t 30 /nobreak >nul

set /a counter+=1
goto loop
