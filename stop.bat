@echo off
echo ==========================================
echo   Stopping Image->Prompt App Services
echo ==========================================
echo.

REM -------------------------
REM Stop Backend (port 8000)
REM -------------------------
echo [1/3] Stopping Backend (port 8000)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8000 ^| findstr LISTENING') do (
    echo     Killing PID %%a
    taskkill /PID %%a /F >nul 2>&1
)

REM -------------------------
REM Stop Frontend (port 5500)
REM -------------------------
echo.
echo [2/3] Stopping Frontend (port 5500)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5500 ^| findstr LISTENING') do (
    echo     Killing PID %%a
    taskkill /PID %%a /F >nul 2>&1
)

REM -------------------------
REM Stop Ollama (port 11434)
REM -------------------------
echo.
echo [3/3] Stopping Ollama (port 11434)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :11434 ^| findstr LISTENING') do (
    echo     Killing PID %%a
    taskkill /PID %%a /F >nul 2>&1
)

echo.
echo All services stopped.
echo.
pause
