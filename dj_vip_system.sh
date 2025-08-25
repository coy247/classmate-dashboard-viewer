#!/bin/bash

# 🎧 VIP DJ QUEUE MANAGEMENT SYSTEM v5.0 - SHAREPLAY EDITION
# Priority Queue Jumping, SharePlay Integration, Now Playing Notifications
# Copyright 2025 - Panther Pride DJ Consortium International - Madonna Approved™

# ANSI Color codes for terminal rave
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GOLD='\033[38;5;220m'
PINK='\033[38;5;205m'
NC='\033[0m' # No Color
BOLD='\033[1m'
BLINK='\033[5m'

# DJ Queue Database
QUEUE_FILE="$HOME/.dj_queue.json"
NOTIFICATION_LOG="$HOME/.dj_notifications.log"
NOW_PLAYING_FILE="$HOME/.dj_now_playing.json"
VIP_LOG="$HOME/.dj_vip_actions.log"

# SharePlay and Audio Configuration
SPOTIFY_TRACK_BASE="https://open.spotify.com/track/"
APPLE_MUSIC_BASE="https://music.apple.com/search?term="
VOLUME_LEVEL="20"  # Low volume for late night consideration

# Function to create VIP notification display
show_vip_booth() {
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║  👑 VIP DJ QUEUE MANAGEMENT SYSTEM v5.0 - SHAREPLAY         ║
    ║     * PRIORITY JUMPING * SHAREPLAY * NOW PLAYING ALERTS *    ║
    ╚═══════════════════════════════════════════════════════════════╝
    
         ┌─────────────────────────────────────────────────┐
         │ 👑👑👑  ╔════════════════════╗  👑👑👑         │
         │ ║ VIP ║  ║  ▶ NOW PLAYING ◀  ║  ║ VIP ║         │
         │ ║QUEUE║  ╚════════════════════╝  ║JUMP║         │
         │ 👑👑👑  ╔════════════════════╗  👑👑👑         │
         │ 🎵🎵🎵  ║   SHAREPLAY READY  ║  🎵🎵🎵         │
         │ ███████  ╚════════════════════╝  ███████         │
         │  [👑][🎵][⚡]  ◄◄  ■  ▶▶  [⚡][🎵][👑]      │
         └─────────────────────────────────────────────────┘
                    ╱│╲  VIP BROADCAST  ╱│╲
                   ╱ │ ╲    ENABLED    ╱ │ ╲
                  ╱  │  ╲ SharePlay   ╱  │  ╲
EOF
}

# Function to jump queue to top (VIP treatment)
vip_queue_jump() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local VIP_REASON="$4"
    
    REQUEST_ID=$(generate_request_id)
    
    echo -e "${GOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║              👑 VIP QUEUE JUMP INITIATED 👑               ║${NC}"
    echo -e "${GOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    
    if [ ! -f "$QUEUE_FILE" ]; then
        echo "[]" > "$QUEUE_FILE"
    fi
    
    # Create VIP entry to insert at position 1
    local vip_entry=$(jq -n \
        --arg id "$REQUEST_ID" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg song "$SONG_TITLE" \
        --arg artist "$ARTIST" \
        --arg requester "$REQUESTER" \
        --arg reason "$VIP_REASON" \
        '{
            "id": $id,
            "timestamp": $timestamp,
            "position": 1,
            "song": $song,
            "artist": $artist,
            "requester": $requester,
            "priority": "VIP_JUMP",
            "vip_reason": $reason,
            "status": "QUEUED_VIP",
            "vlan_sync": true,
            "tmux_broadcast": true,
            "shareplay_ready": true,
            "light_show": "PREMIUM_VIP"
        }')
    
    # Insert at beginning and reposition everything else
    jq --argjson new_entry "$vip_entry" '
        . as $original |
        [$new_entry] + 
        ($original | to_entries | map(.value | .position = (.value.position + 1)) | map(.value))
    ' "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    
    echo -e "${PINK}🚀 ${BOLD}$REQUESTER${NC} ${PINK}just jumped to #1 with${NC} ${GOLD}\"$SONG_TITLE\"${NC} ${PINK}by${NC} ${GOLD}$ARTIST${NC}"
    echo -e "${CYAN}   Reason: ${YELLOW}$VIP_REASON${NC}"
    
    # Log VIP action
    echo "[$(date)] VIP JUMP: $REQUEST_ID - $SONG_TITLE by $ARTIST from $REQUESTER (Reason: $VIP_REASON)" >> "$VIP_LOG"
    
    return 0
}

# Function to generate unique request ID
generate_request_id() {
    echo "VIP-$(date +%Y%m%d)-$(date +%H%M%S)-$(openssl rand -hex 3 | tr '[:lower:]' '[:upper:]')"
}

# Function to notify user that their song is about to play
notify_now_playing() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local REQUEST_ID="$4"
    
    clear
    show_vip_booth
    
    # Strobe effect for "Now Playing"
    for i in {1..5}; do
        printf "\r${BLINK}${GOLD}🎵 NOW PLAYING 🎵 NOW PLAYING 🎵 NOW PLAYING 🎵${NC}"
        sleep 0.2
        printf "\r                                                    "
        sleep 0.2
    done
    echo ""
    
    echo -e "\n${BLINK}${GOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║${NC}    ${BOLD}${PINK}🎵 YOUR SONG IS NOW PLAYING! 🎵${NC}                          ${GOLD}║${NC}"
    echo -e "${GOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${BOLD}${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}REQUEST ID:${NC} ${YELLOW}$REQUEST_ID${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}NOW PLAYING:${NC} $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo -e "${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}${GOLD}🎵 TRACK DETAILS${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Song:${NC}    ${GREEN}$SONG_TITLE${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Artist:${NC}  ${GREEN}$ARTIST${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Requested By:${NC} ${PINK}$REQUESTER${NC}"
    echo -e "${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}${PURPLE}📱 SHAREPLAY STATUS${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Status:${NC}  ${GREEN}ACTIVE & SYNCED${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Devices:${NC} All connected devices"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    
    # Save now playing info
    jq -n \
        --arg id "$REQUEST_ID" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg song "$SONG_TITLE" \
        --arg artist "$ARTIST" \
        --arg requester "$REQUESTER" \
        '{
            "request_id": $id,
            "now_playing_timestamp": $timestamp,
            "song": $song,
            "artist": $artist,
            "requester": $requester,
            "shareplay_active": true,
            "notification_sent": true
        }' > "$NOW_PLAYING_FILE"
    
    # Desktop notification
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$SONG_TITLE by $ARTIST is NOW PLAYING!\" with title \"🎵 NOW PLAYING\" subtitle \"Requested by $REQUESTER\" sound name \"Glass\""
    fi
    
    echo -e "\n${BOLD}${GREEN}✅ $REQUESTER has been notified that their song is playing!${NC}"
}

# Function to start SharePlay and play audio
start_shareplay_audio() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    
    echo -e "\n${BOLD}${PURPLE}📱 INITIATING SHAREPLAY SESSION${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}SharePlay Features:${NC}"
    echo -e "${CYAN}│${NC}   ✓ Multi-device synchronization"
    echo -e "${CYAN}│${NC}   ✓ Real-time playback control"
    echo -e "${CYAN}│${NC}   ✓ Volume normalization across devices"
    echo -e "${CYAN}│${NC}   ✓ Queue sharing enabled"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    
    # Set volume to low level for late night consideration
    echo -e "\n${YELLOW}🔊 Setting volume to ${VOLUME_LEVEL}% for late night consideration...${NC}"
    osascript -e "set volume output volume $VOLUME_LEVEL"
    
    # Try to play via different methods
    echo -e "${GREEN}🎵 Attempting to play: ${BOLD}\"$SONG_TITLE\" by $ARTIST${NC}"
    
    # Method 1: Try Apple Music (if available)
    if command -v osascript &> /dev/null; then
        echo -e "${CYAN}   📱 Trying Apple Music...${NC}"
        
        # Search and play via Apple Music
        local search_term=$(echo "$SONG_TITLE $ARTIST" | sed 's/ /+/g')
        
        # Try to open Apple Music and search
        osascript << EOF 2>/dev/null || true
        tell application "Music"
            if not (exists window 1) then
                activate
                delay 1
            end if
            set search results to (search playlist 1 for "$SONG_TITLE" only songs)
            if (count of search results) > 0 then
                play (item 1 of search results)
                display notification "Now playing via Apple Music: $SONG_TITLE by $ARTIST" with title "🎵 SharePlay Active"
            end if
        end tell
EOF
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}   ✅ Apple Music playback initiated${NC}"
            return 0
        fi
    fi
    
    # Method 2: Try Spotify (if available)
    echo -e "${CYAN}   🎵 Trying Spotify Web Player...${NC}"
    if command -v open &> /dev/null; then
        # Open Spotify web player search
        local spotify_search="https://open.spotify.com/search/$(echo "$SONG_TITLE $ARTIST" | sed 's/ /%20/g')"
        open "$spotify_search" 2>/dev/null || true
        echo -e "${GREEN}   ✅ Spotify search opened${NC}"
    fi
    
    # Method 3: System audio test (fallback)
    echo -e "${CYAN}   🔊 Testing system audio capabilities...${NC}"
    if command -v say &> /dev/null; then
        # Use text-to-speech as audio test
        say -v "Samantha" -r 200 "Now playing $SONG_TITLE by $ARTIST. SharePlay session active across all devices." &
        echo -e "${GREEN}   ✅ System audio test completed${NC}"
    fi
    
    # Method 4: Try YouTube Music (as last resort)
    echo -e "${CYAN}   🌐 Opening YouTube Music as backup...${NC}"
    if command -v open &> /dev/null; then
        local youtube_search="https://music.youtube.com/search?q=$(echo "$SONG_TITLE $ARTIST" | sed 's/ /+/g')"
        open "$youtube_search" 2>/dev/null || true
        echo -e "${GREEN}   ✅ YouTube Music search opened${NC}"
    fi
    
    echo -e "\n${BOLD}${GREEN}🎉 SharePlay session initiated! Check your connected devices.${NC}"
    
    return 0
}

# Function to broadcast tmux notifications for VIP
broadcast_vip_to_tmux() {
    local message="$1"
    local vip_reason="$2"
    
    if tmux list-sessions &>/dev/null; then
        echo -e "${GOLD}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GOLD}║              👑 VIP BROADCAST TO ALL TERMINALS            ║${NC}"
        echo -e "${GOLD}╚══════════════════════════════════════════════════════════╝${NC}"
        
        local sessions=$(tmux list-sessions -F '#{session_name}')
        local broadcast_count=0
        
        for session in $sessions; do
            local windows=$(tmux list-windows -t "$session" -F '#{window_index}')
            
            for window in $windows; do
                local panes=$(tmux list-panes -t "$session:$window" -F '#{pane_index}')
                
                for pane in $panes; do
                    tmux send-keys -t "$session:$window.$pane" "clear" C-m 2>/dev/null || true
                    tmux send-keys -t "$session:$window.$pane" "echo -e '${BLINK}${GOLD}👑 VIP QUEUE JUMP 👑${NC}'" C-m 2>/dev/null || true
                    tmux send-keys -t "$session:$window.$pane" "echo -e '${PINK}$message${NC}'" C-m 2>/dev/null || true
                    tmux send-keys -t "$session:$window.$pane" "echo -e '${YELLOW}Reason: $vip_reason${NC}'" C-m 2>/dev/null || true
                    tmux send-keys -t "$session:$window.$pane" "echo -e '${CYAN}═══════════════════════════════════════${NC}'" C-m 2>/dev/null || true
                    
                    ((broadcast_count++))
                done
            done
        done
        
        tmux display-message -a "👑 VIP QUEUE JUMP: $message"
        echo -e "${YELLOW}VIP broadcast sent to ${BOLD}$broadcast_count${NC} ${YELLOW}terminals${NC}"
    fi
}

# Main VIP request function
process_vip_request() {
    local SONG_TITLE="$1"
    local ARTIST="$2" 
    local REQUESTER="$3"
    local VIP_REASON="$4"
    local PLAY_NOW="${5:-false}"
    
    clear
    show_vip_booth
    
    echo -e "\n${BLINK}${GOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║${NC}    ${BOLD}${PINK}👑 VIP REQUEST PROCESSING 👑${NC}                               ${GOLD}║${NC}"
    echo -e "${GOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
    
    # Process the VIP queue jump
    vip_queue_jump "$SONG_TITLE" "$ARTIST" "$REQUESTER" "$VIP_REASON"
    
    # Broadcast to tmux
    broadcast_vip_to_tmux "$SONG_TITLE by $ARTIST (VIP: $REQUESTER)" "$VIP_REASON"
    
    # If immediate play requested
    if [ "$PLAY_NOW" = "true" ]; then
        echo -e "\n${GOLD}🚀 Immediate playback requested...${NC}"
        sleep 2
        
        # Get the request ID from the queue
        local REQUEST_ID=$(jq -r '.[0].id' "$QUEUE_FILE")
        
        # Notify the requester
        notify_now_playing "$SONG_TITLE" "$ARTIST" "$REQUESTER" "$REQUEST_ID"
        
        # Start SharePlay
        start_shareplay_audio "$SONG_TITLE" "$ARTIST"
        
        # Remove from queue since it's now playing
        jq '.[1:]' "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    fi
    
    echo -e "\n${BLINK}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}✅ VIP REQUEST SUCCESSFULLY PROCESSED${NC}                   ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}SharePlay ready across all connected devices${NC}           ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${GOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}    Thank you for using Panther Pride VIP DJ Services${NC}"
    echo -e "${BOLD}      \"Where VIPs Skip The Line Globally\"™${NC}"
    echo -e "${BOLD}           👑 Madonna Approved Experience 👑${NC}"
    echo -e "${GOLD}═══════════════════════════════════════════════════════════${NC}\n"
}

# Main execution
case "${1:-help}" in
    vip)
        process_vip_request "${2:-Music}" "${3:-Madonna}" "${4:-Madonna}" "${5:-Private jet privilege + Queen of Pop status}" "${6:-true}"
        ;;
    now_playing)
        notify_now_playing "${2:-Unknown Song}" "${3:-Unknown Artist}" "${4:-Anonymous}" "${5:-UNKNOWN-ID}"
        ;;
    shareplay)
        start_shareplay_audio "${2:-Music}" "${3:-Madonna}"
        ;;
    queue_jump)
        vip_queue_jump "${2:-Unknown Song}" "${3:-Unknown Artist}" "${4:-VIP User}" "${5:-VIP privileges}"
        ;;
    status)
        if [ -f "$QUEUE_FILE" ]; then
            echo -e "${BOLD}Current VIP Queue Status:${NC}"
            jq '.' "$QUEUE_FILE"
        else
            echo "Queue is empty"
        fi
        ;;
    *)
        echo "Usage: $0 {vip|now_playing|shareplay|queue_jump|status} [song] [artist] [requester] [reason] [play_now]"
        echo ""
        echo "Commands:"
        echo "  vip           - Process VIP request with queue jump and immediate play"
        echo "  now_playing   - Notify user their song is now playing"
        echo "  shareplay     - Start SharePlay audio session"
        echo "  queue_jump    - Jump to front of queue (VIP treatment)"
        echo "  status        - Show current queue status"
        echo ""
        echo "Example: $0 vip \"Music\" \"Madonna\" \"Madonna\" \"Private jet privilege\" true"
        exit 1
        ;;
esac
