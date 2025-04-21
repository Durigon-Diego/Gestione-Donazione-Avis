#!/bin/bash

# Ensure hooks directory exists
mkdir -p .git/hooks

# Link the pre-commit hook
TARGET_HOOK=".git/hooks/pre-commit"
SOURCE_HOOK="../../.git-hooks/pre-commit"

# Remove existing file or symlink
if [ -e "$TARGET_HOOK" ] || [ -L "$TARGET_HOOK" ]; then
    rm -f "$TARGET_HOOK"
fi

ln -s "$SOURCE_HOOK" "$TARGET_HOOK"
echo "[setup] Hook installed to $TARGET_HOOK"
