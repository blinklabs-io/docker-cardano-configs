#!/bin/sh
# Check if target directory is provided as first argument
if [ $# -eq 0 ]; then
    echo "Error: No target directory specified"
    echo "Usage: docker run <image> <target-directory> [network]"
    echo "Example: docker run cardano-configs /host/configs mainnet"
    exit 1
fi

TARGET_DIR="$1"
NETWORK="$2"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# If network is specified, copy only that network's configs
if [ -n "$NETWORK" ]; then
    if [ -d "/config/$NETWORK" ]; then
        echo "Copying $NETWORK configuration files to $TARGET_DIR"
        mkdir -p "$TARGET_DIR/$NETWORK"
        cp -r "/config/$NETWORK"/* "$TARGET_DIR/$NETWORK/" || exit 1
    else
        echo "Error: Network '$NETWORK' not found"
        echo "Available networks:"
        ls /config/
        exit 1
    fi
else
    # No network specified, copy all configs
    echo "Copying all configuration files to $TARGET_DIR"
    cp -r /config/* "$TARGET_DIR/" || exit 1
fi

# Verify that files were actually copied
if [ "$(ls -A "$TARGET_DIR")" ]; then
    echo "Configuration files copied successfully"
else
    echo "Error: No files were copied"
    exit 1
fi