#!/bin/bash

# 🎧 INTERNATIONAL DJ QUEUE MASTER v8.0 - MULTI-VLAN QUEUE LOGIC EDITION
# Advanced Queue Management, Repeat Logic, Requested vs Playlist Distinction
# Copyright 2025 - Panther Pride DJ Consortium International - "Queue Logic Perfection"™

# ANSI Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GOLD='\033[38;5;220m'
PINK='\033[38;5;205m'
ORANGE='\033[38;5;208m'
MAGENTA='\033[38;5;13m'
LIME='\033[38;5;10m'
NC='\033[0m' # No Color
BOLD='\033[1m'
BLINK='\033[5m'

# Configuration
QUEUE_FILE="$HOME/.dj_queue.json"
PLAY_STATE_FILE="$HOME/.dj_play_state.json"
BACKUP_STATE_FILE="$HOME/.dj_backup_state.json"
REPEAT_THRESHOLD=3
VOLUME_LEVEL="35"

# Hilarious repeat status messages (as requested)
REPEAT_MESSAGES=(
    "Annoyance in the Making"
    "Being a Smart Ass Had to Start from Ground Zero"
    "This Song is Having an Identity Crisis"
    "Stuck in Musical Purgatory"
    "The Groundhog Day Special"
    "Officially in the Cringe Zone"
    "DJ Accidentally Hit Repeat Too Many Times"
    "Song is Experiencing Déjà Vu"
    "Welcome to the Broken Record Club"
    "This Track is Having Trust Issues"
    "Musical Stockholm Syndrome Activated"
    "The Song That Wouldn't Leave"
)

# Function to initialize/rebuild the queue from previous requests
rebuild_queue_from_history() {
    echo -e "${YELLOW}🔧 Rebuilding queue from previous requests...${NC}"
    
    # Create proper queue structure
    cat > "$QUEUE_FILE" << 'EOF'
[
  {
    "id": "REQ-20250825-002759-A36DEED9",
    "timestamp": "2025-08-25T05:28:16Z",
    "position": 1,
    "song": "Welcome to the Jungle",
    "artist": "Guns N' Roses",
    "requester": "Panther 1995",
    "priority": "VIP",
    "status": "QUEUED",
    "type": "REQUESTED",
    "current_plays": 0,
    "max_plays": 3,
    "vlan_sync": true,
    "light_show": "PREMIUM"
  },
  {
    "id": "REQ-20250825-004037-4668E35A",
    "timestamp": "2025-08-25T05:40:42Z",
    "position": 2,
    "song": "Bohemian Rhapsody",
    "artist": "Queen",
    "requester": "TestUser",
    "priority": "HIGH",
    "status": "QUEUED",
    "type": "REQUESTED",
    "current_plays": 0,
    "max_plays": 3,
    "vlan_sync": true,
    "light_show": "STANDARD"
  },
  {
    "id": "VIP-20250825-005131-AFE8C0",
    "timestamp": "2025-08-25T05:51:36Z",
    "position": 3,
    "song": "Music",
    "artist": "Madonna",
    "requester": "Madonna",
    "priority": "VIP_JUMP",
    "status": "QUEUED",
    "type": "REQUESTED",
    "current_plays": 0,
    "max_plays": 3,
    "vlan_sync": true,
    "light_show": "PREMIUM_VIP"
  },
  {
    "id": "REQ-20250825-004513-2D8A0216",
    "timestamp": "2025-08-25T05:45:22Z",
    "position": 4,
    "song": "Don't Stop Me Now",
    "artist": "Queen",
    "requester": "tmux-test-user",
    "priority": "URGENT",
    "status": "QUEUED",
    "type": "REQUESTED",
    "current_plays": 0,
    "max_plays": 3,
    "vlan_sync": true,
    "light_show": "STANDARD"
  },
  {
    "id": "REQ-20250825-004553-6E60841A",
    "timestamp": "2025-08-25T05:45:58Z",
    "position": 5,
    "song": "Sandstorm",
    "artist": "Darude",
    "requester": "epic-user",
    "priority": "PEAK_TIME",
    "status": "QUEUED",
    "type": "REQUESTED",
    "current_plays": 0,
    "max_plays": 3,
    "vlan_sync": true,
    "light_show": "RAVE_MODE"
  }
]
EOF

    # Add some collaborative and rotation songs (includes P!NK - I Am Here)
    echo -e "${LIME}🎵 Adding collaborative playlist and rotation songs (including 'I Am Here' by P!NK)...${NC}"
    
    # Add playlist songs with different logic
    jq '. += [
      {
        "id": "PLAYLIST-$(date +%Y%m%d%H%M%S)-001",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "position": 6,
        "song": "I Am Here",
        "artist": "P!NK",
        "requester": "DJ_SYSTEM",
        "priority": "PLAYLIST",
        "status": "QUEUED",
        "type": "PLAYLIST",
        "current_plays": 0,
        "max_plays": 1,
        "playlist_source": "I Am Here - P!NK",
        "collaborative": true,
        "vlan_sync": false,
        "light_show": "AMBIENT"
      },
      {
        "id": "PLAYLIST-$(date +%Y%m%d%H%M%S)-002",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "position": 7,
        "song": "Collaborative Mix Track",
        "artist": "Various Artists",
        "requester": "DJ_SYSTEM",
        "priority": "PLAYLIST",
        "status": "QUEUED",
        "type": "PLAYLIST",
        "current_plays": 0,
        "max_plays": 1,
        "playlist_source": "I Am Here - Collaborators",
        "collaborative": true,
        "vlan_sync": false,
        "light_show": "COLLABORATIVE"
      },
      {
        "id": "ROTATION-$(date +%Y%m%d%H%M%S)-001",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "position": 8,
        "song": "Bar Warmup Groove",
        "artist": "DJ Rotation",
        "requester": "SYSTEM",
        "priority": "ROTATION",
        "status": "QUEUED",
        "type": "ROTATION",
        "current_plays": 0,
        "max_plays": 1,
        "vlan_sync": false,
        "light_show": "WARMUP"
      },
      {
        "id": "ROTATION-$(date +%Y%m%d%H%M%S)-002",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "position": 9,
        "song": "Chill Interlude",
        "artist": "House Band",
        "requester": "SYSTEM",
        "priority": "ROTATION",
        "status": "QUEUED",
        "type": "ROTATION",
        "current_plays": 0,
        "max_plays": 1,
        "vlan_sync": false,
        "light_show": "CHILL"
      }
    ]' "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    
    echo -e "${GREEN}✅ Queue rebuilt with ${BOLD}9 tracks${NC} ${GREEN}(5 requested + 2 playlist + 2 rotation)${NC}"
}

# Function to initialize play state tracking
initialize_play_state() {
    if [ ! -f "$PLAY_STATE_FILE" ]; then
        cat > "$PLAY_STATE_FILE" << 'EOF'
{
  "current_track_id": null,
  "current_position": 0,
  "current_plays": 0,
  "last_update": null,
  "queue_position": 0,
  "auto_advance": true
}
EOF
    fi
}

# Function to get next song in queue based on repeat logic
get_next_song() {
    local current_id="$1"
    
    if [ ! -f "$QUEUE_FILE" ]; then
        echo "null"
        return 1
    fi
    
    # If no current song, get first in queue
    if [ "$current_id" = "null" ] || [ -z "$current_id" ]; then
        local next_song=$(jq -r '.[0] // null' "$QUEUE_FILE")
        echo "$next_song"
        return 0
    fi
    
    # Find current song and check repeat logic
    local current_song=$(jq --arg id "$current_id" '.[] | select(.id == $id)' "$QUEUE_FILE")
    local current_plays=$(echo "$current_song" | jq -r '.current_plays // 0')
    local max_plays=$(echo "$current_song" | jq -r '.max_plays // 3')
    local song_type=$(echo "$current_song" | jq -r '.type // "REQUESTED"')
    
    if [ "$current_plays" -lt "$max_plays" ]; then
        # Continue with same song (increment play count)
        jq --arg id "$current_id" '
            map(if .id == $id then .current_plays = (.current_plays // 0) + 1 else . end)
        ' "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
        
        echo "$current_song"
        return 0
    else
        # Move to next song in queue
        local current_pos=$(echo "$current_song" | jq -r '.position')
        local next_pos=$((current_pos + 1))
        
        # Mark current song as completed
        jq --arg id "$current_id" '
            map(if .id == $id then .status = "COMPLETED" else . end)
        ' "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
        
        # Get next song
        local next_song=$(jq --arg pos "$next_pos" '.[] | select(.position == ($pos | tonumber) and .status == "QUEUED")' "$QUEUE_FILE")
        
        if [ "$next_song" = "null" ] || [ -z "$next_song" ]; then
            # No more songs, loop back to first or stop
            local first_queued=$(jq -r '.[] | select(.status == "QUEUED") | .id' "$QUEUE_FILE" | head -1)
            if [ -n "$first_queued" ]; then
                local first_song=$(jq --arg id "$first_queued" '.[] | select(.id == $id)' "$QUEUE_FILE")
                echo "$first_song"
            else
                echo "null"
            fi
        else
            echo "$next_song"
        fi
    fi
}

# Function to play specific song with repeat logic
play_song_with_queue_logic() {
    local song_data="$1"
    
    if [ "$song_data" = "null" ] || [ -z "$song_data" ]; then
        echo -e "${RED}❌ No valid song data provided${NC}"
        return 1
    fi
    
    local song_title=$(echo "$song_data" | jq -r '.song')
    local artist=$(echo "$song_data" | jq -r '.artist')
    local requester=$(echo "$song_data" | jq -r '.requester')
    local song_type=$(echo "$song_data" | jq -r '.type // "REQUESTED"')
    local current_plays=$(echo "$song_data" | jq -r '.current_plays // 0')
    local max_plays=$(echo "$song_data" | jq -r '.max_plays // 3')
    local song_id=$(echo "$song_data" | jq -r '.id')
    
    echo -e "${GREEN}🎵 International DJ Queue Master: ${BOLD}\"$song_title\" by $artist${NC}"
    echo -e "${CYAN}   Type: ${YELLOW}$song_type${NC} | Requester: ${YELLOW}$requester${NC}"
    echo -e "${CYAN}   Plays: ${YELLOW}$current_plays/$max_plays${NC}"
    
    # Show different behavior for requested vs playlist songs
    if [ "$song_type" = "REQUESTED" ]; then
        echo -e "${PINK}🎧 REQUESTED SONG - Will repeat $max_plays times${NC}"
        if [ "$current_plays" -ge "$REPEAT_THRESHOLD" ]; then
            local repeat_status="${REPEAT_MESSAGES[$((RANDOM % ${#REPEAT_MESSAGES[@]}))]}"
            echo -e "${ORANGE}🔄 Status: ${BOLD}$repeat_status${NC}"
            
            # Notify with humor
            osascript -e "display notification \"$song_title is now: $repeat_status (Play $current_plays/$max_plays)\" with title \"🔄 REPEAT STATUS\" subtitle \"Requested by $requester\""
        fi
    else
        echo -e "${LIME}📂 PLAYLIST SONG - Single play from collaborative playlist${NC}"
    fi
    
    # Try to actually play the song
    local temp_script="/tmp/dj_queue_$$.scpt"
    cat > "$temp_script" << 'APPLESCRIPT'
tell application "Music"
    try
        activate
        delay 0.5
        
        set searchResults to (search library 1 for "SONG_REPLACE ARTIST_REPLACE")
        
        if (count of searchResults) > 0 then
            set foundTrack to item 1 of searchResults
            play foundTrack
            
            -- Set repeat mode based on type
            if "TYPE_REPLACE" = "REQUESTED" then
                set song repeat to all
            else
                set song repeat to off
            end if
            
            display notification "🎧 Queue Master: SONG_REPLACE by ARTIST_REPLACE" with title "🎵 NOW PLAYING" subtitle "TYPE_REPLACE | Play PLAY_COUNT/MAX_PLAYS"
            return "SUCCESS"
        else
            set searchResults to (search library 1 for "SONG_REPLACE")
            if (count of searchResults) > 0 then
                set foundTrack to item 1 of searchResults
                play foundTrack
                return "PARTIAL_SUCCESS"
            else
                return "NOT_FOUND"
            end if
        end if
    on error
        return "ERROR"
    end try
end tell
APPLESCRIPT
    
    # Replace placeholders
    sed -i '' "s/SONG_REPLACE/$song_title/g" "$temp_script"
    sed -i '' "s/ARTIST_REPLACE/$artist/g" "$temp_script"
    sed -i '' "s/TYPE_REPLACE/$song_type/g" "$temp_script"
    sed -i '' "s/PLAY_COUNT/$current_plays/g" "$temp_script"
    sed -i '' "s/MAX_PLAYS/$max_plays/g" "$temp_script"
    
    # Execute the script
    local result=$(osascript "$temp_script" 2>/dev/null || echo "FAILED")
    rm -f "$temp_script"
    
    # Update play state
    jq -n \
        --arg id "$song_id" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg plays "$current_plays" \
        '{
            "current_track_id": $id,
            "current_plays": ($plays | tonumber),
            "last_update": $timestamp,
            "playback_result": "'$result'"
        }' > "$PLAY_STATE_FILE"
    
    case "$result" in
        "SUCCESS")
            echo -e "${GREEN}✅ Song playing successfully with queue logic!${NC}"
            post_status_event "🎵 NOW PLAYING: \"$song_title\" by $artist — Requested by $requester"
            return 0
            ;;
        "PARTIAL_SUCCESS")
            echo -e "${ORANGE}⚠️  Playing closest match${NC}"
            post_status_event "🎵 NOW PLAYING (closest match): \"$song_title\" — Requested by $requester"
            return 0
            ;;
        *)
            echo -e "${RED}❌ Playback failed, will try next in queue${NC}"
            post_status_event "❌ Playback failed for \"$song_title\" by $artist — Requested by $requester"
            return 1
            ;;
    esac
}

# Function to advance queue automatically
advance_queue() {
    echo -e "${GOLD}🔄 Advancing queue with international DJ logic...${NC}"
    
    local current_state=$(jq -r '.current_track_id // "null"' "$PLAY_STATE_FILE" 2>/dev/null || echo "null")
    local next_song=$(get_next_song "$current_state")
    
    if [ "$next_song" != "null" ]; then
        play_song_with_queue_logic "$next_song"
    else
        echo -e "${YELLOW}⚠️  Queue empty, keeping current song playing${NC}"
    fi
}

# Function to show detailed queue status
show_queue_master_status() {
    echo -e "${BOLD}${GOLD}🌍 INTERNATIONAL DJ QUEUE MASTER STATUS${NC}"
    echo -e "${GOLD}═══════════════════════════════════════════════════════════${NC}"
    
    # Current Apple Music status
    local state=$(osascript -e 'tell application "Music" to get player state' 2>/dev/null || echo "unknown")
    local track=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null || echo "None")
    local artist=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null || echo "Unknown")
    
    echo -e "${CYAN}Current Playback:${NC}"
    echo -e "  ${YELLOW}State: ${BOLD}$state${NC}"
    echo -e "  ${YELLOW}Track: ${BOLD}$track${NC}"
    echo -e "  ${YELLOW}Artist: ${BOLD}$artist${NC}"
    
    # Queue status
    if [ -f "$QUEUE_FILE" ]; then
        local total_songs=$(jq length "$QUEUE_FILE" 2>/dev/null || echo "0")
        local queued_songs=$(jq '[.[] | select(.status == "QUEUED")] | length' "$QUEUE_FILE" 2>/dev/null || echo "0")
        local completed_songs=$(jq '[.[] | select(.status == "COMPLETED")] | length' "$QUEUE_FILE" 2>/dev/null || echo "0")
        local requested_songs=$(jq '[.[] | select(.type == "REQUESTED")] | length' "$QUEUE_FILE" 2>/dev/null || echo "0")
        local playlist_songs=$(jq '[.[] | select(.type == "PLAYLIST")] | length' "$QUEUE_FILE" 2>/dev/null || echo "0")
        
        echo -e "\n${PINK}Queue Statistics:${NC}"
        echo -e "  ${YELLOW}Total Songs: ${BOLD}$total_songs${NC}"
        echo -e "  ${YELLOW}Queued: ${BOLD}$queued_songs${NC} | Completed: ${BOLD}$completed_songs${NC}"
        echo -e "  ${YELLOW}Requested: ${BOLD}$requested_songs${NC} | Playlist: ${BOLD}$playlist_songs${NC}"
        
        echo -e "\n${LIME}🎵 ACTIVE QUEUE:${NC}"
        jq -r '.[] | select(.status == "QUEUED") | 
            "  \(.position). [\(.type)] \(.song) by \(.artist) - \(.requester) (\(.current_plays // 0)/\(.max_plays))"' "$QUEUE_FILE" 2>/dev/null || echo "  No active queue"
        
        echo -e "\n${ORANGE}📋 COMPLETED:${NC}"
        jq -r '.[] | select(.status == "COMPLETED") | 
            "  ✅ [\(.type)] \(.song) by \(.artist) - \(.requester)"' "$QUEUE_FILE" 2>/dev/null || echo "  None completed yet"
    else
        echo -e "\n${RED}❌ No queue file found${NC}"
    fi
    
    echo -e "\n${BOLD}${GREEN}🕺 International Dance Floor Status: ${BOLD}MULTI-VLAN PROTECTED${NC}"
}

# Function to start the queue from Madonna's VIP request
start_madonna_recovery() {
    echo -e "${GOLD}👑 MADONNA VIP RECOVERY INITIATED 👑${NC}"
    echo -e "${PINK}Prioritizing Madonna's 'Music' request...${NC}"
    
    # Move Madonna to position 1
    jq '
        map(if .requester == "Madonna" and .song == "Music" 
            then .position = 1 | .status = "QUEUED" | .current_plays = 0
            else .position = (.position + 1) 
            end) | 
        sort_by(.position)
    ' "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    
    # Get Madonna's song and play it
    local madonna_song=$(jq '.[] | select(.requester == "Madonna" and .song == "Music")' "$QUEUE_FILE")
    
    if [ "$madonna_song" != "null" ] && [ -n "$madonna_song" ]; then
        echo -e "${GOLD}🎵 Playing Madonna's VIP request...${NC}"
        play_song_with_queue_logic "$madonna_song"
    else
        echo -e "${RED}❌ Madonna's request not found in queue${NC}"
        advance_queue
    fi
}

# Post an event to the dashboard status.json
post_status_event() {
    local event_text="$1"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local status_json="$script_dir/status.json"

    # Ensure status.json exists
    if [ ! -f "$status_json" ]; then
        cat > "$status_json" << EOF
{
  "services": [],
  "events": [],
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "message": ""
}
EOF
    fi

    # Add event and update timestamp/message
    jq \
      --arg event "$event_text" \
      --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '.events = ([ $event ] + (.events // []))[:50] | .timestamp = $ts | .message = $event' \
      "$status_json" > "$status_json.tmp" && mv "$status_json.tmp" "$status_json"
}

# Enqueue a new track with proper metadata
enqueue_track() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local TYPE="${4:-REQUESTED}"   # REQUESTED | PLAYLIST | ROTATION
    local PRIORITY="${5:-STANDARD}"
    local DEDICATION="${6:-}"
    local SOURCE="${7:-manual}"

    if [ ! -f "$QUEUE_FILE" ]; then
        echo "[]" > "$QUEUE_FILE"
    fi

    # Determine next position
    local next_pos=$(jq 'if length>0 then (map(.position) | max + 1) else 1 end' "$QUEUE_FILE")

    # Determine ID prefix and max plays
    local id_prefix="REQ"
    local max_plays=3
    case "$TYPE" in
        PLAYLIST) id_prefix="PLAYLIST"; max_plays=1 ;;
        ROTATION) id_prefix="ROTATION"; max_plays=1 ;;
        *) id_prefix="REQ"; max_plays=3 ;;
    esac

    local new_id="${id_prefix}-$(date +%Y%m%d%H%M%S)-$RANDOM"

    # Build entry JSON
    local entry_json
    entry_json=$(jq -n \
        --arg id "$new_id" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg pos "$next_pos" \
        --arg song "$SONG_TITLE" \
        --arg artist "$ARTIST" \
        --arg requester "$REQUESTER" \
        --arg priority "$PRIORITY" \
        --arg type "$TYPE" \
        --arg dedication "$DEDICATION" \
        --arg source "$SOURCE" \
        --argjson max_plays "$max_plays" \
        '{
            id: $id,
            timestamp: $ts,
            position: ($pos|tonumber),
            song: $song,
            artist: $artist,
            requester: $requester,
            priority: $priority,
            status: "QUEUED",
            type: $type,
            current_plays: 0,
            max_plays: $max_plays,
            vlan_sync: true,
            light_show: (if $type=="REQUESTED" then "STANDARD" else "AMBIENT" end),
            dedication: (if ($dedication|length)>0 then $dedication else null end),
            source: $source
        }')

    # Append to queue
    jq --argjson new_entry "$entry_json" '. += [ $new_entry ]' "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"

    echo -e "${GREEN}✅ Enqueued: ${BOLD}\"$SONG_TITLE\" by $ARTIST${NC} (${TYPE}) at position $next_pos"

    # Post event for message board
    local event_text="🎧 Queued: \"$SONG_TITLE\" by $ARTIST — Requested by $REQUESTER$( [ -n "$DEDICATION" ] && echo " — Dedication: $DEDICATION" )"
    post_status_event "$event_text"
}

# Main execution
case "${1:-help}" in
    rebuild)
        rebuild_queue_from_history
        initialize_play_state
        ;;
    madonna)
        start_madonna_recovery
        ;;
    next)
        advance_queue
        ;;
    status)
        show_queue_master_status
        ;;
    play)
        if [ -n "$2" ]; then
            song_by_pos=$(jq --arg pos "$2" '.[] | select(.position == ($pos | tonumber))' "$QUEUE_FILE")
            play_song_with_queue_logic "$song_by_pos"
        else
            advance_queue
        fi
        ;;
    enqueue)
        # Usage: enqueue "song" "artist" "requester" [type] [priority] [dedication] [source]
        enqueue_track "${2:-Unknown Song}" "${3:-Unknown Artist}" "${4:-Anonymous}" "${5:-REQUESTED}" "${6:-STANDARD}" "${7:-}" "${8:-manual}"
        ;;
    *)
        echo "Usage: $0 {rebuild|madonna|next|status|play|enqueue} [args]"
        echo ""
        echo "Commands:"
        echo "  rebuild         - Rebuild queue from notification history"
        echo "  madonna         - Start with Madonna's VIP request"
        echo "  next            - Advance to next song in queue"
        echo "  status          - Show detailed queue status"
        echo "  play [pos]      - Play specific position or advance queue"
        echo "  enqueue [args]  - Enqueue a song with metadata"
        echo ""
        echo "International DJ Queue Master v8.0 - Multi-VLAN Ready!"
        exit 1
        ;;
esac
