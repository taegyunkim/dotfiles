#!/bin/bash
# ~/.claude/scripts/notify.sh
# Notification hook for Claude Code

# Read hook input data from standard input
INPUT=$(cat)

# Get current session directory name (hooks run in the same directory as the session)
SESSION_DIR=$(basename "$(pwd)")

# Extract notification fields
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // "general"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Notification from Claude Code"')
TITLE=$(echo "$INPUT" | jq -r '.title // "ClaudeCode"')

# Truncate message to 100 characters and replace newlines with spaces
MESSAGE_CLEAN=$(echo "$MESSAGE" | tr '\n' ' ' | cut -c1-100)

# Map notification types to more readable display names
case "$NOTIFICATION_TYPE" in
    "permission_prompt")
        DISPLAY_TITLE="$TITLE - Permission Needed ($SESSION_DIR)"
        SOUND="Tink"
        ;;
    "idle_prompt")
        DISPLAY_TITLE="$TITLE - Idle ($SESSION_DIR)"
        SOUND="Purr"
        ;;
    "auth_success")
        DISPLAY_TITLE="$TITLE - Auth Success ($SESSION_DIR)"
        SOUND="Glass"
        ;;
    "elicitation_dialog")
        DISPLAY_TITLE="$TITLE - Question ($SESSION_DIR)"
        SOUND="Pop"
        ;;
    *)
        DISPLAY_TITLE="$TITLE ($SESSION_DIR)"
        SOUND="Default"
        ;;
esac

# Display macOS notification with sound
# Try to use terminal-notifier if available (allows specifying which app to activate)
if command -v terminal-notifier &> /dev/null; then
    terminal-notifier -message "$MESSAGE_CLEAN" -title "$DISPLAY_TITLE" -sound "$SOUND" -activate "com.mitchellh.ghostty"
else
    # Fallback to osascript (will open Script Editor on click)
    osascript -e "display notification \"$MESSAGE_CLEAN\" with title \"$DISPLAY_TITLE\" sound name \"$SOUND\""
fi
