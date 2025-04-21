#!/bin/bash

# Ensure hooks directory exists
mkdir -p .git/hooks

# link the prepare-commit-msg hook
ln -s .git-hooks/prepare-commit-msg .git/hooks/prepare-commit-msg

echo "[setup] Hook installed to .git/hooks/prepare-commit-msg"
