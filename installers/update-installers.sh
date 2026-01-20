#!/bin/bash

# Script to rebuild dfsetup.run from source files using makeself

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAKESELF_RUN="$SCRIPT_DIR/makeself.run"
SOURCE_DIR="$SCRIPT_DIR/source"
OUTPUT_FILE="$SCRIPT_DIR/dfsetup.run"
TEMP_DIR=$(mktemp -d)

# Check if makeself.run exists
if [[ ! -f "$MAKESELF_RUN" ]]; then
    echo "Error: makeself.run not found in $SCRIPT_DIR"
    exit 1
fi

# Check if source directory exists
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: source directory not found in $SCRIPT_DIR"
    exit 1
fi

echo "Extracting makeself..."
"$MAKESELF_RUN" --target "$TEMP_DIR" > /dev/null 2>&1

if [[ ! -f "$TEMP_DIR/makeself.sh" ]]; then
    echo "Error: Failed to extract makeself"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Building dfsetup.run..."
"$TEMP_DIR/makeself.sh" "$SOURCE_DIR" "$OUTPUT_FILE" "DreamFactory Installer" ./setup.sh

if [[ $? -eq 0 ]]; then
    echo "Successfully updated $OUTPUT_FILE"
else
    echo "Error: Failed to create dfsetup.run"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "Done!"
