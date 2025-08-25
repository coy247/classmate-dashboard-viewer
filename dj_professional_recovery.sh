#!/bin/bash

# 🎧 PROFESSIONAL DJ RECOVERY SYSTEM v7.0 - NO DANCE FLOOR CLEARING EDITION
# Graceful Recovery, Dedication System, Repeat Protection, Donation Integration
# Copyright 2025 - Panther Pride DJ Consortium International - "Keep The Floor Moving"™

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
NC='\033[0m' # No Color
BOLD='\033[1m'
BLINK='\033[5m'

# Configuration
QUEUE_FILE="$HOME/.dj_queue.json"
BACKUP_STATE_FILE="$HOME/.dj_backup_state.json"
DEDICATION_FILE="$HOME/.dj_dedications.json"
DONATION_LOG="$HOME/.dj_donations.log"
REPEAT_THRESHOLD=3  # Lowered from 500 to 3 as requested
VOLUME_LEVEL="35"

# Hilarious repeat status messages
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

# Function to save current state before any changes
save_backup_state() {
    local current_state=$(osascript -e 'tell application "Music" to get player state' 2>/dev/null || echo "stopped")
    local current_song=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null || echo "None")
    local current_artist=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null || echo "Unknown")
    local current_position=$(osascript -e 'tell application "Music" to get player position' 2>/dev/null || echo "0")
    
    jq -n \
        --arg state "$current_state" \
        --arg song "$current_song" \
        --arg artist "$current_artist" \
        --arg position "$current_position" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            "backup_timestamp": $timestamp,
            "previous_state": $state,
            "previous_song": $song,
            "previous_artist": $artist,
            "previous_position": $position,
            "recovery_available": true
        }' > "$BACKUP_STATE_FILE"
    
    echo -e "${CYAN}💾 Backup state saved: $current_song by $current_artist${NC}"
}

# Function for graceful recovery when things go wrong
graceful_recovery() {
    echo -e "${RED}🚨 DANCE FLOOR EMERGENCY DETECTED! 🚨${NC}"
    echo -e "${YELLOW}Initiating graceful recovery procedure...${NC}"
    
    if [ -f "$BACKUP_STATE_FILE" ]; then
        local previous_song=$(jq -r '.previous_song' "$BACKUP_STATE_FILE" 2>/dev/null || echo "None")
        local previous_artist=$(jq -r '.previous_artist' "$BACKUP_STATE_FILE" 2>/dev/null || echo "Unknown")
        local previous_state=$(jq -r '.previous_state' "$BACKUP_STATE_FILE" 2>/dev/null || echo "stopped")
        
        if [ "$previous_song" != "None" ] && [ "$previous_song" != "null" ]; then
            echo -e "${GREEN}🎵 Attempting to restore: \"$previous_song\" by $previous_artist${NC}"
            
            # Try to search and play the previous song
            local temp_script="/tmp/dj_recovery_$$.scpt"
            cat > "$temp_script" << 'APPLESCRIPT'
tell application "Music"
    try
        set searchResults to (search library 1 for "SONG_REPLACE ARTIST_REPLACE")
        if (count of searchResults) > 0 then
            set foundTrack to item 1 of searchResults
            play foundTrack
            display notification "🎵 Dance floor saved! Restored: SONG_REPLACE by ARTIST_REPLACE" with title "🚨 GRACEFUL RECOVERY"
            return "SUCCESS"
        else
            -- Try just the song name
            set searchResults to (search library 1 for "SONG_REPLACE")
            if (count of searchResults) > 0 then
                set foundTrack to item 1 of searchResults
                play foundTrack
                return "PARTIAL_SUCCESS"
            end if
        end if
    end try
    return "FAILED"
end tell
APPLESCRIPT
            
            sed -i '' "s/SONG_REPLACE/$previous_song/g" "$temp_script"
            sed -i '' "s/ARTIST_REPLACE/$previous_artist/g" "$temp_script"
            
            if osascript "$temp_script" 2>/dev/null; then
                echo -e "${GREEN}✅ Dance floor successfully restored!${NC}"
                rm -f "$temp_script"
                return 0
            fi
            rm -f "$temp_script"
        fi
    fi
    
    # If we can't restore, play something generic to keep the floor moving
    echo -e "${ORANGE}⚠️  Unable to restore previous song, playing emergency track...${NC}"
    osascript -e 'tell application "Music" to play (some track of library playlist 1)' 2>/dev/null || true
    
    return 1
}

# Function to check if song request is a dedication
check_for_dedication() {
    local REQUESTER="$1"
    local SONG_TITLE="$2"
    local ARTIST="$3"
    
    # This should only be shown to the requester, not publicly
    echo -e "${MAGENTA}💌 PRIVATE MESSAGE TO $REQUESTER:${NC}"
    echo -e "${CYAN}Is this song a dedication? (y/n): ${NC}"
    read -p "$(echo -e ${CYAN}Your response: ${NC})" is_dedication
    
    if [[ "$(echo "$is_dedication" | tr '[:upper:]' '[:lower:]')" == "y" || "$(echo "$is_dedication" | tr '[:upper:]' '[:lower:]')" == "yes" ]]; then
        echo -e "${PINK}💕 Who would you like to dedicate this to?${NC}"
        read -p "$(echo -e ${PINK}Dedication to: ${NC})" dedication_to
        
        echo -e "${PINK}💌 Optional dedication message (press Enter to skip):${NC}"
        read -p "$(echo -e ${PINK}Message: ${NC})" dedication_message
        
        # Sanitize input to prevent injection
        dedication_to=$(echo "$dedication_to" | sed 's/[<>&"'"'"'`]//g' | head -c 100)
        dedication_message=$(echo "$dedication_message" | sed 's/[<>&"'"'"'`]//g' | head -c 250)
        
        # Save dedication
        local dedication_id="DED-$(date +%Y%m%d%H%M%S)-$(openssl rand -hex 2 | tr '[:lower:]' '[:upper:]')"
        
        if [ ! -f "$DEDICATION_FILE" ]; then
            echo "[]" > "$DEDICATION_FILE"
        fi
        
        jq ". += [{
            \"id\": \"$dedication_id\",
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
            \"song\": \"$SONG_TITLE\",
            \"artist\": \"$ARTIST\",
            \"from\": \"$REQUESTER\",
            \"to\": \"$dedication_to\",
            \"message\": \"$dedication_message\",
            \"status\": \"active\"
        }]" "$DEDICATION_FILE" > "$DEDICATION_FILE.tmp" && mv "$DEDICATION_FILE.tmp" "$DEDICATION_FILE"
        
        # Notify dedication recipient
        osascript -e "display notification \"$REQUESTER dedicated '$SONG_TITLE' by $ARTIST to you! $dedication_message\" with title \"💕 DEDICATION\" sound name \"Glass\""
        
        echo -e "${GREEN}✅ Dedication saved! $dedication_to will be notified.${NC}"
        return 0
    fi
    
    return 1
}

# Function to handle repeat logic with hilarious messages
handle_song_repeat() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local CURRENT_REPEATS="${3:-0}"
    
    if [ $CURRENT_REPEATS -ge $REPEAT_THRESHOLD ]; then
        local repeat_status="${REPEAT_MESSAGES[$((RANDOM % ${#REPEAT_MESSAGES[@]}))]}"
        
        echo -e "${YELLOW}🔄 Song Status: ${BOLD}$repeat_status${NC}"
        echo -e "${ORANGE}\"$SONG_TITLE\" by $ARTIST has played $CURRENT_REPEATS times${NC}"
        
        # Notify requester with humor
        osascript -e "display notification \"Your song '$SONG_TITLE' is now classified as: $repeat_status\" with title \"🔄 REPEAT STATUS UPDATE\" subtitle \"Played $CURRENT_REPEATS times\""
        
        # Check if there are other requests in queue
        if [ -f "$QUEUE_FILE" ]; then
            local queue_length=$(jq length "$QUEUE_FILE" 2>/dev/null || echo "0")
            if [ "$queue_length" -gt 1 ]; then
                echo -e "${GREEN}Moving to next song in queue...${NC}"
                return 1  # Signal to move to next song
            fi
        fi
    fi
    
    return 0  # Continue repeating
}

# Function to offer donation options
offer_donation() {
    local REQUESTER="$1"
    local SONG_TITLE="$2"
    local REASON="${3:-Song request frustration}"
    
    echo -e "${GOLD}💰 OPTIONAL: Support Your DJ${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}DONATION OPTIONS AVAILABLE:${NC}"
    echo -e "${CYAN}│${NC}   💳 Venmo: @PantherPrideDJ"
    echo -e "${CYAN}│${NC}   💰 PayPal: dj@pantherpride.com"
    echo -e "${CYAN}│${NC}   ☕ Buy Me a Coffee: /pantherpridedj"
    echo -e "${CYAN}│${NC}   🍕 DoorDash Gift Card (DJ gets hungry!)"
    echo -e "${CYAN}│${NC}   🎵 Apple Music Gift Card"
    echo -e "${CYAN}│${NC}   💎 Cash App: \$PantherPrideDJ"
    echo -e "${CYAN}│${NC}   🌟 Patreon: /pantherpridedj"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    
    echo -e "\n${PINK}Would you like to send a tip/donation? (y/n/later): ${NC}"
    read -p "$(echo -e ${PINK}Your choice: ${NC})" donation_choice
    
    case "$(echo "$donation_choice" | tr '[:upper:]' '[:lower:]')" in
        "y"|"yes")
            echo -e "${GREEN}💝 Thank you! Opening donation options...${NC}"
            # Log the intent
            echo "[$(date)] DONATION INTENT: $REQUESTER for '$SONG_TITLE' - Reason: $REASON" >> "$DONATION_LOG"
            
            # Open various donation platforms
            open "https://venmo.com/PantherPrideDJ" 2>/dev/null &
            open "https://www.paypal.me/PantherPrideDJ" 2>/dev/null &
            open "https://www.buymeacoffee.com/pantherpridedj" 2>/dev/null &
            
            osascript -e "display notification \"Donation options opened. Thank you for supporting your DJ! 💰\" with title \"💝 DONATION\" subtitle \"Every tip helps keep the music going!\""
            ;;
        "later")
            echo -e "${YELLOW}💛 No problem! Donation reminder saved for later.${NC}"
            echo "[$(date)] DONATION REMINDER: $REQUESTER for '$SONG_TITLE' - Status: Later" >> "$DONATION_LOG"
            ;;
        *)
            echo -e "${CYAN}💙 No worries! The music is always free. Keep enjoying! 🎵${NC}"
            ;;
    esac
}

# Enhanced song playing with repeat and recovery logic
play_song_with_recovery() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local IS_DEDICATION="${4:-false}"
    
    # Always save backup state before making changes
    save_backup_state
    
    echo -e "${GREEN}🎵 Professional DJ takeover for: ${BOLD}\"$SONG_TITLE\" by $ARTIST${NC}"
    
    # Try to find and play the song
    local temp_script="/tmp/dj_professional_$$.scpt"
    cat > "$temp_script" << 'APPLESCRIPT'
tell application "Music"
    try
        activate
        delay 0.5
        
        -- Search for exact match first
        set searchResults to (search library 1 for "SONG_REPLACE ARTIST_REPLACE")
        
        if (count of searchResults) > 0 then
            set foundTrack to item 1 of searchResults
            play foundTrack
            set song repeat to all  -- Enable repeat for this song
            display notification "🎧 DJ Professional: Now playing SONG_REPLACE by ARTIST_REPLACE" with title "🎵 NOW PLAYING" subtitle "Requested by REQUESTER_REPLACE"
            return "SUCCESS"
        else
            -- Try broader search
            set searchResults to (search library 1 for "SONG_REPLACE")
            if (count of searchResults) > 0 then
                set foundTrack to item 1 of searchResults
                play foundTrack
                set song repeat to all
                display notification "🎧 DJ Professional: Playing closest match - SONG_REPLACE" with title "🎵 CLOSEST MATCH" subtitle "Requested by REQUESTER_REPLACE"
                return "PARTIAL_SUCCESS"
            else
                display notification "Song not found: SONG_REPLACE by ARTIST_REPLACE" with title "🎧 SEARCH FAILED" subtitle "Initiating recovery..."
                return "NOT_FOUND"
            end if
        end if
    on error errMsg
        display notification "Apple Music Error during playback" with title "🎧 ERROR" subtitle "Starting recovery..."
        return "ERROR"
    end try
end tell
APPLESCRIPT
    
    # Replace placeholders
    sed -i '' "s/SONG_REPLACE/$SONG_TITLE/g" "$temp_script"
    sed -i '' "s/ARTIST_REPLACE/$ARTIST/g" "$temp_script"
    sed -i '' "s/REQUESTER_REPLACE/$REQUESTER/g" "$temp_script"
    
    # Execute the script
    local result=$(osascript "$temp_script" 2>/dev/null || echo "FAILED")
    rm -f "$temp_script"
    
    case "$result" in
        "SUCCESS")
            echo -e "${GREEN}✅ Song successfully playing with repeat enabled!${NC}"
            
            # Show dedication if applicable
            if [ "$IS_DEDICATION" = "true" ]; then
                show_dedication_display "$SONG_TITLE" "$ARTIST" "$REQUESTER"
            fi
            
            # Notify user their request is being honored
            osascript -e "display notification \"Your request is now playing: $SONG_TITLE by $ARTIST\" with title \"🎵 REQUEST FULFILLED\" subtitle \"Song will repeat 3 times or until next request\""
            
            return 0
            ;;
        "PARTIAL_SUCCESS")
            echo -e "${ORANGE}⚠️  Playing closest match found${NC}"
            return 0
            ;;
        *)
            echo -e "${RED}❌ Song not found or playback failed${NC}"
            echo -e "${YELLOW}🚨 Initiating graceful recovery...${NC}"
            
            # Attempt graceful recovery
            if graceful_recovery; then
                # Offer donation as apology for the inconvenience
                offer_donation "$REQUESTER" "$SONG_TITLE" "Song not found - DJ apologizes for the inconvenience"
            fi
            
            return 1
            ;;
    esac
}

# Function to display dedication
show_dedication_display() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    
    if [ -f "$DEDICATION_FILE" ]; then
        local latest_dedication=$(jq -r '.[-1] | select(.song == "'"$SONG_TITLE"'" and .artist == "'"$ARTIST"'") | "To: \(.to) | Message: \(.message // "No message")"' "$DEDICATION_FILE" 2>/dev/null)
        
        if [ -n "$latest_dedication" ] && [ "$latest_dedication" != "null" ]; then
            echo -e "\n${PINK}💕 DEDICATION DISPLAY 💕${NC}"
            echo -e "${MAGENTA}┌─────────────────────────────────────────────────────────┐${NC}"
            echo -e "${MAGENTA}│${NC} ${BOLD}\"$SONG_TITLE\" by $ARTIST${NC}"
            echo -e "${MAGENTA}│${NC} ${BOLD}From: ${YELLOW}$REQUESTER${NC}"
            echo -e "${MAGENTA}│${NC} ${BOLD}$latest_dedication${NC}"
            echo -e "${MAGENTA}└─────────────────────────────────────────────────────────┘${NC}"
        fi
    fi
}

# Main enhanced VIP function with all new features
process_professional_vip_request() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local VIP_REASON="$4"
    local PLAY_NOW="${5:-true}"
    
    clear
    echo -e "${GOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║      🎧 PROFESSIONAL DJ RECOVERY SYSTEM v7.0           ║${NC}"
    echo -e "${GOLD}║  * NO DANCE FLOOR CLEARING * DEDICATIONS * DONATIONS *  ║${NC}"
    echo -e "${GOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    
    # Check for dedication (private to requester only)
    local is_dedication=false
    if check_for_dedication "$REQUESTER" "$SONG_TITLE" "$ARTIST"; then
        is_dedication=true
    fi
    
    # Set volume for optimal experience
    echo -e "\n${YELLOW}🔊 Setting volume to ${VOLUME_LEVEL}% for optimal dance floor experience...${NC}"
    osascript -e "set volume output volume $VOLUME_LEVEL"
    
    if [ "$PLAY_NOW" = "true" ]; then
        echo -e "\n${GOLD}🚀 Processing professional VIP request...${NC}"
        
        # Attempt to play the song with recovery
        if play_song_with_recovery "$SONG_TITLE" "$ARTIST" "$REQUESTER" "$is_dedication"; then
            echo -e "${GREEN}✅ Professional DJ service delivered!${NC}"
        else
            echo -e "${ORANGE}⚠️  Request handled with graceful recovery${NC}"
            # Still offer donation for the inconvenience
            offer_donation "$REQUESTER" "$SONG_TITLE" "Technical difficulties - DJ service recovery"
        fi
    fi
    
    # Log the enhanced action
    echo "[$(date)] PROFESSIONAL VIP: $SONG_TITLE by $ARTIST from $REQUESTER - Dedication: $is_dedication - Reason: $VIP_REASON" >> "$HOME/.dj_professional.log"
    
    echo -e "\n${BLINK}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}✅ PROFESSIONAL DJ SERVICE COMPLETE${NC}                    ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}Dance floor status: ACTIVE${NC}                            ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}Recovery system: ARMED${NC}                               ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}Donation system: AVAILABLE${NC}                          ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    
    return 0
}

# Emergency dance floor rescue function
emergency_dance_floor_rescue() {
    echo -e "${RED}🚨 EMERGENCY DANCE FLOOR RESCUE ACTIVATED! 🚨${NC}"
    
    if graceful_recovery; then
        echo -e "${GREEN}✅ Dance floor successfully rescued!${NC}"
    else
        echo -e "${ORANGE}⚠️  Playing emergency backup track...${NC}"
        osascript -e 'tell application "Music" to play (some track of library playlist 1)' 2>/dev/null
    fi
}

# Function to show current status with repeat tracking
show_professional_status() {
    echo -e "${BOLD}${CYAN}📊 PROFESSIONAL DJ STATUS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    
    local state=$(osascript -e 'tell application "Music" to get player state' 2>/dev/null || echo "unknown")
    local track=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null || echo "None")
    local artist=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null || echo "Unknown")
    local repeat_mode=$(osascript -e 'tell application "Music" to get song repeat' 2>/dev/null || echo "off")
    
    echo -e "${YELLOW}State: ${BOLD}$state${NC}"
    echo -e "${YELLOW}Track: ${BOLD}$track${NC}"
    echo -e "${YELLOW}Artist: ${BOLD}$artist${NC}"
    echo -e "${YELLOW}Repeat Mode: ${BOLD}$repeat_mode${NC}"
    
    # Check for active dedications
    if [ -f "$DEDICATION_FILE" ]; then
        local active_dedications=$(jq '[.[] | select(.status == "active")] | length' "$DEDICATION_FILE" 2>/dev/null || echo "0")
        echo -e "${PINK}Active Dedications: ${BOLD}$active_dedications${NC}"
    fi
    
    # Show backup status
    if [ -f "$BACKUP_STATE_FILE" ]; then
        local backup_available=$(jq -r '.recovery_available' "$BACKUP_STATE_FILE" 2>/dev/null || echo "false")
        echo -e "${CYAN}Recovery Available: ${BOLD}$backup_available${NC}"
    fi
    
    echo -e "\n${BOLD}${GREEN}🕺 Dance Floor Status: ${BOLD}PROTECTED${NC}"
}

# Main execution
case "${1:-help}" in
    vip)
        process_professional_vip_request "${2:-Music}" "${3:-Madonna}" "${4:-Madonna}" "${5:-VIP Professional Request}" "${6:-true}"
        ;;
    play)
        play_song_with_recovery "${2:-Unknown Song}" "${3:-Unknown Artist}" "${4:-DJ System}" "false"
        ;;
    rescue)
        emergency_dance_floor_rescue
        ;;
    status)
        show_professional_status
        ;;
    dedication)
        check_for_dedication "${2:-Anonymous}" "${3:-Unknown Song}" "${4:-Unknown Artist}"
        ;;
    donate)
        offer_donation "${2:-Anonymous}" "${3:-General Support}" "${4:-Supporting the DJ}"
        ;;
    recovery)
        graceful_recovery
        ;;
    *)
        echo "Usage: $0 {vip|play|rescue|status|dedication|donate|recovery} [song] [artist] [requester] [reason]"
        echo ""
        echo "Commands:"
        echo "  vip        - Full professional VIP request with all features"
        echo "  play       - Play song with recovery protection"
        echo "  rescue     - Emergency dance floor rescue"
        echo "  status     - Show professional DJ status"
        echo "  dedication - Test dedication system"
        echo "  donate     - Show donation options"
        echo "  recovery   - Manual graceful recovery"
        echo ""
        echo "Example: $0 vip \"Music\" \"Madonna\" \"Madonna\" \"VIP Request\""
        exit 1
        ;;
esac
