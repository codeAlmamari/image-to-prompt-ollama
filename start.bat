@echo off
setlocal enabledelayedexpansion

REM =========================
REM Config
REM =========================
set BACKEND_PORT=8000
set FRONTEND_PORT=5500
set BACKEND_DIR=%~dp0backend
set FRONTEND_DIR=%~dp0frontend

echo.
echo ==========================================
echo   Starting Image->Prompt App (Ollama+LLaVA)
echo ==========================================
echo.

REM =========================
REM 1) Start Ollama server (if not already)
REM =========================
echo [1/4] Checking Ollama...
powershell -NoProfile -Command "try { $r = Invoke-WebRequest -UseBasicParsing http://localhost:11434 -TimeoutSec 2; exit 0 } catch { exit 1 }"
if %errorlevel%==0 (
  echo     Ollama is already running.
) else (
  echo     Ollama not running. Starting 'ollama serve'...
  start "Ollama Server" cmd /k "ollama serve"
  echo     Waiting 3 seconds...
  timeout /t 3 /nobreak >nul
)

REM =========================
REM 2) Start Backend (FastAPI)
REM =========================
echo.
echo [2/4] Starting Backend on http://127.0.0.1:%BACKEND_PORT% ...
if not exist "%BACKEND_DIR%\main.py" (
  echo     ERROR: backend\main.py not found.
  pause
  exit /b 1
)

if not exist "%BACKEND_DIR%\.venv\Scripts\python.exe" (
  echo     ERROR: backend\.venv not found. Create venv first:
  echo     cd backend ^& python -m venv .venv ^& .\.venv\Scripts\pip install -r requirements.txt
  pause
  exit /b 1
)

start "Backend (Uvicorn)" cmd /k ^
  "cd /d "%BACKEND_DIR%" && ^
   .\.venv\Scripts\python -m uvicorn main:app --reload --port %BACKEND_PORT%"

REM =========================
REM 3) Start Frontend (HTTP Server)
REM =========================
echo.
echo [3/4] Starting Frontend on http://localhost:%FRONTEND_PORT% ...
if not exist "%FRONTEND_DIR%\index.html" (
  echo     ERROR: frontend\index.html not found.
  pause
  exit /b 1
)

start "Frontend (http.server)" cmd /k ^
  "cd /d "%FRONTEND_DIR%" && python -m http.server %FRONTEND_PORT%"

REM =========================
REM 4) Open Browser
REM =========================
echo.
echo [4/4] Opening browser...
timeout /t 2 /nobreak >nul
start "" "http://localhost:%FRONTEND_PORT%"

echo.
echo Done. Close the opened terminal windows to stop services.
echo.
endlocal
