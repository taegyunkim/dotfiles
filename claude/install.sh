#!/usr/bin/env zsh
# Install Claude Code configuration
# Merges base (~/.dotfiles/claude) and optional work (~/.dotfiles-work/claude) configs

set -euo pipefail

BASE_DIR="$HOME/.dotfiles/claude"
WORK_DIR="$HOME/.dotfiles-work/claude"
CLAUDE_DIR="$HOME/.claude"
DISABLED_WORK_PLUGINS='["slack@claude-plugins-official"]'

mkdir -p "$CLAUDE_DIR/plugins"

# Symlink commands and hooks directories
ln -nfs "$BASE_DIR/commands" "$CLAUDE_DIR/commands"
ln -nfs "$BASE_DIR/hooks" "$CLAUDE_DIR/hooks"

# Merge settings.json: add work enabledPlugins if available
if [[ -f "$WORK_DIR/enabled_plugins.json" ]]; then
  jq -s --argjson disabled "$DISABLED_WORK_PLUGINS" \
    '.[0] as $base
     | .[1] as $work
     | $base * {
         enabledPlugins: (
           $base.enabledPlugins
           + ($work | with_entries(select(.key as $key | ($disabled | index($key) | not))))
         )
       }' \
    "$BASE_DIR/settings.json" "$WORK_DIR/enabled_plugins.json" \
    > "$CLAUDE_DIR/settings.json"
  echo "Merged settings.json (base + work plugins)"
else
  cp "$BASE_DIR/settings.json" "$CLAUDE_DIR/settings.json"
  echo "Copied settings.json (base only)"
fi

# Merge installed_plugins.json (rewrite installPath to current $HOME)
if [[ -f "$WORK_DIR/installed_plugins.json" ]]; then
  jq -s --arg home "$HOME" --argjson disabled "$DISABLED_WORK_PLUGINS" \
    '.[0] as $base
     | .[1] as $work
     | $base * {
         plugins: (
           $base.plugins
           + ($work | with_entries(select(.key as $key | ($disabled | index($key) | not))))
         )
       }
     | walk(if type == "string" and test("/Users/[^/]+/\\.claude/") then sub("/Users/[^/]+/\\.claude/"; $home + "/.claude/") else . end)' \
    "$BASE_DIR/installed_plugins.json" "$WORK_DIR/installed_plugins.json" \
    > "$CLAUDE_DIR/plugins/installed_plugins.json"
  echo "Merged installed_plugins.json (base + work)"
else
  jq --arg home "$HOME" \
    'walk(if type == "string" and test("/Users/[^/]+/\\.claude/") then sub("/Users/[^/]+/\\.claude/"; $home + "/.claude/") else . end)' \
    "$BASE_DIR/installed_plugins.json" \
    > "$CLAUDE_DIR/plugins/installed_plugins.json"
  echo "Copied installed_plugins.json (base only)"
fi

# Merge known_marketplaces.json (rewrite installLocation to current $HOME)
# Claude expects each marketplace entry to carry a lastUpdated timestamp.
if [[ -f "$WORK_DIR/known_marketplaces.json" ]]; then
  jq -s --arg home "$HOME" \
    '.[0] + .[1]
     | walk(if type == "string" and test("/Users/[^/]+/\\.claude/") then sub("/Users/[^/]+/\\.claude/"; $home + "/.claude/") else . end)
     | with_entries(.value.lastUpdated = (.value.lastUpdated // (now | strftime("%Y-%m-%dT%H:%M:%SZ"))))' \
    "$BASE_DIR/known_marketplaces.json" "$WORK_DIR/known_marketplaces.json" \
    > "$CLAUDE_DIR/plugins/known_marketplaces.json"
  echo "Merged known_marketplaces.json (base + work)"
else
  jq --arg home "$HOME" \
    'walk(if type == "string" and test("/Users/[^/]+/\\.claude/") then sub("/Users/[^/]+/\\.claude/"; $home + "/.claude/") else . end)
     | with_entries(.value.lastUpdated = (.value.lastUpdated // (now | strftime("%Y-%m-%dT%H:%M:%SZ"))))' \
    "$BASE_DIR/known_marketplaces.json" \
    > "$CLAUDE_DIR/plugins/known_marketplaces.json"
  echo "Copied known_marketplaces.json (base only)"
fi

echo "Claude Code configuration installed."
