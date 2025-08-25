#!/bin/bash

# 🎧 INDUSTRIAL GRADE DJ NOTIFICATION SYSTEM v4.0 TMUX EDITION
# Multi-Terminal, Multi-VLAN, Global Location, High-Powered Light Setup Integration
# Copyright 2025 - Panther Pride DJ Consortium International

# ANSI Color codes for terminal rave
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RAINBOW='\033[38;5;196m'
NC='\033[0m' # No Color
BOLD='\033[1m'
BLINK='\033[5m'

# DJ Queue Database
QUEUE_FILE="$HOME/.dj_queue.json"
NOTIFICATION_LOG="$HOME/.dj_notifications.log"
VLAN_CONFIG="$HOME/.vlan_routing.conf"

# Function to check if tmux is running
is_tmux_running() {
    tmux list-sessions &>/dev/null
}

# Function to broadcast to all tmux windows and panes
broadcast_to_tmux() {
    local message="$1"
    local priority="$2"
    
    if is_tmux_running; then
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║         BROADCASTING TO ALL TMUX SESSIONS               ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
        
        # Get all tmux sessions, windows, and panes
        local sessions=$(tmux list-sessions -F '#{session_name}')
        local broadcast_count=0
        
        for session in $sessions; do
            echo -ne "${GREEN}► Session: $session"
            
            # Get windows for this session
            local windows=$(tmux list-windows -t "$session" -F '#{window_index}')
            
            for window in $windows; do
                # Get panes for this window
                local panes=$(tmux list-panes -t "$session:$window" -F '#{pane_index}')
                
                for pane in $panes; do
                    # Send the notification command to each pane
                    tmux send-keys -t "$session:$window.$pane" C-c 2>/dev/null || true
                    tmux send-keys -t "$session:$window.$pane" "clear" C-m 2>/dev/null || true
                    
                    # Send a compact notification display
                    tmux send-keys -t "$session:$window.$pane" "echo -e '${BLINK}${RED}🎧 NEW DJ REQUEST 🎧${NC}'" C-m 2>/dev/null || true
                    tmux send-keys -t "$session:$window.$pane" "echo -e '${YELLOW}$message${NC}'" C-m 2>/dev/null || true
                    tmux send-keys -t "$session:$window.$pane" "echo -e '${GREEN}Priority: $priority | Queue Position: #$(jq length "$QUEUE_FILE" 2>/dev/null || echo "1")${NC}'" C-m 2>/dev/null || true
                    tmux send-keys -t "$session:$window.$pane" "echo -e '${CYAN}═══════════════════════════════════════${NC}'" C-m 2>/dev/null || true
                    
                    ((broadcast_count++))
                done
            done
            
            echo -e " ${BOLD}[SYNCED - $broadcast_count panes]${NC}"
        done
        
        # Also trigger tmux visual bell in all panes
        tmux display-message -a "🎧 NEW DJ REQUEST: $message"
        
        echo -e "${YELLOW}Total broadcasts sent: ${BOLD}$broadcast_count${NC} panes across ${BOLD}$(echo "$sessions" | wc -l)${NC} sessions"
    else
        echo -e "${YELLOW}⚠️  No tmux sessions found - skipping tmux broadcast${NC}"
    fi
}

# Function to create a persistent tmux notification window
create_tmux_notification_window() {
    if is_tmux_running; then
        # Create a dedicated notification window if it doesn't exist
        if ! tmux list-windows -a | grep -q "dj-notifications"; then
            tmux new-window -d -n "dj-notifications" "bash $0 monitor_tmux"
            echo -e "${GREEN}✅ Created dedicated tmux notification window${NC}"
        fi
    fi
}

# Function to monitor and display queue in tmux
monitor_tmux() {
    echo -e "${BOLD}${PURPLE}🎧 DJ NOTIFICATION MONITOR - TMUX EDITION 🎧${NC}"
    echo -e "${CYAN}Monitoring queue for real-time updates...${NC}\n"
    
    while true; do
        clear
        echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${BOLD}${CYAN}    🎧 LIVE DJ QUEUE MONITOR - $(date '+%H:%M:%S')${NC}"
        echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}\n"
        
        if [ -f "$QUEUE_FILE" ]; then
            local queue_length=$(jq length "$QUEUE_FILE" 2>/dev/null || echo "0")
            echo -e "${BOLD}Current Queue Size: ${GREEN}$queue_length requests${NC}\n"
            
            if [ "$queue_length" -gt 0 ]; then
                echo -e "${YELLOW}📋 ACTIVE REQUESTS:${NC}"
                jq -r '.[] | "  \(.position). \(.song) by \(.artist) - \(.requester) [\(.priority)]"' "$QUEUE_FILE" 2>/dev/null || echo "  Error reading queue"
            else
                echo -e "${GRAY}No requests in queue${NC}"
            fi
        else
            echo -e "${GRAY}Queue file not found${NC}"
        fi
        
        echo -e "\n${CYAN}Press Ctrl+C to exit monitor${NC}"
        sleep 5
    done
}

# Function to simulate strobe light effect in terminal
strobe_effect() {
    for i in {1..10}; do
        printf "\r${BLINK}⚡💡⚡💡⚡💡⚡💡⚡💡⚡💡⚡💡⚡💡⚡💡⚡💡⚡${NC}"
        sleep 0.1
        printf "\r                                          "
        sleep 0.1
    done
    echo ""
}

# Function to show ASCII DJ booth
show_dj_booth() {
    cat << 'EOF'
    ╔═══════════════════════════════════════════════════════════════╗
    ║  🎧 PROFESSIONAL DJ QUEUE MANAGEMENT SYSTEM v4.0 TMUX       ║
    ║      * MULTI-TERMINAL * MULTI-VLAN * INDUSTRIAL GRADE *      ║
    ╚═══════════════════════════════════════════════════════════════╝
    
         ┌─────────────────────────────────────────────────┐
         │ ╔═══╗ ╔═══╗  ╔════════════════════╗  ╔═══╗ ╔═══╗│
         │ ║ ◯ ║ ║ ◯ ║  ║  ▶ NOW PLAYING ◀  ║  ║ ◯ ║ ║ ◯ ║│
         │ ╚═══╝ ╚═══╝  ╚════════════════════╝  ╚═══╝ ╚═══╝│
         │ ┌───┐ ┌───┐  ╔════════════════════╗  ┌───┐ ┌───┐│
         │ │▓▓▓│ │▓▓▓│  ║  MIXING CONSOLE    ║  │▓▓▓│ │▓▓▓│
         │ └───┘ └───┘  ╚════════════════════╝  └───┘ └───┘│
         │  [■][■][■]    ◄◄  ■  ▶▶    [■][■][■]            │
         └─────────────────────────────────────────────────┘
                    ╱│╲  TMUX BROADCAST  ╱│╲
                   ╱ │ ╲    ENABLED     ╱ │ ╲
                  ╱  │  ╲              ╱  │  ╲
EOF
}

# Function to generate unique request ID with timestamp
generate_request_id() {
    echo "REQ-$(date +%Y%m%d)-$(date +%H%M%S)-$(openssl rand -hex 4 | tr '[:lower:]' '[:upper:]')"
}

# Function to calculate queue position
calculate_queue_position() {
    local current_queue=$(jq length "$QUEUE_FILE" 2>/dev/null || echo "0")
    echo $((current_queue + 1))
}

# Main notification function with tmux integration
notify_dj_request() {
    local SONG_TITLE="$1"
    local ARTIST="$2"
    local REQUESTER="$3"
    local PRIORITY="${4:-STANDARD}"
    
    # Generate unique request ID
    REQUEST_ID=$(generate_request_id)
    QUEUE_POS=$(calculate_queue_position)
    
    # Clear screen for dramatic effect
    clear
    
    # Show DJ booth ASCII art
    show_dj_booth
    
    # Initial strobe effect
    strobe_effect
    
    # Main notification display
    echo -e "\n${BLINK}${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}  ${BLINK}${YELLOW}⚠️  NEW DJ REQUEST INCOMING ⚠️${NC}                                ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}\n"
    
    # Request details
    echo -e "${BOLD}${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}REQUEST ID:${NC} ${YELLOW}$REQUEST_ID${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}TIMESTAMP:${NC}  $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo -e "${CYAN}│${NC} ${BOLD}QUEUE POS:${NC}  #${QUEUE_POS}"
    echo -e "${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${BOLD}${PURPLE}🎵 TRACK DETAILS${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Song:${NC}    ${GREEN}$SONG_TITLE${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Artist:${NC}  ${GREEN}$ARTIST${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Requested By:${NC} ${YELLOW}$REQUESTER${NC}"
    echo -e "${CYAN}│${NC}   ${BOLD}Priority:${NC} ${RED}$PRIORITY${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
    
    # Broadcast to tmux sessions
    echo ""
    broadcast_to_tmux "$SONG_TITLE by $ARTIST" "$PRIORITY"
    
    # Original VLAN broadcast (keeping for show)
    echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         BROADCASTING TO GLOBAL DJ NETWORK               ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    
    for vlan in "VLAN-100-NYC" "VLAN-200-LAX" "VLAN-300-MIA" "VLAN-400-CHI" "VLAN-500-ATL"; do
        echo -ne "${GREEN}► Routing to $vlan"
        for i in {1..3}; do
            echo -n "."
            sleep 0.1
        done
        echo -e " ${BOLD}[SYNCED]${NC}"
    done
    
    # Desktop notification (if available)
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$SONG_TITLE by $ARTIST\" with title \"🎧 NEW DJ REQUEST\" subtitle \"Queue Position: #$QUEUE_POS\" sound name \"Glass\""
    fi
    
    # Terminal bell
    echo -e "\a"
    
    # Save to queue file
    if [ ! -f "$QUEUE_FILE" ]; then
        echo "[]" > "$QUEUE_FILE"
    fi
    
    jq ". += [{
        \"id\": \"$REQUEST_ID\",
        \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
        \"position\": $QUEUE_POS,
        \"song\": \"$SONG_TITLE\",
        \"artist\": \"$ARTIST\",
        \"requester\": \"$REQUESTER\",
        \"priority\": \"$PRIORITY\",
        \"status\": \"QUEUED\",
        \"vlan_sync\": true,
        \"tmux_broadcast\": true,
        \"light_show\": \"PROGRAMMED\"
    }]" "$QUEUE_FILE" > "$QUEUE_FILE.tmp" && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
    
    # Log notification
    echo "[$(date)] Request $REQUEST_ID: $SONG_TITLE by $ARTIST from $REQUESTER (TMUX BROADCAST)" >> "$NOTIFICATION_LOG"
    
    # Final confirmation
    echo -e "\n${BLINK}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}✅ REQUEST SUCCESSFULLY QUEUED & BROADCASTED${NC}           ${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}  ${BOLD}Estimated Wait Time: $(shuf -n1 -e "3" "5" "7" "10") minutes${NC}                    ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    
    # Professional sign-off
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}    Thank you for using Panther Pride DJ Services${NC}"
    echo -e "${BOLD}      \"Where Every Beat Matters Globally\"™${NC}"
    echo -e "${BOLD}         TMUX Edition - Multi-Terminal Ready${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}\n"
}

# Main execution
case "${1:-notify}" in
    notify)
        notify_dj_request "${2:-Unknown Song}" "${3:-Unknown Artist}" "${4:-Anonymous}" "${5:-STANDARD}"
        ;;
    monitor_tmux)
        monitor_tmux
        ;;
    create_window)
        create_tmux_notification_window
        ;;
    status)
        if [ -f "$QUEUE_FILE" ]; then
            echo -e "${BOLD}Current Queue Status:${NC}"
            jq '.' "$QUEUE_FILE"
        else
            echo "Queue is empty"
        fi
        ;;
    *)
        echo "Usage: $0 {notify|monitor_tmux|create_window|status} [song] [artist] [requester] [priority]"
        echo ""
        echo "Commands:"
        echo "  notify          - Send a DJ request notification to all terminals"
        echo "  monitor_tmux    - Start tmux monitoring window"
        echo "  create_window   - Create dedicated tmux notification window"
        echo "  status          - Show current queue status"
        exit 1
        ;;
esac
