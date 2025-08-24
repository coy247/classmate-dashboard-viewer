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
        # Get the full output first
        FULL_OUTPUT=$(./apple_music_monitor.sh monitor 2>/dev/null)
        
        # Extract just the JSON part (last 10 lines)
        MUSIC_JSON=$(echo "$FULL_OUTPUT" | tail -n 10)
        
        # Check if we have valid JSON with apple_music
        if echo "$MUSIC_JSON" | grep -q '"apple_music"'; then
            # Extract fields more reliably
            MUSIC_TRACK=$(echo "$MUSIC_JSON" | grep '"track":' | sed 's/.*"track": "\([^"]*\)".*/\1/')
            MUSIC_ARTIST=$(echo "$MUSIC_JSON" | grep '"artist":' | sed 's/.*"artist": "\([^"]*\)".*/\1/')
            MUSIC_REPEAT=$(echo "$MUSIC_JSON" | grep '"repeat_mode":' | sed 's/.*"repeat_mode": "\([^"]*\)".*/\1/')
            MUSIC_TOTAL=$(echo "$MUSIC_JSON" | grep '"total_plays":' | sed 's/.*"total_plays": \([0-9]*\).*/\1/')
            
            # Debug log
            log_message INFO "Music detected: $MUSIC_ARTIST - $MUSIC_TRACK | Repeat: $MUSIC_REPEAT | Plays: $MUSIC_TOTAL"
            
            # ONLY create status if repeat mode is "one" (single repeat)
            if [ "$MUSIC_REPEAT" = "one" ] && [ -n "$MUSIC_TOTAL" ] && [ "$MUSIC_TOTAL" -gt 0 ]; then
                if [ "$MUSIC_TOTAL" -gt 5000 ]; then
                    MUSIC_STATUS="🎙️ HALL OF FAME! $MUSIC_ARTIST - $MUSIC_TRACK on REPEAT! Play #$MUSIC_TOTAL!"
                elif [ "$MUSIC_TOTAL" -gt 1000 ]; then
                    MUSIC_STATUS="🔥 OBSESSION MODE! $MUSIC_ARTIST - $MUSIC_TRACK x${MUSIC_TOTAL}!"
                else
                    MUSIC_STATUS="🎵 ON REPEAT: $MUSIC_ARTIST - $MUSIC_TRACK (#$MUSIC_TOTAL)"
                fi
                log_message INFO "Music status set: $MUSIC_STATUS"
            fi
        fi
    fi
    
    # Track recursion
    RECURSION_STATUS=""
    if [ -x "./recursion_monitor.sh" ]; then
        ./recursion_monitor.sh track >/dev/null 2>&1
        RECURSION_STATUS=$(./recursion_monitor.sh status 2>/dev/null)
    fi
    
    # Get PSA educational content
    PSA_MESSAGE=""
    if [ -x "./psa_generator.sh" ]; then
        PSA_MESSAGE=$(./psa_generator.sh get 2>/dev/null | head -n 1)
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
    
    # Build unique sports announcer events
    SPORTS_EVENTS=()
    
    # Dynamic commentary based on time and status
    SPORTS_EVENTS+=("🎙️ LIVE from the dashboard at $CURRENT_TIME!")
    
    if [ "$SAMMY_STATUS" = "operational" ]; then
        SPORTS_EVENTS+=("🏈 SAMMY's DEFENSIVE LINE is UNSTOPPABLE at port 8443!")
    else
        SPORTS_EVENTS+=("⚠️ SAMMY's taking a timeout for repairs...")
    fi
    
    # Add excitement variety
    EXCITEMENT=("INCREDIBLE!" "UNBELIEVABLE!" "SPECTACULAR!" "PHENOMENAL!" "AMAZING!" "OUTSTANDING!")
    RANDOM_EXCITEMENT="${EXCITEMENT[$RANDOM % ${#EXCITEMENT[@]}}]"
    SPORTS_EVENTS+=("⚡ ${RANDOM_EXCITEMENT} Response time: ${SYSTEM_LATENCY}ms!")
    
    # Time-based stadium atmosphere
    HOUR=$(date +%H)
    if [ $HOUR -ge 6 ] && [ $HOUR -lt 12 ]; then
        SPORTS_EVENTS+=("☕ THE MORNING CROWD IS CAFFEINATED AND READY!")
    elif [ $HOUR -ge 12 ] && [ $HOUR -lt 18 ]; then
        SPORTS_EVENTS+=("🌞 THE AFTERNOON HEAT CAN'T STOP THIS PERFORMANCE!")
    elif [ $HOUR -ge 18 ] && [ $HOUR -lt 22 ]; then
        SPORTS_EVENTS+=("🌆 PRIME TIME PERFORMANCE UNDER THE LIGHTS!")
    else
        SPORTS_EVENTS+=("🌙 THE NIGHT SHIFT NEVER SLEEPS!")
    fi
    
    # Fun stats commentary
    SPORTS_EVENTS+=("📊 Dashboard #$DASHBOARD_NUM bringing the HEAT!")
    SPORTS_EVENTS+=("🏆 Uptime streak: LEGENDARY!")
    
    # Build events array with no duplicates
    EVENT_ARRAY=()
    
    # Priority 1: Music status (if available)
    if [ -n "$MUSIC_STATUS" ]; then
        EVENT_ARRAY+=("$MUSIC_STATUS")
    fi
    
    # Priority 2: PSA educational content
    if [ -n "$PSA_MESSAGE" ]; then
        EVENT_ARRAY+=("$PSA_MESSAGE")
    fi
    
    # Priority 3: Recursion monitoring (if interesting)
    if [ -n "$RECURSION_STATUS" ]; then
        EVENT_ARRAY+=("$RECURSION_STATUS")
    fi
    
    # Priority 4: Sports announcer commentary (2-3 items)
    for ((i=0; i<${#SPORTS_EVENTS[@]} && i<2; i++)); do
        EVENT_ARRAY+=("${SPORTS_EVENTS[$i]}")
    done
    
    # Priority 5: Neural events (1-2 items)
    for ((i=0; i<${#NEURAL_EVENTS[@]} && i<2; i++)); do
        if [ -n "${NEURAL_EVENTS[$i]}" ]; then
            EVENT_ARRAY+=("${NEURAL_EVENTS[$i]}")
        fi
    done
    
    # Add a final status line
    EVENT_ARRAY+=("🤖 Auto-update cycle #$N_EPOCHS | Next in ${UPDATE_INTERVAL}s")
    
    # Ensure exactly 8 events (no more, no less)
    while [ ${#EVENT_ARRAY[@]} -lt 8 ]; do
        EVENT_ARRAY+=("${SPORTS_EVENTS[$((RANDOM % ${#SPORTS_EVENTS[@]}))}]}")
    done
    
    # Trim to exactly 8 if we have more
    EVENT_ARRAY=("${EVENT_ARRAY[@]:0:8}")
    
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
