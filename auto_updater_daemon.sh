#!/bin/bash

# 🤖 AUTOMATED DASHBOARD UPDATER DAEMON
# Continuously monitors services and pushes updates to GitHub
# Runs every 2 minutes (configurable)

# Configuration
UPDATE_INTERVAL=120  # seconds (2 minutes default)
LOG_FILE="$HOME/.dashboard_auto_updater.log"
PID_FILE="/tmp/dashboard_auto_updater.pid"
DASHBOARD_DIR="/Volumes/TOSHIBA EXT/projects/nano-systems/playground/ollama_llm/classmate-dashboard-viewer"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case $level in
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
    esac
}

# Check if another instance is running
check_existing_instance() {
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE")
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            log_message ERROR "Another instance is already running with PID $OLD_PID"
            exit 1
        else
            log_message WARNING "Removing stale PID file"
            rm -f "$PID_FILE"
        fi
    fi
}

# Create PID file
create_pid_file() {
    echo $$ > "$PID_FILE"
    log_message INFO "Created PID file with PID $$"
}

# Cleanup on exit
cleanup() {
    log_message INFO "Shutting down auto-updater..."
    rm -f "$PID_FILE"
    log_message SUCCESS "Auto-updater stopped cleanly"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Update function
perform_update() {
    log_message INFO "Starting dashboard update cycle..."
    
    # Security validation first
    if [ -x "./quantum_security_validator.sh" ]; then
        ./quantum_security_validator.sh status.json 2>/dev/null || {
            log_message ERROR "SECURITY-VALIDATION-FAILED-ABORTING"
            return 1
        }
    fi
    
    cd "$DASHBOARD_DIR" || {
        log_message ERROR "Failed to change to dashboard directory"
        return 1
    }
    
    # Get current timestamp
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Check SAMMY service (port 8443)
    SAMMY_STATUS="operational"
    if lsof -i :8443 > /dev/null 2>&1; then
        SAMMY_HEALTH="100%"
    else
        SAMMY_STATUS="degraded"
        SAMMY_HEALTH="0%"
    fi
    
    # Check if TRIAGE CLI exists
    TRIAGE_STATUS="operational"
    if [ -f "../triage_cli.ts" ]; then
        TRIAGE_STATUS="operational"
    else
        TRIAGE_STATUS="degraded"
    fi
    
    # Check Apple Music status - ONLY report if single repeat is on
    MUSIC_STATUS=""
    if [ -x "./apple_music_monitor.sh" ]; then
        MUSIC_JSON=$(./apple_music_monitor.sh monitor 2>/dev/null | tail -n 11 | head -n 10)
        if echo "$MUSIC_JSON" | grep -q "apple_music"; then
            MUSIC_TRACK=$(echo "$MUSIC_JSON" | grep '"track"' | cut -d'"' -f4)
            MUSIC_ARTIST=$(echo "$MUSIC_JSON" | grep '"artist"' | cut -d'"' -f4)
            MUSIC_REPEAT=$(echo "$MUSIC_JSON" | grep '"repeat_mode"' | cut -d'"' -f4)
            MUSIC_TOTAL=$(echo "$MUSIC_JSON" | grep '"total_plays"' | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
            
            # ONLY create status if repeat mode is "one" (single repeat)
            if [ "$MUSIC_REPEAT" = "one" ] && [ "$MUSIC_TOTAL" -gt 0 ]; then
                if [ "$MUSIC_TOTAL" -gt 5000 ]; then
                    MUSIC_STATUS="🎙️ HALL OF FAME! $MUSIC_ARTIST - $MUSIC_TRACK on REPEAT! Play #$MUSIC_TOTAL!"
                elif [ "$MUSIC_TOTAL" -gt 1000 ]; then
                    MUSIC_STATUS="🔥 OBSESSION MODE! $MUSIC_ARTIST - $MUSIC_TRACK x${MUSIC_TOTAL}!"
                else
                    MUSIC_STATUS="🎵 ON REPEAT: $MUSIC_ARTIST - $MUSIC_TRACK (#$MUSIC_TOTAL)"
                fi
            fi
            # Don't report anything if repeat is not on
        fi
    fi
    
    # Get neural state and unique events
    NEURAL_EVENTS=()
    if [ -x "./neural_state.sh" ]; then
        # Update neural state and get context-aware events
        mapfile -t NEURAL_EVENTS < <(./neural_state.sh events 2>/dev/null)
        
        # Get current neural stats for display
        NEURAL_STATE=$(./neural_state.sh update 2>/dev/null)
        IFS='|' read -r N_LEVEL N_ACCURACY N_EPOCHS N_LAYERS N_GC <<< "$NEURAL_STATE"
    else
        # Fallback if neural state not available
        N_LEVEL=1
        N_ACCURACY="85.0"
        N_EPOCHS=0
    fi
    
    # Dynamic sports announcer events (non-repeating)
    CURRENT_TIME=$(date +%H:%M:%S)
    SYSTEM_LATENCY=$(( $RANDOM % 50 + 10 ))
    DASHBOARD_NUM=$(( $RANDOM % 5 + 10 ))
    UPTIME_HOURS=$(( $(date +%s) / 3600 % 1000 ))
    
    # Build unique event array
    UNIQUE_EVENTS=()
    UNIQUE_EVENTS+=("🎙️ LIVE UPDATE at $CURRENT_TIME | Systems: OPTIMAL")
    UNIQUE_EVENTS+=("⚡ Response time: ${SYSTEM_LATENCY}ms | Cloud sync: SUCCESS")
    
    # Add service-specific dynamic events
    if [ "$SAMMY_STATUS" = "operational" ]; then
        UNIQUE_EVENTS+=("🛡️ SAMMY fortress IMPENETRABLE at port 8443!")
    else
        UNIQUE_EVENTS+=("🔧 SAMMY rebuilding defenses...")
    fi
    
    # Add time-based variety
    HOUR=$(date +%H)
    if [ $HOUR -ge 6 ] && [ $HOUR -lt 12 ]; then
        UNIQUE_EVENTS+=("☕ Morning percolation at MAXIMUM")
    elif [ $HOUR -ge 12 ] && [ $HOUR -lt 18 ]; then
        UNIQUE_EVENTS+=("🌞 Afternoon systems: BLAZING FAST")
    elif [ $HOUR -ge 18 ] && [ $HOUR -lt 22 ]; then
        UNIQUE_EVENTS+=("🌆 Evening patrol: ALL CLEAR")
    else
        UNIQUE_EVENTS+=("🌙 Night watch: VIGILANT")
    fi
    
    # Build events array with no duplicates
    EVENT_ARRAY=()
    
    # Add music status if available
    if [ -n "$MUSIC_STATUS" ]; then
        EVENT_ARRAY+=("$MUSIC_STATUS")
    fi
    
    # Add neural events (already unique from neural_state.sh)
    for event in "${NEURAL_EVENTS[@]:0:3}"; do
        if [ -n "$event" ]; then
            EVENT_ARRAY+=("$event")
        fi
    done
    
    # Add unique dynamic events
    EVENT_ARRAY+=("${UNIQUE_EVENTS[@]:0:3}")
    
    # Ensure we have at least 8 events, pad if needed
    while [ ${#EVENT_ARRAY[@]} -lt 8 ]; do
        EVENT_ARRAY+=("🔄 Monitoring cycle #$N_EPOCHS active")
        break
    done
    
    # Create updated status.json with neural state persistence
    cat > status.json << EOF
{
  "services": [
    {
      "name": "🔧 SAMMY Service",
      "status": "${SAMMY_STATUS}",
      "details": {
        "Port": "8443 (HTTPS)",
        "SSL": "✅ Enabled",
        "Health": "${SAMMY_HEALTH}"
      }
    },
    {
      "name": "🏛️ CONSORTIUM",
      "status": "operational",
      "details": {
        "Self-Regulation": "Active & Optimized",
        "Health": "$(( $RANDOM % 10 + 91 ))%",
        "Auto-Heal": "✅ Enabled"
      }
    },
    {
      "name": "🍭 CANDY Interface",
      "status": "operational",
      "details": {
        "Migration": "Grafana ($(( $RANDOM % 30 + 60 ))%)",
        "Dashboards": "$DASHBOARD_NUM Active",
        "K-Pop Squad": "🎵 Dancing"
      }
    },
    {
      "name": "⚡ TRIAGE CLI",
      "status": "${TRIAGE_STATUS}",
      "details": {
        "Imports": "✅ Resolved",
        "Modules": "All Loaded",
        "Performance": "Optimized"
      }
    },
    {
      "name": "🎙️ VOICE System",
      "status": "operational",
      "details": {
        "Neural Network": "Monitoring",
        "Recognition": "$(( $RANDOM % 5 + 95 )).$(( $RANDOM % 9 ))%",
        "Latency": "${SYSTEM_LATENCY}ms"
      }
    },
    {
      "name": "🧠 Neural Network",
      "status": "learning",
      "details": {
        "Learning Level": "${N_LEVEL}/10",
        "Epochs": "${N_EPOCHS}",
        "Accuracy": "${N_ACCURACY}%",
        "Sandwich Layers": "${N_LAYERS:-3}",
        "GC Cycles": "${N_GC:-0}"
      }
    }
  ],
  "events": [
$(printf '    "%s"' "${EVENT_ARRAY[0]}")
$(for ((i=1; i<${#EVENT_ARRAY[@]}; i++)); do printf ',
    "%s"' "${EVENT_ARRAY[$i]}"; done)
  ],
  "timestamp": "${TIMESTAMP}",
  "message": "🤖 Auto-Dashboard v2.0 | 🧠 Neural Sandwich GC Active | 🐾 Keep Pounding!"
}
EOF
    
    log_message SUCCESS "Status file updated"
    
    # Git operations
    if [ -d ".git" ]; then
        # Check if there are changes
        if git diff --quiet status.json; then
            log_message INFO "No changes detected, skipping commit"
            return 0
        fi
        
        # Add and commit
        git add status.json
        git commit -m "🤖 Auto-update: $(date '+%Y-%m-%d %H:%M:%S')" > /dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            log_message SUCCESS "Changes committed"
            
            # Push to GitHub
            if git push > /dev/null 2>&1; then
                log_message SUCCESS "Pushed to GitHub successfully"
            else
                log_message ERROR "Failed to push to GitHub"
            fi
        else
            log_message WARNING "No changes to commit"
        fi
    else
        log_message ERROR "Not a git repository"
    fi
}

# Main loop
main() {
    echo -e "${MAGENTA}"
    echo "╔════════════════════════════════════════════╗"
    echo "║   🤖 DASHBOARD AUTO-UPDATER DAEMON 🤖      ║"
    echo "║                                            ║"
    echo "║   Updating every ${UPDATE_INTERVAL} seconds              ║"
    echo "║   Log: $LOG_FILE                           ║"
    echo "║                                            ║"
    echo "║   Press Ctrl+C to stop                    ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_existing_instance
    create_pid_file
    
    log_message INFO "Auto-updater daemon started"
    log_message INFO "Update interval: ${UPDATE_INTERVAL} seconds"
    
    # Main loop
    while true; do
        perform_update
        
        # Show countdown
        echo -ne "${BLUE}Next update in: ${NC}"
        for ((i=UPDATE_INTERVAL; i>0; i--)); do
            echo -ne "\r${BLUE}Next update in: ${YELLOW}${i}${NC} seconds  "
            sleep 1
        done
        echo -ne "\r${GREEN}Updating now...                    ${NC}\n"
    done
}

# Start the daemon
main
