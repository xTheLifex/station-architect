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

REM Check if Love2D is already installed
set "loveExecutable=!loveInstallPath!\love.exe"
set "loveInstalled=false"

if exist "!loveExecutable!" (
    set "loveInstalled=true"
)

REM Install Love2D if not already installed
if not !loveInstalled! (
    echo Installing Love2D v11.5 ...
    
    set "installerUrl=https://github.com/love2d/love/releases/download/%love_version%/love-%love_version%-win64.zip"
    if !arch! equ 32 set "installerUrl=https://github.com/love2d/love/releases/download/%love_version%/love-%love_version%-win32.zip"
    
    set "installPath=%TEMP%\Love2D"

    mkdir "!installPath!" 2>nul
    cd "!installPath!"

    REM Download and unzip Love2D
    bitsadmin.exe /transfer "Love2DInstaller" "!installerUrl!" "!installPath!\love.zip"
    powershell Expand-Archive -Path "!installPath!\love.zip" -DestinationPath "!installPath!\"

    REM Move Love2D to the installation path and rename the folder
    move "!installPath!\love-!love_version!-win!arch!" "!loveInstallPath!"

    set "loveInstalled=true"
    echo Love2D installed successfully.
)

REM Run the game using the discovered Love2D executable
if exist "!loveExecutable!" (
    echo Running the game...
    "!loveExecutable%" "%cd%"
) else (
    echo Error: Love2D executable not found.
)

endlocal
