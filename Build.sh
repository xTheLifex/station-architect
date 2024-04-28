#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
if [ -e Engine/version.txt ]; then
    current_version=$(cat Engine/version.txt)
else
    current_version=0
fi
new_version=$((current_version + 1))

echo "1. Starting build..."
echo " "

echo $new_version > Engine/version.txt # Increase version on file.
echo "Version $GREEN[$new_version]."

echo Downloading love executable...
wget https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.zip
unzip love-11.5-win64.zip
mv love-11.5-win64 love

echo "2. Writing executable..."
echo " "

zip -9 -r StationArchitect.love Engine
zip -9 -r StationArchitect.love main.lua
zip -9 -r StationArchitect.love conf.lua

cat love/love.exe StationArchitect.love > StationArchitect.exe

echo "3. Packaging..."
echo " "

mkdir builds
mkdir builds/$new_version
destination=builds/$new_version

cp -ra Game $destination/Game
mv StationArchitect.exe $destination/StationArchitect.exe
mv love/OpenAL32.dll $destination/OpenAL32.dll
mv love/SDL2.dll $destination/SDL2.dll
mv love/lua51.dll $destination/lua51.dll
mv love/mpg123.dll $destination/mpg123.dll
mv love/msvcp120.dll $destination/msvcp120.dll
mv love/msvcr120.dll $destination/msvcr120.dll
mv love/love.dll $destination/love.dll

cp -ra redist/. $destination/

chmod +x $destination/StationArchitect.sh

echo "4. Cleaning up..."
echo " "

rm -r love
rm StationArchitect.love
rm -r love-11.5-win64
rm love-11.5-win64.zip

echo "@ Build complete."