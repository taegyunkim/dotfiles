#!/bin/bash
# Custom WorktreeRemove hook: cleans up worktree created by worktree-create.sh
set -euo pipefail

INPUT=$(cat)
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path')

if [ -d "$WORKTREE_PATH" ]; then
  git worktree remove "$WORKTREE_PATH" --force >&2 2>&1
fi
