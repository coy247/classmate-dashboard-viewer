#!/bin/bash

# 🎵 APPLE MUSIC MONITOR FOR EPIC DASHBOARD
# Tracks repeat mode, current song, and play counts

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Session play count file
SESSION_FILE="/tmp/apple_music_session_$(date +%Y%m%d).json"
HISTORY_FILE="$HOME/.apple_music_play_history.json"

# Initialize session file if it doesn't exist
if [ ! -f "$SESSION_FILE" ]; then
    echo '{}' > "$SESSION_FILE"
fi

# Initialize history file if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
    echo '{}' > "$HISTORY_FILE"
fi

# Function to check if Apple Music is running
check_apple_music() {
    osascript -e 'tell application "System Events" to (name of processes) contains "Music"' 2>/dev/null
}

# Function to get current track info
get_current_track() {
    if [ "$(check_apple_music)" = "true" ]; then
        # Get track details
        TRACK_NAME=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null || echo "Unknown")
        ARTIST=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null || echo "Unknown")
        ALBUM=$(osascript -e 'tell application "Music" to get album of current track' 2>/dev/null || echo "Unknown")
        PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state as string' 2>/dev/null || echo "stopped")
        
        # Check repeat mode (returns "off", "one", or "all")
        REPEAT_MODE=$(osascript -e 'tell application "Music" to get song repeat as string' 2>/dev/null || echo "off")
        
        # Get play count from Music app
        MUSIC_PLAY_COUNT=$(osascript -e 'tell application "Music" to get played count of current track' 2>/dev/null || echo "0")
        
        # Create unique song ID
        SONG_ID="${ARTIST}_${TRACK_NAME}_${ALBUM}"
        SONG_ID=$(echo "$SONG_ID" | sed 's/[^a-zA-Z0-9_-]/_/g')
        
        echo "$TRACK_NAME|$ARTIST|$ALBUM|$PLAYER_STATE|$REPEAT_MODE|$MUSIC_PLAY_COUNT|$SONG_ID"
    else
        echo "NOT_RUNNING|||||"
    fi
}

# Function to update play counts
update_play_counts() {
    local song_id=$1
    local song_name=$2
    local artist=$3
    
    # Update session count
    SESSION_COUNT=$(jq -r ".\"$song_id\" // 0" "$SESSION_FILE")
    SESSION_COUNT=$((SESSION_COUNT + 1))
    jq ".\"$song_id\" = $SESSION_COUNT" "$SESSION_FILE" > "${SESSION_FILE}.tmp" && mv "${SESSION_FILE}.tmp" "$SESSION_FILE"
    
    # Update history count
    HISTORY_COUNT=$(jq -r ".\"$song_id\".total_plays // 0" "$HISTORY_FILE")
    HISTORY_COUNT=$((HISTORY_COUNT + 1))
    
    # Update history file with metadata
    jq ".\"$song_id\" = {
        \"name\": \"$song_name\",
        \"artist\": \"$artist\",
        \"total_plays\": $HISTORY_COUNT,
        \"last_played\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
        \"first_played\": (.\"$song_id\".first_played // \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\")
    }" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
    
    echo "$SESSION_COUNT|$HISTORY_COUNT"
}

# Function to generate sports announcer commentary for music
generate_music_commentary() {
    local track_name=$1
    local artist=$2
    local repeat_mode=$3
    local session_plays=$4
    local total_plays=$5
    
    if [ "$repeat_mode" = "one" ]; then
        if [ "$total_plays" -gt 5000 ]; then
            echo "🎙️ LEGENDARY STATUS! $artist - $track_name on INFINITE REPEAT! Play #$session_plays this session, #$total_plays ALL-TIME! This is HALL OF FAME dedication!"
        elif [ "$total_plays" -gt 1000 ]; then
            echo "🔥 OBSESSION LEVEL: MAXIMUM! $artist - $track_name LOCKED IN! Session play #$session_plays of LIFETIME #$total_plays! THE CROWD KNOWS EVERY WORD!"
        elif [ "$total_plays" -gt 100 ]; then
            echo "🎵 REPEAT CHAMPION! $artist - $track_name spinning for the ${session_plays}th time today! Career plays: $total_plays - FAN FAVORITE!"
        else
            echo "🎯 REPEAT MODE ENGAGED! $artist - $track_name on loop! Play #$session_plays this session (Total: $total_plays)"
        fi
    else
        if [ "$total_plays" -gt 100 ]; then
            echo "🎶 CROWD PLEASER! $artist - $track_name returns! Lifetime spins: $total_plays"
        else
            echo "🎵 Now playing: $artist - $track_name (Play count: $total_plays)"
        fi
    fi
}

# Main monitoring function
monitor_apple_music() {
    echo -e "${CYAN}🎵 Apple Music Monitor Active${NC}"
    
    # Check if Apple Music is running
    if [ "$(check_apple_music)" = "false" ]; then
        echo "Apple Music is not running"
        return
    fi
    
    # Get current track info
    IFS='|' read -r TRACK_NAME ARTIST ALBUM PLAYER_STATE REPEAT_MODE MUSIC_PLAY_COUNT SONG_ID <<< "$(get_current_track)"
    
    if [ "$PLAYER_STATE" = "playing" ]; then
        # Get play counts
        SESSION_COUNT=$(jq -r ".\"$SONG_ID\" // 0" "$SESSION_FILE")
        HISTORY_COUNT=$(jq -r ".\"$SONG_ID\".total_plays // 0" "$HISTORY_FILE")
        
        # If Music app has play count, use it as minimum
        if [ "$MUSIC_PLAY_COUNT" -gt "$HISTORY_COUNT" ]; then
            HISTORY_COUNT=$MUSIC_PLAY_COUNT
        fi
        
        echo -e "${GREEN}▶️  Currently Playing:${NC}"
        echo "   Artist: $ARTIST"
        echo "   Track: $TRACK_NAME"
        echo "   Album: $ALBUM"
        echo "   Repeat Mode: $REPEAT_MODE"
        echo "   Session Plays: $SESSION_COUNT"
        echo "   Total Plays: $HISTORY_COUNT"
        
        # Generate commentary
        COMMENTARY=$(generate_music_commentary "$TRACK_NAME" "$ARTIST" "$REPEAT_MODE" "$SESSION_COUNT" "$HISTORY_COUNT")
        echo -e "\n${MAGENTA}$COMMENTARY${NC}"
        
        # Return JSON for integration
        cat << EOF
{
  "apple_music": {
    "status": "playing",
    "track": "$TRACK_NAME",
    "artist": "$ARTIST",
    "album": "$ALBUM",
    "repeat_mode": "$REPEAT_MODE",
    "session_plays": $SESSION_COUNT,
    "total_plays": $HISTORY_COUNT,
    "commentary": "$COMMENTARY"
  }
}
EOF
    else
        echo "Apple Music is $PLAYER_STATE"
        echo '{"apple_music": {"status": "'$PLAYER_STATE'"}}'
    fi
}

# Track current song (call this periodically to increment play count)
track_current_song() {
    if [ "$(check_apple_music)" = "true" ]; then
        IFS='|' read -r TRACK_NAME ARTIST ALBUM PLAYER_STATE REPEAT_MODE MUSIC_PLAY_COUNT SONG_ID <<< "$(get_current_track)"
        
        if [ "$PLAYER_STATE" = "playing" ] && [ -n "$SONG_ID" ]; then
            # Check if this is a new play (simple check - could be enhanced)
            LAST_TRACKED="/tmp/last_tracked_song.txt"
            if [ -f "$LAST_TRACKED" ]; then
                LAST_SONG=$(cat "$LAST_TRACKED")
                if [ "$LAST_SONG" != "$SONG_ID" ]; then
                    # New song, increment play count
                    update_play_counts "$SONG_ID" "$TRACK_NAME" "$ARTIST"
                    echo "$SONG_ID" > "$LAST_TRACKED"
                fi
            else
                # First track of session
                update_play_counts "$SONG_ID" "$TRACK_NAME" "$ARTIST"
                echo "$SONG_ID" > "$LAST_TRACKED"
            fi
        fi
    fi
}

# Export data for dashboard
export_for_dashboard() {
    monitor_apple_music > apple_music_status.json
}

# Main execution
case "${1:-monitor}" in
    monitor)
        monitor_apple_music
        ;;
    track)
        track_current_song
        ;;
    export)
        export_for_dashboard
        ;;
    *)
        echo "Usage: $0 {monitor|track|export}"
        exit 1
        ;;
esac
