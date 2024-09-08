@echo off
setlocal enabledelayedexpansion

REM Check system architecture
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set "arch=64"
) else (
    set "arch=32"
)

REM Set Love2D version
set "love_version=11.5"

REM Set installation paths
set "loveInstallPath=C:\Program Files\LOVE"
if !arch! equ 32 set "loveInstallPath=C:\Program Files (x86)\LOVE"

REM Check if Love2D is installed in the standard installation paths
set "loveExecutable=!loveInstallPath!\love.exe"

REM Run the game using the discovered Love2D executable
if exist "!loveExecutable!" (
    echo Running the game...
    start "" "!loveExecutable!" "%cd%"
) else (
    REM If not found, check if Scoop is installed
    where scoop >nul 2>nul
    if %errorlevel% neq 0 (
        echo Error: Love2D executable not found locally, and Scoop is not installed.
        pause >nul
        exit
    )

    REM Check if Love2D is installed via Scoop
    scoop list love >nul 2>nul
    if %errorlevel% neq 0 (
        echo Love2D not found via Scoop. Installing Love2D...
        scoop install love
    ) else (
        echo Love2D found via Scoop.
    )

    REM Run the game using Scoop-installed Love2D
    echo Running the game using Scoop Love2D...
    REM C:\Users\(USER)\scoop\apps\love\current 
    call "%HOMEDRIVE%%HOMEPATH%\scoop\apps\love\current\love.exe" "%cd%"
)

endlocal
