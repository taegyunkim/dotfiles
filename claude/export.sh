#!/usr/bin/env zsh
# Export live Claude Code plugin state back into dotfiles source files.
# Base dotfiles keep personal/default plugins; work dotfiles keep work marketplaces/plugins.

set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/.dotfiles/claude}"
WORK_DIR="${WORK_DIR:-$HOME/.dotfiles-work/claude}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
DISABLED_WORK_PLUGINS='["slack@claude-plugins-official"]'

SETTINGS_FILE="$CLAUDE_DIR/settings.json"
INSTALLED_PLUGINS_FILE="$CLAUDE_DIR/plugins/installed_plugins.json"
KNOWN_MARKETPLACES_FILE="$CLAUDE_DIR/plugins/known_marketplaces.json"
BASE_SETTINGS_FILE="$BASE_DIR/settings.json"
WORK_ENABLED_PLUGINS_FILE="$WORK_DIR/enabled_plugins.json"
WORK_INSTALLED_PLUGINS_FILE="$WORK_DIR/installed_plugins.json"
WORK_KNOWN_MARKETPLACES_FILE="$WORK_DIR/known_marketplaces.json"

for file in "$SETTINGS_FILE" "$INSTALLED_PLUGINS_FILE" "$KNOWN_MARKETPLACES_FILE"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required Claude runtime file: $file" >&2
    exit 1
  fi
done

mkdir -p "$BASE_DIR"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

work_marketplaces_keys_file="$tmp_dir/work-marketplaces-keys.json"
if [[ -f "$WORK_KNOWN_MARKETPLACES_FILE" ]]; then
  jq -S 'keys' "$WORK_KNOWN_MARKETPLACES_FILE" > "$work_marketplaces_keys_file"
else
  printf '[]\n' > "$work_marketplaces_keys_file"
fi

if [[ -f "$BASE_SETTINGS_FILE" ]]; then
  jq -S \
    --slurpfile live "$SETTINGS_FILE" \
    --slurpfile work_marketplaces "$work_marketplaces_keys_file" \
    '.enabledPlugins = (
      ($live[0].enabledPlugins // {})
      | with_entries(
          select((.key | split("@") | last) as $marketplace | ($work_marketplaces[0] | index($marketplace) | not))
        )
    )' \
    "$BASE_SETTINGS_FILE" \
    > "$tmp_dir/base-settings.json"
else
  jq -S \
    --slurpfile work_marketplaces "$work_marketplaces_keys_file" \
    '.enabledPlugins = (
      (.enabledPlugins // {})
      | with_entries(
          select((.key | split("@") | last) as $marketplace | ($work_marketplaces[0] | index($marketplace) | not))
        )
    )' \
    "$SETTINGS_FILE" \
    > "$tmp_dir/base-settings.json"
fi

jq -S \
  --slurpfile work_marketplaces "$work_marketplaces_keys_file" \
  --argjson disabled "$DISABLED_WORK_PLUGINS" \
  '(.enabledPlugins // {})
   | with_entries(
       select(
         (.key | split("@") | last) as $marketplace
         | ($work_marketplaces[0] | index($marketplace))
         and (.key as $key | ($disabled | index($key) | not))
       )
     )' \
  "$SETTINGS_FILE" \
  > "$tmp_dir/work-enabled-plugins.json"

jq -S \
  --slurpfile work_marketplaces "$work_marketplaces_keys_file" \
  '{version: (.version // 2), plugins: (
    (.plugins // {})
    | with_entries(
        select((.key | split("@") | last) as $marketplace | ($work_marketplaces[0] | index($marketplace) | not))
      )
  )}' \
  "$INSTALLED_PLUGINS_FILE" \
  > "$tmp_dir/base-installed-plugins.json"

jq -S \
  --slurpfile work_marketplaces "$work_marketplaces_keys_file" \
  --argjson disabled "$DISABLED_WORK_PLUGINS" \
  '(.plugins // {})
   | with_entries(
       select(
         (.key | split("@") | last) as $marketplace
         | ($work_marketplaces[0] | index($marketplace))
         and (.key as $key | ($disabled | index($key) | not))
       )
     )' \
  "$INSTALLED_PLUGINS_FILE" \
  > "$tmp_dir/work-installed-plugins.json"

jq -S \
  --slurpfile work_marketplaces "$work_marketplaces_keys_file" \
  'with_entries(
     select(.key as $marketplace | ($work_marketplaces[0] | index($marketplace) | not))
   )
   | with_entries(.value.lastUpdated = (.value.lastUpdated // (now | strftime("%Y-%m-%dT%H:%M:%SZ"))))' \
  "$KNOWN_MARKETPLACES_FILE" \
  > "$tmp_dir/base-known-marketplaces.json"

jq -S \
  --slurpfile work_marketplaces "$work_marketplaces_keys_file" \
  'with_entries(
     select(.key as $marketplace | ($work_marketplaces[0] | index($marketplace)))
   )
   | with_entries(.value.lastUpdated = (.value.lastUpdated // (now | strftime("%Y-%m-%dT%H:%M:%SZ"))))' \
  "$KNOWN_MARKETPLACES_FILE" \
  > "$tmp_dir/work-known-marketplaces.json"

mv "$tmp_dir/base-settings.json" "$BASE_SETTINGS_FILE"
mv "$tmp_dir/base-installed-plugins.json" "$BASE_DIR/installed_plugins.json"
mv "$tmp_dir/base-known-marketplaces.json" "$BASE_DIR/known_marketplaces.json"
echo "Exported base Claude plugin state to $BASE_DIR"

if [[ -d "$WORK_DIR" || -f "$WORK_ENABLED_PLUGINS_FILE" || -f "$WORK_INSTALLED_PLUGINS_FILE" || -f "$WORK_KNOWN_MARKETPLACES_FILE" ]]; then
  mkdir -p "$WORK_DIR"
  mv "$tmp_dir/work-enabled-plugins.json" "$WORK_ENABLED_PLUGINS_FILE"
  mv "$tmp_dir/work-installed-plugins.json" "$WORK_INSTALLED_PLUGINS_FILE"
  mv "$tmp_dir/work-known-marketplaces.json" "$WORK_KNOWN_MARKETPLACES_FILE"
  echo "Exported work Claude plugin state to $WORK_DIR"
else
  rm -f "$tmp_dir/work-enabled-plugins.json" "$tmp_dir/work-installed-plugins.json" "$tmp_dir/work-known-marketplaces.json"
  echo "No work Claude overlay detected; skipped work export"
fi
