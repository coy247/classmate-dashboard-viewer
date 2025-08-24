#!/bin/bash

# 🔄 REAL-TIME LOOP TRACKER
# Properly tracks and increments song plays in real-time

LOOP_STATE_FILE="$HOME/.loop_tracker_state.json"
LAST_POSITION_FILE="$HOME/.last_song_position.txt"
LOOP_LOG="$HOME/.loop_tracker.log"

# Initialize tracking
init_tracking() {
    if [ ! -f "$LOOP_STATE_FILE" ]; then
        echo '{}' > "$LOOP_STATE_FILE"
    fi
    echo "0" > "$LAST_POSITION_FILE"
}

# Get current song position in seconds
get_song_position() {
    osascript -e 'tell application "Music" to get player position' 2>/dev/null || echo "0"
}

# Get song duration
get_song_duration() {
    osascript -e 'tell application "Music" to get duration of current track' 2>/dev/null || echo "0"
}

# Track loops in real-time
track_loops() {
    # Get current song info
    local CURRENT_TRACK=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null)
    local CURRENT_ARTIST=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null)
    local REPEAT_MODE=$(osascript -e 'tell application "Music" to get song repeat' 2>/dev/null)
    local PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state as string' 2>/dev/null)
    
    if [ "$PLAYER_STATE" != "playing" ] || [ "$REPEAT_MODE" != "one" ]; then
        echo "Not tracking: Player $PLAYER_STATE, Repeat $REPEAT_MODE"
        return
    fi
    
    local SONG_KEY="${CURRENT_ARTIST}:::${CURRENT_TRACK}"
    local CURRENT_POSITION=$(get_song_position | cut -d'.' -f1)
    local DURATION=$(get_song_duration | cut -d'.' -f1)
    
    # Read last position
    local LAST_POSITION=$(cat "$LAST_POSITION_FILE" 2>/dev/null || echo "0")
    
    # Detect loop: position jumped back (song restarted)
    if [ "$CURRENT_POSITION" -lt "$LAST_POSITION" ] && [ "$LAST_POSITION" -gt $((DURATION - 5)) ]; then
        # Song looped! Increment counter
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOOP DETECTED: $SONG_KEY" >> "$LOOP_LOG"
        
        # Read current count
        local CURRENT_COUNT=$(jq -r ".\"$SONG_KEY\" // 0" "$LOOP_STATE_FILE")
        local NEW_COUNT=$((CURRENT_COUNT + 1))
        
        # Update count
        jq ".\"$SONG_KEY\" = $NEW_COUNT" "$LOOP_STATE_FILE" > "${LOOP_STATE_FILE}.tmp" && \
            mv "${LOOP_STATE_FILE}.tmp" "$LOOP_STATE_FILE"
        
        echo "🔄 Loop detected! $CURRENT_TRACK by $CURRENT_ARTIST - Play #$NEW_COUNT"
    fi
    
    # Save current position
    echo "$CURRENT_POSITION" > "$LAST_POSITION_FILE"
}

# Get current loop count for a song
get_loop_count() {
    local CURRENT_TRACK=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null)
    local CURRENT_ARTIST=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null)
    local SONG_KEY="${CURRENT_ARTIST}:::${CURRENT_TRACK}"
    
    local COUNT=$(jq -r ".\"$SONG_KEY\" // 0" "$LOOP_STATE_FILE" 2>/dev/null || echo "0")
    
    echo "$COUNT"
}

# Monitor continuously
continuous_monitor() {
    echo "🔄 Starting continuous loop monitoring..."
    echo "Tracking: $(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null)"
    
    while true; do
        track_loops
        sleep 2  # Check every 2 seconds
    done
}

# Get formatted status
get_status() {
    local CURRENT_TRACK=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null)
    local CURRENT_ARTIST=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null)
    local REPEAT_MODE=$(osascript -e 'tell application "Music" to get song repeat' 2>/dev/null)
    local COUNT=$(get_loop_count)
    
    if [ "$REPEAT_MODE" = "one" ] && [ "$COUNT" -gt 0 ]; then
        if [ "$COUNT" -gt 5000 ]; then
            echo "🎙️ HALL OF FAME! $CURRENT_ARTIST - $CURRENT_TRACK on REPEAT! Play #$COUNT!"
        elif [ "$COUNT" -gt 1000 ]; then
            echo "🔥 OBSESSION MODE! $CURRENT_ARTIST - $CURRENT_TRACK x${COUNT}!"
        elif [ "$COUNT" -gt 500 ]; then
            echo "🔁 LOOP CHAMPION! $CURRENT_ARTIST - $CURRENT_TRACK (${COUNT}x)"
        else
            echo "🎵 ON REPEAT: $CURRENT_ARTIST - $CURRENT_TRACK (#$COUNT)"
        fi
    else
        echo ""
    fi
}

# Main execution
case "${1:-status}" in
    init)
        init_tracking
        echo "Loop tracker initialized"
        ;;
    track)
        track_loops
        ;;
    monitor)
        continuous_monitor
        ;;
    count)
        get_loop_count
        ;;
    status)
        get_status
        ;;
    *)
        echo "Usage: $0 {init|track|monitor|count|status}"
        exit 1
        ;;
esac
