#!/bin/bash

# Script to set initial count for El Sonidito
# This preserves your historical play count

LOOP_STATE_FILE="$HOME/.loop_tracker_state.json"
SONG_KEY="Hechizeros Band:::El Sonidito"
INITIAL_COUNT=1283

echo "Setting initial count for El Sonidito to $INITIAL_COUNT..."

# Create state file if it doesn't exist
if [ ! -f "$LOOP_STATE_FILE" ]; then
    echo '{}' > "$LOOP_STATE_FILE"
fi

# Set the initial count
jq ".\"$SONG_KEY\" = $INITIAL_COUNT" "$LOOP_STATE_FILE" > "${LOOP_STATE_FILE}.tmp" && \
    mv "${LOOP_STATE_FILE}.tmp" "$LOOP_STATE_FILE"

echo "✅ Initial count set successfully!"
echo "Current state:"
jq . "$LOOP_STATE_FILE"
