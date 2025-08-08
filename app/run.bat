@echo off
SETLOCAL EnableExtensions EnableDelayedExpansion
REM AI Hedge Fund Web Application Setup and Runner (Windows)

REM Check Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install from https://nodejs.org/
    pause
    exit /b 1
)

REM Check npm
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed. Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    where python3 >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Python is not installed. Please install from https://python.org/
        pause
        exit /b 1
    )
)

REM Check Poetry
where poetry >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Poetry is not installed.
    echo [INFO] Poetry is required to manage Python dependencies.
    echo.
    set /p install_poetry="Would you like to install Poetry automatically? (y/N): "
    if /i "%install_poetry%"=="y" (
        echo [INFO] Installing Poetry...
        python -m pip install poetry
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to install Poetry automatically.
            echo [ERROR] Please install Poetry manually from https://python-poetry.org/
            pause
            exit /b 1
        )
        echo [SUCCESS] Poetry installed successfully.
        call refreshenv >nul 2>&1 || echo [WARNING] Could not refresh environment. Restart terminal.
    ) else (
        echo [ERROR] Poetry is required to run this application.
        echo [ERROR] Please install Poetry from https://python-poetry.org/
        pause
        exit /b 1
    )
)

REM Ensure correct directory
if not exist "frontend" (
    echo [ERROR] This script must be run from the app\ directory
    pause
    exit /b 1
)

if not exist "backend" (
    echo [ERROR] This script must be run from the app\ directory
    pause
    exit /b 1
)

echo.
echo [INFO] AI Hedge Fund Web Application Setup
echo [INFO] This script will install dependencies and start both frontend and backend services
echo.

REM Check for .env
if not exist "..\.env" (
    if exist "..\.env.example" (
        echo [WARNING] No .env file found. Creating from .env.example...
        copy "..\.env.example" "..\.env"
        echo [WARNING] Please edit ..\.env to add your API keys.
    ) else (
        echo [ERROR] No .env or .env.example file found.
        echo [ERROR] Please create a .env file with your API keys.
        pause
        exit /b 1
    )
) else (
    echo [SUCCESS] .env file found.
)

REM Backend setup
echo [INFO] Installing backend dependencies...
cd backend

poetry check >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Backend dependencies already installed.
) else (
    echo [INFO] Installing backend dependencies...
    poetry install
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install backend dependencies.
        pause
        exit /b 1
    )
    echo [SUCCESS] Backend dependencies installed.
)

cd ..

REM Frontend setup
echo [INFO] Installing frontend dependencies...
cd frontend

if exist "node_modules" (
    echo [SUCCESS] Frontend dependencies already installed.
) else (
    echo [INFO] Installing frontend dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install frontend dependencies.
        pause
        exit /b 1
    )
    echo [SUCCESS] Frontend dependencies installed.
)

cd ..

REM Launch backend
echo [INFO] Starting backend server...
cd ..
start /b poetry run uvicorn app.backend.main:app --reload --host 127.0.0.1 --port 8000
cd app

timeout /t 3 /nobreak >nul

REM Launch frontend
echo [INFO] Starting frontend dev server...
cd frontend
start /b npm run dev
cd ..

timeout /t 5 /nobreak >nul

REM Open browser
echo [INFO] Opening in browser...
timeout /t 2 /nobreak >nul
start http://localhost:5173

echo.
echo [SUCCESS] AI Hedge Fund web app is now running!
echo [INFO] Frontend: http://localhost:5173
echo [INFO] Backend:  http://localhost:8000
echo [INFO] Docs:     http://localhost:8000/docs
echo.
echo [INFO] Press any key to stop services...
pause >nul

REM Stop services
taskkill /f /im "uvicorn.exe" >nul 2>&1
taskkill /f /im "node.exe" >nul 2>&1

echo [SUCCESS] Services stopped. Goodbye!
pause
