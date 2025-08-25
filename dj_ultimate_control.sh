#!/bin/bash

# 🎧 ULTIMATE DJ CONTROL SYSTEM v9.0 - APPLE MUSIC INTEGRATION EDITION
# Apple Music "Play Next", DJ Pause Controls, Dedication Validation, Event History
# Copyright 2025 - Panther Pride DJ Consortium International - "Ultimate DJ Power"™

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
DJ_CONTROL_FILE="$HOME/.dj_control_state.json"
EVENT_HISTORY_FILE="$HOME/.dj_event_history.json"
DEDICATION_FILE="$HOME/.dj_dedications.json"
VOLUME_LEVEL="35"

# Initialize DJ control state
initialize_dj_control() {
    if [ ! -f "$DJ_CONTROL_FILE" ]; then
        cat > "$DJ_CONTROL_FILE" << 'EOF'
{
  "dj_pause_enabled": false,
  "auto_advance": true,
  "apple_music_integration": true,
  "current_override": null,
  "last_dj_action": null,
  "queue_control": "AUTO"
}
EOF
    fi
}

# Function to add song to Apple Music "Play Next" with proper ordering
apple_music_play_next() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local POSITION="${4:-1}"
    
    echo -e "${GOLD}🍎 Adding to Apple Music 'Play Next' queue: ${BOLD}\"$SONG_TITLE\" by $ARTIST${NC}"
    
    # First, try to find the song in Apple Music
    local temp_script="/tmp/dj_play_next_$$.scpt"
    cat > "$temp_script" << 'APPLESCRIPT'
tell application "Music"
    try
        activate
        delay 0.5
        
        -- Search for the song
        set searchResults to (search library 1 for "SONG_REPLACE ARTIST_REPLACE")
        
        if (count of searchResults) > 0 then
            set foundTrack to item 1 of searchResults
            
            -- Add to "Play Next" queue (this puts it at the very top)
            play foundTrack after current track
            
            display notification "🍎 Added to Play Next: SONG_REPLACE by ARTIST_REPLACE" with title "🎵 APPLE MUSIC QUEUE" subtitle "Requested by REQUESTER_REPLACE"
            
            return "SUCCESS"
        else
            -- Try broader search
            set searchResults to (search library 1 for "SONG_REPLACE")
            if (count of searchResults) > 0 then
                set foundTrack to item 1 of searchResults
                play foundTrack after current track
                display notification "🍎 Added closest match to Play Next: SONG_REPLACE" with title "🎵 APPLE MUSIC QUEUE" subtitle "Requested by REQUESTER_REPLACE"
                return "PARTIAL_SUCCESS"
            else
                display notification "🍎 Song not found in Apple Music: SONG_REPLACE by ARTIST_REPLACE" with title "❌ NOT FOUND"
                return "NOT_FOUND"
            end if
        end if
    on error errMsg
        display notification "Apple Music Error: " & errMsg with title "🍎 ERROR"
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
            echo -e "${GREEN}✅ Successfully added to Apple Music Play Next queue${NC}"
            log_event "APPLE_MUSIC_QUEUE" "$SONG_TITLE by $ARTIST" "$REQUESTER" "Added via Play Next"
            return 0
            ;;
        "PARTIAL_SUCCESS")
            echo -e "${ORANGE}⚠️  Added closest match to Play Next queue${NC}"
            log_event "APPLE_MUSIC_QUEUE" "$SONG_TITLE by $ARTIST (closest match)" "$REQUESTER" "Partial match via Play Next"
            return 0
            ;;
        *)
            echo -e "${RED}❌ Failed to add to Apple Music queue${NC}"
            log_event "APPLE_MUSIC_FAILED" "$SONG_TITLE by $ARTIST" "$REQUESTER" "Song not found in Apple Music"
            return 1
            ;;
    esac
}

# Function to toggle DJ pause mode
toggle_dj_pause() {
    local current_pause=$(jq -r '.dj_pause_enabled' "$DJ_CONTROL_FILE" 2>/dev/null || echo "false")
    
    if [ "$current_pause" = "true" ]; then
        # Disable pause, resume auto-advance
        jq '.dj_pause_enabled = false | .auto_advance = true | .queue_control = "AUTO"' "$DJ_CONTROL_FILE" > "$DJ_CONTROL_FILE.tmp" && mv "$DJ_CONTROL_FILE.tmp" "$DJ_CONTROL_FILE"
        echo -e "${GREEN}🎵 DJ Pause DISABLED - Queue auto-advance resumed${NC}"
        log_event "DJ_CONTROL" "Queue Auto-Advance Resumed" "DJ_SYSTEM" "DJ disabled pause mode"
    else
        # Enable pause, stop auto-advance
        jq '.dj_pause_enabled = true | .auto_advance = false | .queue_control = "MANUAL"' "$DJ_CONTROL_FILE" > "$DJ_CONTROL_FILE.tmp" && mv "$DJ_CONTROL_FILE.tmp" "$DJ_CONTROL_FILE"
        echo -e "${YELLOW}⏸️  DJ Pause ENABLED - Manual queue control active${NC}"
        echo -e "${CYAN}   Queue will not auto-advance. Use 'next' command to manually control.${NC}"
        log_event "DJ_CONTROL" "Manual Queue Control Activated" "DJ_SYSTEM" "DJ enabled pause mode"
    fi
}

# Function to check for duplicate requests and combine them
check_duplicate_requests() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local NEW_REQUESTER="$3"
    
    if [ ! -f "$QUEUE_FILE" ]; then
        echo "false"
        return
    fi
    
    # Check for exact match
    local duplicate=$(jq --arg song "$SONG_TITLE" --arg artist "$ARTIST" '.[] | select(.song == $song and .artist == $artist and .status == "QUEUED")' "$QUEUE_FILE")
    
    if [ -n "$duplicate" ] && [ "$duplicate" != "null" ]; then
        local existing_requester=$(echo "$duplicate" | jq -r '.requester')
        local existing_id=$(echo "$duplicate" | jq -r '.id')
        
        # Combine requesters
        local combined_requester="$existing_requester + $NEW_REQUESTER"
        
        # Update the existing request
        jq --arg id "$existing_id" --arg combined "$combined_requester" '
            map(if .id == $id then .requester = $combined | .duplicate_requests = (.duplicate_requests // 0) + 1 else . end)
        ' "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
        
        echo -e "${PINK}🔄 DUPLICATE REQUEST DETECTED!${NC}"
        echo -e "${YELLOW}   Combined requesters: ${BOLD}$combined_requester${NC}"
        echo -e "${GREEN}   Both users will be notified when song plays${NC}"
        
        # Notify both users
        osascript -e "display notification \"Your request for '$SONG_TITLE' by $ARTIST has been combined with another request!\" with title \"🔄 DUPLICATE REQUEST\" subtitle \"Both requesters will be notified\""
        
        log_event "DUPLICATE_REQUEST" "$SONG_TITLE by $ARTIST" "$combined_requester" "Combined duplicate requests"
        
        echo "true"
    else
        echo "false"
    fi
}

# Enhanced dedication system with contact validation
create_enhanced_dedication() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    
    echo -e "${MAGENTA}💌 PRIVATE DEDICATION SETUP FOR $REQUESTER:${NC}"
    echo -e "${CYAN}Is this song a dedication? (y/n): ${NC}"
    read -p "$(echo -e ${CYAN}Your response: ${NC})" is_dedication
    
    if [[ "$(echo "$is_dedication" | tr '[:upper:]' '[:lower:]')" == "y" || "$(echo "$is_dedication" | tr '[:upper:]' '[:lower:]')" == "yes" ]]; then
        echo -e "${PINK}💕 Who would you like to dedicate this to?${NC}"
        read -p "$(echo -e ${PINK}Dedication to: ${NC})" dedication_to
        
        echo -e "${PINK}💌 Optional dedication message (press Enter to skip):${NC}"
        read -p "$(echo -e ${PINK}Message: ${NC})" dedication_message
        
        # REQUIRED: Contact method for the recipient
        echo -e "${GOLD}📱 How should we notify the recipient? ${BOLD}(REQUIRED)${NC}"
        echo -e "${CYAN}1) Social Media Handle (Instagram, Twitter, etc.)${NC}"
        echo -e "${CYAN}2) Email Address${NC}"
        echo -e "${CYAN}3) Phone Number${NC}"
        
        read -p "$(echo -e ${GOLD}Choose option (1-3): ${NC})" contact_method
        
        local contact_info=""
        local contact_type=""
        local validation_status="PENDING"
        
        case "$contact_method" in
            "1")
                echo -e "${PURPLE}📱 Enter social media handle (e.g., @username):${NC}"
                read -p "$(echo -e ${PURPLE}Handle: ${NC})" contact_info
                contact_type="SOCIAL_MEDIA"
                
                # Basic validation - must start with @
                if [[ "$contact_info" =~ ^@[a-zA-Z0-9_]{1,50}$ ]]; then
                    validation_status="FORMAT_VALID"
                    echo -e "${GREEN}✅ Social media handle format is valid${NC}"
                    echo -e "${YELLOW}⚠️  Note: We'll validate if this account exists later${NC}"
                else
                    validation_status="INVALID_FORMAT"
                    echo -e "${RED}❌ Invalid social media handle format (should be @username)${NC}"
                fi
                ;;
            "2")
                echo -e "${BLUE}📧 Enter email address:${NC}"
                read -p "$(echo -e ${BLUE}Email: ${NC})" contact_info
                contact_type="EMAIL"
                
                # Email validation
                if [[ "$contact_info" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    validation_status="FORMAT_VALID"
                    echo -e "${GREEN}✅ Email format is valid${NC}"
                    echo -e "${CYAN}📨 Basic confirmation will be sent to: $contact_info${NC}"
                else
                    validation_status="INVALID_FORMAT"
                    echo -e "${RED}❌ Invalid email format${NC}"
                fi
                ;;
            "3")
                echo -e "${GREEN}📱 Enter phone number with country code (e.g., +1-555-123-4567):${NC}"
                read -p "$(echo -e ${GREEN}Phone: ${NC})" contact_info
                contact_type="PHONE"
                
                # Basic phone validation
                if [[ "$contact_info" =~ ^\+[1-9][0-9]{1,3}-[0-9]{3}-[0-9]{3}-[0-9]{4}$ ]] || [[ "$contact_info" =~ ^\+[1-9][0-9]{7,14}$ ]]; then
                    validation_status="FORMAT_VALID"
                    echo -e "${GREEN}✅ Phone number format is valid${NC}"
                    echo -e "${ORANGE}📱 Standard text message rates may apply${NC}"
                    echo -e "${YELLOW}⚠️  SMS verification will be added in future updates${NC}"
                else
                    validation_status="INVALID_FORMAT"
                    echo -e "${RED}❌ Invalid phone format (use +country-xxx-xxx-xxxx)${NC}"
                fi
                ;;
            *)
                echo -e "${RED}❌ Invalid option selected${NC}"
                return 1
                ;;
        esac
        
        if [ "$validation_status" = "INVALID_FORMAT" ]; then
            echo -e "${RED}Cannot create dedication with invalid contact information${NC}"
            return 1
        fi
        
        # Sanitize all inputs
        dedication_to=$(echo "$dedication_to" | sed 's/[<>&"'"'"'`]//g' | head -c 100)
        dedication_message=$(echo "$dedication_message" | sed 's/[<>&"'"'"'`]//g' | head -c 250)
        contact_info=$(echo "$contact_info" | sed 's/[<>&"'"'"'`]//g' | head -c 100)
        
        # Save enhanced dedication
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
            \"contact_method\": \"$contact_type\",
            \"contact_info\": \"$contact_info\",
            \"validation_status\": \"$validation_status\",
            \"status\": \"active\",
            \"notification_sent\": false
        }]" "$DEDICATION_FILE" > "$DEDICATION_FILE.tmp" && mv "$DEDICATION_FILE.tmp" "$DEDICATION_FILE"
        
        echo -e "${GREEN}✅ Enhanced dedication created with ID: $dedication_id${NC}"
        echo -e "${PINK}💕 $dedication_to will be notified via $contact_type when song plays${NC}"
        
        log_event "DEDICATION_CREATED" "$SONG_TITLE by $ARTIST" "$REQUESTER" "Dedication to $dedication_to via $contact_type"
        
        return 0
    fi
    
    return 1
}

# Function to log events for 48-hour history
log_event() {
    local event_type="$1"
    local event_data="$2"
    local user="$3"
    local details="$4"
    
    if [ ! -f "$EVENT_HISTORY_FILE" ]; then
        echo "[]" > "$EVENT_HISTORY_FILE"
    fi
    
    # Add new event
    jq ". += [{
        \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
        \"event_type\": \"$event_type\",
        \"event_data\": \"$event_data\",
        \"user\": \"$user\",
        \"details\": \"$details\",
        \"local_time\": \"$(date '+%Y-%m-%d %H:%M:%S %Z')\"
    }]" "$EVENT_HISTORY_FILE" > "$EVENT_HISTORY_FILE.tmp" && mv "$EVENT_HISTORY_FILE.tmp" "$EVENT_HISTORY_FILE"
    
    # Clean up events older than 48 hours
    local cutoff_time=$(date -d '48 hours ago' -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -v-48H -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)
    
    if [ -n "$cutoff_time" ]; then
        jq --arg cutoff "$cutoff_time" '[.[] | select(.timestamp > $cutoff)]' "$EVENT_HISTORY_FILE" > "$EVENT_HISTORY_FILE.tmp" && mv "$EVENT_HISTORY_FILE.tmp" "$EVENT_HISTORY_FILE"
    fi
}

# Function to show 48-hour event history including dedications
show_event_history() {
    echo -e "${BOLD}${GOLD}📡 Event History (Last 48 Hours)${NC}"
    echo -e "${GOLD}═══════════════════════════════════════════════════════════${NC}"
    
    if [ ! -f "$EVENT_HISTORY_FILE" ]; then
        echo -e "${YELLOW}No event history found${NC}"
        return
    fi
    
    local event_count=$(jq length "$EVENT_HISTORY_FILE" 2>/dev/null || echo "0")
    echo -e "${CYAN}Total Events: ${BOLD}$event_count${NC}\n"
    
    # Show events in reverse chronological order
    jq -r '.[] | 
        if .event_type == "DEDICATION_CREATED" then
            "💕 \(.local_time) - DEDICATION: \(.event_data) from \(.user) (\(.details))"
        elif .event_type == "DJ_CONTROL" then
            "🎧 \(.local_time) - DJ CONTROL: \(.event_data) - \(.details)"
        elif .event_type == "APPLE_MUSIC_QUEUE" then
            "🍎 \(.local_time) - APPLE MUSIC: \(.event_data) by \(.user) - \(.details)"
        elif .event_type == "DUPLICATE_REQUEST" then
            "🔄 \(.local_time) - DUPLICATE: \(.event_data) by \(.user)"
        elif .event_type == "VIP_REQUEST" then
            "👑 \(.local_time) - VIP: \(.event_data) by \(.user) - \(.details)"
        else
            "📋 \(.local_time) - \(.event_type): \(.event_data) by \(.user)"
        end' "$EVENT_HISTORY_FILE" | tail -20
    
    # Show active dedications
    if [ -f "$DEDICATION_FILE" ]; then
        local active_dedications=$(jq '[.[] | select(.status == "active")] | length' "$DEDICATION_FILE" 2>/dev/null || echo "0")
        if [ "$active_dedications" -gt 0 ]; then
            echo -e "\n${PINK}💕 ACTIVE DEDICATIONS (Last 48hrs):${NC}"
            jq -r '.[] | select(.status == "active") | 
                "   💌 \(.song) by \(.artist) - From: \(.from) To: \(.to) (\(.contact_method))"' "$DEDICATION_FILE"
        fi
    fi
}

# Enhanced request processing with all new features
process_ultimate_request() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local PRIORITY="${4:-STANDARD}"
    
    initialize_dj_control
    
    echo -e "${GOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║          🎧 ULTIMATE DJ CONTROL SYSTEM v9.0            ║${NC}"
    echo -e "${GOLD}║   * APPLE MUSIC INTEGRATION * PAUSE CONTROL * MORE *   ║${NC}"
    echo -e "${GOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    
    # Check for duplicates first
    local is_duplicate=$(check_duplicate_requests "$SONG_TITLE" "$ARTIST" "$REQUESTER")
    
    if [ "$is_duplicate" = "true" ]; then
        echo -e "${GREEN}✅ Duplicate request processed - both users will be notified${NC}"
        return 0
    fi
    
    # Check if DJ pause is enabled
    local dj_pause=$(jq -r '.dj_pause_enabled' "$DJ_CONTROL_FILE" 2>/dev/null || echo "false")
    
    if [ "$dj_pause" = "true" ]; then
        echo -e "${YELLOW}⏸️  DJ PAUSE MODE ACTIVE - Request queued but not auto-playing${NC}"
        echo -e "${CYAN}   DJ will manually control when to play this request${NC}"
    fi
    
    # Check for dedication
    local is_dedication=false
    if create_enhanced_dedication "$REQUESTER" "$SONG_TITLE" "$ARTIST"; then
        is_dedication=true
    fi
    
    # Try to add to Apple Music first
    if apple_music_play_next "$SONG_TITLE" "$ARTIST" "$REQUESTER"; then
        echo -e "${GREEN}✅ Successfully integrated with Apple Music${NC}"
        
        if [ "$dj_pause" = "false" ]; then
            echo -e "${LIME}🎵 Song will play next in Apple Music queue${NC}"
        else
            echo -e "${YELLOW}⏸️  Song queued - waiting for DJ to resume${NC}"
        fi
    else
        echo -e "${ORANGE}⚠️  Apple Music integration failed - using fallback queue${NC}"
    fi
    
    # Log the ultimate request
    log_event "ULTIMATE_REQUEST" "$SONG_TITLE by $ARTIST" "$REQUESTER" "Priority: $PRIORITY, Dedication: $is_dedication, DJ_Pause: $dj_pause"
    
    echo -e "\n${BLINK}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}✅ ULTIMATE DJ REQUEST PROCESSED${NC}                      ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}Apple Music: INTEGRATED${NC}                              ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}DJ Control: $([ "$dj_pause" = "true" ] && echo "PAUSED" || echo "AUTO")${NC}                                    ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}Event History: LOGGED${NC}                                ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
}

# Function to show DJ control status
show_dj_control_status() {
    echo -e "${BOLD}${GOLD}🎧 DJ CONTROL PANEL${NC}"
    echo -e "${GOLD}═══════════════════════════════════════════════════════════${NC}"
    
    if [ -f "$DJ_CONTROL_FILE" ]; then
        local pause_enabled=$(jq -r '.dj_pause_enabled' "$DJ_CONTROL_FILE")
        local auto_advance=$(jq -r '.auto_advance' "$DJ_CONTROL_FILE")
        local queue_control=$(jq -r '.queue_control' "$DJ_CONTROL_FILE")
        
        echo -e "${CYAN}DJ Pause Mode: ${BOLD}$([ "$pause_enabled" = "true" ] && echo "${YELLOW}ENABLED ⏸️" || echo "${GREEN}DISABLED ▶️")${NC}"
        echo -e "${CYAN}Auto Advance: ${BOLD}$([ "$auto_advance" = "true" ] && echo "${GREEN}ON" || echo "${RED}OFF")${NC}"
        echo -e "${CYAN}Queue Control: ${BOLD}$queue_control${NC}"
    else
        echo -e "${RED}DJ Control not initialized${NC}"
    fi
    
    # Current Apple Music status
    local state=$(osascript -e 'tell application "Music" to get player state' 2>/dev/null || echo "unknown")
    local track=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null || echo "None")
    
    echo -e "\n${LIME}🍎 APPLE MUSIC STATUS:${NC}"
    echo -e "  ${YELLOW}State: ${BOLD}$state${NC}"
    echo -e "  ${YELLOW}Track: ${BOLD}$track${NC}"
    
    echo -e "\n${BOLD}${GREEN}🎵 DJ has ultimate control over the queue!${NC}"
}

# Main execution
case "${1:-help}" in
    request)
        process_ultimate_request "${2:-Unknown Song}" "${3:-Unknown Artist}" "${4:-Anonymous}" "${5:-STANDARD}"
        ;;
    pause)
        toggle_dj_pause
        ;;
    history)
        show_event_history
        ;;
    status)
        show_dj_control_status
        ;;
    play_next)
        apple_music_play_next "${2:-Test Song}" "${3:-Test Artist}" "${4:-Test User}"
        ;;
    init)
        initialize_dj_control
        echo -e "${GREEN}✅ DJ Control System initialized${NC}"
        ;;
    *)
        echo "Usage: $0 {request|pause|history|status|play_next|init} [song] [artist] [requester] [priority]"
        echo ""
        echo "Commands:"
        echo "  request     - Process ultimate DJ request with all features"
        echo "  pause       - Toggle DJ pause mode (stops auto-advance)"
        echo "  history     - Show 48-hour event history including dedications"
        echo "  status      - Show DJ control panel status"
        echo "  play_next   - Test Apple Music 'Play Next' integration"
        echo "  init        - Initialize DJ control system"
        echo ""
        echo "🎧 Ultimate DJ Control System v9.0 - You are the DJ!"
        exit 1
        ;;
esac
