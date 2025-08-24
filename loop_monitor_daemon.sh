#!/bin/bash

# 🔄 LOOP MONITOR DAEMON
# Runs in background to track loops in real-time

PID_FILE="/tmp/loop_monitor.pid"
LOG_FILE="$HOME/.loop_monitor_daemon.log"

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Loop monitor already running with PID $OLD_PID"
        exit 1
    fi
    rm -f "$PID_FILE"
fi

# Create PID file
echo $$ > "$PID_FILE"

# Cleanup on exit
cleanup() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Loop monitor daemon stopped" >> "$LOG_FILE"
    rm -f "$PID_FILE"
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Loop monitor daemon started" >> "$LOG_FILE"
echo "🔄 Loop Monitor Daemon Started (PID: $$)"
echo "Monitoring Apple Music for loops..."
echo "Press Ctrl+C to stop"

# Initialize tracking
./loop_tracker.sh init 2>/dev/null

# Main monitoring loop
while true; do
    # Check if Music app is running
    if pgrep -x "Music" > /dev/null; then
        # Track loops
        RESULT=$(./loop_tracker.sh track 2>&1)
        
        # If a loop was detected, log it
        if echo "$RESULT" | grep -q "Loop detected"; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $RESULT" | tee -a "$LOG_FILE"
        fi
    fi
    
    # Check every 2 seconds
    sleep 2
done
