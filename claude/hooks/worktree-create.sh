#!/bin/bash
# Custom WorktreeCreate hook: uses the worktree name as the branch name
# (instead of the default "worktree-<name>" prefix)
set -euo pipefail

INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name')
CWD=$(echo "$INPUT" | jq -r '.cwd')

DIR="$CWD/.worktrees/$NAME"
mkdir -p "$(dirname "$DIR")"

git worktree add -b "$NAME" "$DIR" HEAD >&2 2>&1 || {
  # Branch may already exist, try without -b
  git worktree add "$DIR" "$NAME" >&2 2>&1
}

echo "$DIR"
