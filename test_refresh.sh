#!/bin/bash

# Test the refresh rate calculation

REFRESH_RATE_FILE="$HOME/.refresh_rate.txt"

calculate_refresh_rate() {
    local CURRENT_RATE=$(cat "$REFRESH_RATE_FILE" 2>/dev/null || echo "30")
    
    # Progressive speedup formula
    local NEW_RATE
    if [ $CURRENT_RATE -ge 20 ]; then
        # Fast reduction at first (reduce by 33%)
        NEW_RATE=$((CURRENT_RATE * 2 / 3))
    elif [ $CURRENT_RATE -ge 10 ]; then
        # Medium reduction (reduce by 25%)
        NEW_RATE=$((CURRENT_RATE * 3 / 4))
    elif [ $CURRENT_RATE -ge 5 ]; then
        # Slower reduction near the limit
        NEW_RATE=$((CURRENT_RATE - 1))
    else
        # Approaching ludicrous speed
        NEW_RATE=$((CURRENT_RATE - 1))
    fi
    
    # Ensure bounds
    if [ $NEW_RATE -gt 60 ]; then
        NEW_RATE=60
    elif [ $NEW_RATE -le 0 ]; then
        NEW_RATE=1
    fi
    
    echo "$NEW_RATE" > "$REFRESH_RATE_FILE"
    echo "$NEW_RATE"
}

# Initialize with 30 seconds
echo "30" > "$REFRESH_RATE_FILE"
echo "Starting with 30 seconds..."
echo "Formula: new_seconds = (current_seconds * 1000 / 30) / 1000"
echo ""

# Simulate 10 requests
for i in {1..10}; do
    CURRENT=$(cat "$REFRESH_RATE_FILE")
    NEW=$(calculate_refresh_rate)
    echo "Request $i: ${CURRENT}s → ${NEW}s"
    
    # Check if we've hit ludicrous speed
    if [ "$NEW" -eq 1 ]; then
        echo "🚀 LUDICROUS SPEED ACHIEVED!"
        break
    fi
done
