#!/bin/bash

# Ensure hooks directory exists
mkdir -p .git/hooks

# Copy the prepare-commit-msg hook
cp .git-hooks/prepare-commit-msg .git/hooks/prepare-commit-msg
chmod +x .git/hooks/prepare-commit-msg

echo "[setup] Hook installed to .git/hooks/prepare-commit-msg"
