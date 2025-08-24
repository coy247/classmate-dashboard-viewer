#!/bin/bash

# 🎮 DASHBOARD AUTO-UPDATER CONTROL SCRIPT
# Easy management of the automated dashboard updater

SCRIPT_DIR="/Volumes/TOSHIBA EXT/projects/nano-systems/playground/ollama_llm/classmate-dashboard-viewer"
DAEMON_SCRIPT="$SCRIPT_DIR/auto_updater_daemon.sh"
PLIST_FILE="$SCRIPT_DIR/com.edgarzaro.dashboard.autoupdater.plist"
LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
INSTALLED_PLIST="$LAUNCHAGENT_DIR/com.edgarzaro.dashboard.autoupdater.plist"
PID_FILE="/tmp/dashboard_auto_updater.pid"
LOG_FILE="$HOME/.dashboard_auto_updater.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Header
show_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║   🎮 DASHBOARD CONTROL CENTER 🎮           ║"
    echo "║                                            ║"
    echo "║   Automated Dashboard Update Manager       ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Status check
check_status() {
    echo -e "${BLUE}📊 Checking auto-updater status...${NC}"
    
    # Check if daemon is running
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Auto-updater is RUNNING (PID: $PID)${NC}"
            
            # Show last few log entries
            if [ -f "$LOG_FILE" ]; then
                echo -e "\n${BLUE}📜 Recent activity:${NC}"
                tail -n 5 "$LOG_FILE" | while IFS= read -r line; do
                    echo "   $line"
                done
            fi
        else
            echo -e "${YELLOW}⚠️  PID file exists but process not running${NC}"
            rm -f "$PID_FILE"
        fi
    else
        echo -e "${RED}❌ Auto-updater is NOT running${NC}"
    fi
    
    # Check LaunchAgent status
    echo -e "\n${BLUE}🚀 LaunchAgent status:${NC}"
    if [ -f "$INSTALLED_PLIST" ]; then
        if launchctl list | grep -q "com.edgarzaro.dashboard.autoupdater"; then
            echo -e "${GREEN}✅ LaunchAgent is loaded${NC}"
        else
            echo -e "${YELLOW}⚠️  LaunchAgent installed but not loaded${NC}"
        fi
    else
        echo -e "${RED}❌ LaunchAgent not installed${NC}"
    fi
}

# Start daemon in foreground
start_foreground() {
    echo -e "${GREEN}▶️  Starting auto-updater in foreground...${NC}"
    chmod +x "$DAEMON_SCRIPT"
    exec "$DAEMON_SCRIPT"
}

# Start daemon in background
start_background() {
    echo -e "${GREEN}▶️  Starting auto-updater in background...${NC}"
    chmod +x "$DAEMON_SCRIPT"
    nohup "$DAEMON_SCRIPT" > /tmp/dashboard_autoupdater.out 2>&1 &
    echo -e "${GREEN}✅ Auto-updater started in background${NC}"
    echo -e "${BLUE}Check logs at: $LOG_FILE${NC}"
}

# Stop daemon
stop_daemon() {
    echo -e "${YELLOW}⏹  Stopping auto-updater...${NC}"
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            kill -TERM "$PID"
            sleep 2
            if ps -p "$PID" > /dev/null 2>&1; then
                echo -e "${YELLOW}Force stopping...${NC}"
                kill -9 "$PID"
            fi
            echo -e "${GREEN}✅ Auto-updater stopped${NC}"
        else
            echo -e "${YELLOW}Process not found, cleaning up PID file${NC}"
            rm -f "$PID_FILE"
        fi
    else
        echo -e "${YELLOW}Auto-updater not running${NC}"
    fi
}

# Install LaunchAgent
install_launchagent() {
    echo -e "${BLUE}📦 Installing LaunchAgent...${NC}"
    
    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$LAUNCHAGENT_DIR"
    
    # Copy plist file
    cp "$PLIST_FILE" "$INSTALLED_PLIST"
    
    # Load the agent
    launchctl load "$INSTALLED_PLIST"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ LaunchAgent installed and loaded${NC}"
        echo -e "${GREEN}The auto-updater will now start automatically on login${NC}"
    else
        echo -e "${RED}❌ Failed to load LaunchAgent${NC}"
    fi
}

# Uninstall LaunchAgent
uninstall_launchagent() {
    echo -e "${YELLOW}🗑  Uninstalling LaunchAgent...${NC}"
    
    if [ -f "$INSTALLED_PLIST" ]; then
        # Unload the agent
        launchctl unload "$INSTALLED_PLIST" 2>/dev/null
        
        # Remove the plist file
        rm -f "$INSTALLED_PLIST"
        
        echo -e "${GREEN}✅ LaunchAgent uninstalled${NC}"
    else
        echo -e "${YELLOW}LaunchAgent not installed${NC}"
    fi
}

# View logs
view_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo -e "${BLUE}📜 Dashboard Auto-Updater Logs:${NC}"
        echo "----------------------------------------"
        tail -f "$LOG_FILE"
    else
        echo -e "${YELLOW}No log file found${NC}"
    fi
}

# Manual update
manual_update() {
    echo -e "${BLUE}🔄 Running manual update...${NC}"
    cd "$SCRIPT_DIR"
    ./update_status.sh
}

# Main menu
main_menu() {
    show_header
    
    echo "Select an option:"
    echo ""
    echo "  ${GREEN}1)${NC} Start auto-updater (foreground)"
    echo "  ${GREEN}2)${NC} Start auto-updater (background)"
    echo "  ${YELLOW}3)${NC} Stop auto-updater"
    echo "  ${BLUE}4)${NC} Check status"
    echo "  ${CYAN}5)${NC} Install as system service (LaunchAgent)"
    echo "  ${CYAN}6)${NC} Uninstall system service"
    echo "  ${MAGENTA}7)${NC} View logs"
    echo "  ${MAGENTA}8)${NC} Run manual update now"
    echo "  ${RED}9)${NC} Exit"
    echo ""
    
    read -p "Enter choice [1-9]: " choice
    
    case $choice in
        1) start_foreground ;;
        2) start_background ;;
        3) stop_daemon ;;
        4) check_status ;;
        5) install_launchagent ;;
        6) uninstall_launchagent ;;
        7) view_logs ;;
        8) manual_update ;;
        9) echo -e "${GREEN}Goodbye! Keep percolating! ☕${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    main_menu
}

# Handle command line arguments
case "${1:-menu}" in
    start)
        start_background
        ;;
    stop)
        stop_daemon
        ;;
    status)
        check_status
        ;;
    install)
        install_launchagent
        ;;
    uninstall)
        uninstall_launchagent
        ;;
    logs)
        view_logs
        ;;
    update)
        manual_update
        ;;
    menu|*)
        main_menu
        ;;
esac
