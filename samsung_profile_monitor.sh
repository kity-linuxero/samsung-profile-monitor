#!/bin/bash

# Path to the file containing the current state
PROFILE_FILE="/sys/firmware/acpi/platform_profile"

ICON_DIR="/usr/share/icons/platform_profile"

# Icons associated with each profile
ICON_LOW="$ICON_DIR/0.png"
ICON_QUIET="$ICON_DIR/1.png"
ICON_BALANCED="$ICON_DIR/2.png"
ICON_PERFORMANCE="$ICON_DIR/3.png"


# Function to get the current state
get_current_profile() {
    cat "$PROFILE_FILE" 2>/dev/null
}

# Function to send OSD type notification
send_notification() {
    local profile="$1"
    local icon=""
    
    case "$profile" in
        low-power) icon="$ICON_LOW" ;;
        quiet) icon="$ICON_QUIET" ;;
        balanced) icon="$ICON_BALANCED" ;;
        performance) icon="$ICON_PERFORMANCE" ;;
    esac
    
    gdbus call --session --dest org.freedesktop.Notifications \
               --object-path /org/freedesktop/Notifications \
               --method org.freedesktop.Notifications.Notify \
               "SamsungPlatformProfile" 0 "$icon" "" "Mode: ${profile^^}" [] {} 1200
}

# Get the initial status and report it
previous_profile=$(get_current_profile)
if [ -n "$previous_profile" ]; then
    send_notification "$previous_profile"
fi

# Monitor file changes
while inotifywait -q -e modify "$PROFILE_FILE"; do
    current_profile=$(get_current_profile)
    if [ "$current_profile" != "$previous_profile" ]; then
        send_notification "$current_profile"
        previous_profile="$current_profile"
    fi
done
