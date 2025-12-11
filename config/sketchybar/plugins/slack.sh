#!/bin/sh

# Colors
NORMAL_COLOR="0x44FFFFFF"
NOTIFICATION_COLOR="0xFFFF9500"

# Path to Slack's storage directory - this is where notification data is stored
SLACK_DIR="$HOME/Library/Containers/com.tinyspeck.slackmacgap/Data/Library/Application Support/Slack"

# Function to count unread notifications
get_slack_notifications() {
  local unread_count=0
  local team_dirs

  # Check if Slack directory exists
  if [ -d "$SLACK_DIR" ]; then
    # Get all team directories
    team_dirs=$(find "$SLACK_DIR" -name "storage" -type d)

    for team_dir in $team_dirs; do
      if [ -f "$team_dir/slack-unread-counts" ]; then
        # Count mentions from the unread counts file
        local mentions=$(grep -o "\"mentions\":[0-9]*" "$team_dir/slack-unread-counts" | grep -o "[0-9]*")

        # Add any non-empty mentions to our count
        for count in $mentions; do
          if [ -n "$count" ] && [ "$count" -gt 0 ]; then
            unread_count=$((unread_count + count))
          fi
        done
      fi
    done
  fi

  echo "$unread_count"
}

# Get the notification count
NOTIFICATION_COUNT=$(get_slack_notifications)

# Set icon and color based on notification count
if [ "$NOTIFICATION_COUNT" -gt 0 ]; then
  sketchybar --set "$NAME" icon="" label="$NOTIFICATION_COUNT" icon.color="$NOTIFICATION_COLOR" label.color="$NOTIFICATION_COLOR"
else
  sketchybar --set "$NAME" icon="" label="" icon.color="$NORMAL_COLOR" label.color="$NORMAL_COLOR"
fi
