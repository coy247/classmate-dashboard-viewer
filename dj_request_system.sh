#!/bin/bash

# 🎵 PANTHER PRIDE DJ REQUEST SYSTEM 🎵
# Gia & Melissa's Open Bar - DJ Request Queue Manager
# Handles Apple Music requests with state management

REQUEST_QUEUE="$HOME/.dj_request_queue.json"
REQUEST_LOG="$HOME/.dj_requests.log"
BANNED_SONGS="$HOME/.banned_music.txt"
ALLOWED_SONGS="$HOME/.allowed_music.txt"
BAR_STATE="$HOME/.bar_state.json"
REFRESH_RATE_FILE="$HOME/.refresh_rate.txt"

# Initialize state files
init_dj_system() {
    if [ ! -f "$REQUEST_QUEUE" ]; then
        echo '{"queue":[],"processed":[],"current_index":0}' > "$REQUEST_QUEUE"
    fi
    if [ ! -f "$BAR_STATE" ]; then
        echo '{"bar_open":false,"last_check":"","refresh_rate_ms":30000}' > "$BAR_STATE"
    fi
    if [ ! -f "$REFRESH_RATE_FILE" ]; then
        echo "30" > "$REFRESH_RATE_FILE"
    fi
}

# Check if repeat mode is on (bar open/closed)
check_bar_status() {
    # Check Apple Music repeat status
    REPEAT_STATUS=$(osascript -e 'tell application "Music" to get song repeat' 2>/dev/null)
    
    if [ "$REPEAT_STATUS" = "one" ]; then
        echo "open"
        update_bar_state "true"
    else
        echo "closed"
        update_bar_state "false"
    fi
}

update_bar_state() {
    local IS_OPEN="$1"
    local CURRENT_RATE=$(cat "$REFRESH_RATE_FILE" 2>/dev/null || echo "30")
    local RATE_MS=$((CURRENT_RATE * 1000))
    
    cat > "$BAR_STATE" << EOF
{
  "bar_open": $IS_OPEN,
  "last_check": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "refresh_rate_ms": $RATE_MS,
  "dj_status": "$([ "$IS_OPEN" = "true" ] && echo "ACCEPTING REQUESTS" || echo "CLOSED")"
}
EOF
}

# Calculate ludicrous speed refresh rate
calculate_refresh_rate() {
    local CURRENT_RATE=$(cat "$REFRESH_RATE_FILE" 2>/dev/null || echo "30")
    
    # Each request reduces the interval more aggressively
    # Using a different approach: divide by 2 for dramatic speedup
    # But not as extreme as /30 which goes straight to 1s
    local NEW_RATE
    
    # Progressive speedup formula
    if [ $CURRENT_RATE -ge 20 ]; then
        # Fast reduction at first
        NEW_RATE=$((CURRENT_RATE * 2 / 3))  # Reduce by 33%
    elif [ $CURRENT_RATE -ge 10 ]; then
        # Medium reduction
        NEW_RATE=$((CURRENT_RATE * 3 / 4))  # Reduce by 25%
    elif [ $CURRENT_RATE -ge 5 ]; then
        # Slower reduction near the limit
        NEW_RATE=$((CURRENT_RATE - 1))  # Reduce by 1 second
    else
        # Approaching ludicrous speed
        NEW_RATE=$((CURRENT_RATE - 1))
    fi
    
    # Ensure it never exceeds 60 seconds (max) or goes below 1 second (min)
    if [ $NEW_RATE -gt 60 ]; then
        NEW_RATE=60
    elif [ $NEW_RATE -le 0 ]; then
        NEW_RATE=1  # Ludicrous speed achieved!
    fi
    
    echo "$NEW_RATE" > "$REFRESH_RATE_FILE"
    echo "$NEW_RATE"
}

# Validate and sanitize song request
validate_request() {
    local SONG="$1"
    local ARTIST="$2"
    
    # Remove multiple spaces and special characters
    SONG=$(echo "$SONG" | tr -s ' ' | sed 's/[;<>&|`$]//g' | cut -c1-100)
    ARTIST=$(echo "$ARTIST" | tr -s ' ' | sed 's/[;<>&|`$]//g' | cut -c1-100)
    
    # Check if empty
    if [ -z "$SONG" ] || [ -z "$ARTIST" ]; then
        echo "ERROR: Invalid request"
        return 1
    fi
    
    # Check banned list
    if [ -f "$BANNED_SONGS" ]; then
        if grep -qi "${SONG}.*${ARTIST}" "$BANNED_SONGS"; then
            # Check allowed list override
            if [ -f "$ALLOWED_SONGS" ]; then
                if ! grep -qi "${SONG}.*${ARTIST}" "$ALLOWED_SONGS"; then
                    echo "ERROR: Song is banned"
                    return 1
                fi
            else
                echo "ERROR: Song is banned"
                return 1
            fi
        fi
    fi
    
    echo "${SONG}|${ARTIST}"
    return 0
}

# Correct graduation year (Y2K fix for Glenbard North)
correct_grad_year() {
    local YEAR="$1"
    
    # If 2-digit year provided
    if [ ${#YEAR} -eq 2 ]; then
        # Glenbard North opened ~1960s
        if [ $YEAR -ge 60 ] && [ $YEAR -le 99 ]; then
            YEAR=$((1900 + YEAR))
        else
            YEAR=$((2000 + YEAR))
        fi
    fi
    
    # Validate reasonable range (1965-2030)
    if [ $YEAR -lt 1965 ] || [ $YEAR -gt 2030 ]; then
        echo "ERROR: Invalid graduation year"
        return 1
    fi
    
    echo "$YEAR"
    return 0
}

# Queue song in Apple Music with state management
queue_song() {
    local SONG="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local IS_PANTHER="$4"
    local GRAD_YEAR="$5"
    local IP_HASH="$6"
    
    # Log the request
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Request: $SONG by $ARTIST | Panther: $IS_PANTHER | Year: $GRAD_YEAR | IP: $IP_HASH" >> "$REQUEST_LOG"
    
    # State-based queue management
    osascript << EOF
tell application "Music"
    try
        -- Save current repeat state
        set currentRepeat to song repeat
        
        -- Turn off repeat temporarily
        set song repeat to off
        
        -- Search for the song
        set searchResults to search playlist "Library" for "$SONG $ARTIST"
        
        if (count of searchResults) > 0 then
            -- Add to up next
            set theSong to item 1 of searchResults
            duplicate theSong to end of current playlist
            
            -- Restore repeat state (double toggle technique)
            set song repeat to one
            delay 0.1
            set song repeat to one
            
            return "SUCCESS: Queued $SONG by $ARTIST"
        else
            -- Restore repeat if song not found
            set song repeat to currentRepeat
            return "ERROR: Song not found in library"
        end if
    on error errMsg
        return "ERROR: " & errMsg
    end try
end tell
EOF
}

# Generate bar status message
get_bar_message() {
    local STATUS=$(check_bar_status)
    
    if [ "$STATUS" = "open" ]; then
        cat << EOF
🍺🎉 GIA & MELISSA'S ALL YOU CAN DRINK BAR IS OPEN!! 🎉🍺

🎵 Your AWESOME Bot DJ is NOW ACCEPTING REQUESTS! 🎵
🎧 Check your Apple Music for any available ANNOYING song 
🎶 To enhance your Big Brother surveillance interactive experience!

🐾 PANTHER PRIDE DJ REQUEST SYSTEM ACTIVE 🐾
➡️ Submit your requests below!
EOF
    else
        cat << EOF
🚫 Gia & Melissa's Open Bar is now CLOSED 🚫
Check back soon...

(Enable repeat mode in Apple Music to open the bar!)
EOF
    fi
}

# Process a complete request
process_request() {
    local SONG="$1"
    local ARTIST="$2"
    local IS_PANTHER="$3"
    local GRAD_YEAR="$4"
    local REQUESTER_IP="$5"
    
    # Validate inputs
    VALIDATED=$(validate_request "$SONG" "$ARTIST")
    if [ $? -ne 0 ]; then
        echo "$VALIDATED"
        return 1
    fi
    
    # Correct graduation year
    CORRECTED_YEAR=$(correct_grad_year "$GRAD_YEAR")
    if [ $? -ne 0 ]; then
        echo "$CORRECTED_YEAR"
        return 1
    fi
    
    # Extract validated song/artist
    IFS='|' read -r CLEAN_SONG CLEAN_ARTIST <<< "$VALIDATED"
    
    # Hash IP for privacy
    IP_HASH=$(echo -n "$REQUESTER_IP" | shasum -a 256 | cut -d' ' -f1 | cut -c1-8)
    
    # Queue the song
    RESULT=$(queue_song "$CLEAN_SONG" "$CLEAN_ARTIST" "$REQUESTER_ID" "$IS_PANTHER" "$CORRECTED_YEAR" "$IP_HASH")
    
    # Update refresh rate (ludicrous speed!)
    NEW_RATE=$(calculate_refresh_rate)
    
    echo "$RESULT | New refresh rate: ${NEW_RATE}s"
}

# Main execution
case "$1" in
    init)
        init_dj_system
        echo "DJ system initialized"
        ;;
    status)
        get_bar_message
        ;;
    check)
        check_bar_status
        ;;
    request)
        # Usage: request "song" "artist" "y/n" "grad_year" "ip"
        process_request "$2" "$3" "$4" "$5" "$6"
        ;;
    refresh)
        cat "$REFRESH_RATE_FILE" 2>/dev/null || echo "30"
        ;;
    *)
        echo "Usage: $0 {init|status|check|request|refresh}"
        exit 1
        ;;
esac
