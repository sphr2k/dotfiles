#!/usr/bin/env bash

set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found, skipping brew bundle"
  exit 0
fi

BREWFILE_PATH="$(chezmoi source-path Brewfile)"
brew bundle --file "$BREWFILE_PATH"
