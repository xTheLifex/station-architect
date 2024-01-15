#!/bin/bash

# Check if the "love" package is installed
if ! command -v love &> /dev/null; then
    echo "Love2D not found. Installing..."
    
    # Install Love2D
    sudo apt-get update
    sudo apt-get install -y love

    echo "Love2D installed successfully."
fi

echo Love2D Found. Launching...
# Run the game using Love2D
love "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
sleep 3
