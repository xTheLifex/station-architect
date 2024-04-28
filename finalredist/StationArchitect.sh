#!/bin/bash

# Check if the "love" package is installed
if ! command -v love &> /dev/null; then
    # Install Love2D
    sudo apt-get update
    sudo apt-get install -y love
fi

love StationArchitect.exe