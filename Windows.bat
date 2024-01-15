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

REM Check if Love2D is installed in either path
set "loveExecutable=!loveInstallPath!\love.exe"

REM Run the game using the discovered Love2D executable
if exist "!loveExecutable!" (
    echo Running the game...
    start "" "!loveExecutable!" "%cd%"
) else (
    echo Error: Love2D executable not found.
)

endlocal
