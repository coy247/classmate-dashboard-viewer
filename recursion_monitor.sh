#!/bin/bash

# 🔄 RECURSION DEPTH MONITOR 🔄
# Tracks and measures recursive update patterns
# Because if you're going to have recursion, measure it properly!

RECURSION_STATE_FILE="$HOME/.dashboard_recursion_state.json"
RECURSION_LOG="$HOME/.dashboard_recursion.log"

# Initialize recursion tracking
init_recursion() {
    if [ ! -f "$RECURSION_STATE_FILE" ]; then
        cat > "$RECURSION_STATE_FILE" << EOF
{
  "current_depth": 0,
  "max_depth_reached": 0,
  "total_recursions": 0,
  "inception_level": "STABLE",
  "last_spiral": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "stack_overflow_risk": 0,
  "mirrors_reflecting": 0
}
EOF
    fi
}

# Track recursion event
track_recursion() {
    init_recursion
    
    # Read current state
    CURRENT_DEPTH=$(grep '"current_depth"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    MAX_DEPTH=$(grep '"max_depth_reached"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    TOTAL_RECURSIONS=$(grep '"total_recursions"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    MIRRORS=$(grep '"mirrors_reflecting"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    
    # Check for recursive pattern (same process calling within 2 seconds)
    LAST_CALL=$(tail -n 1 "$RECURSION_LOG" 2>/dev/null | cut -d'|' -f1)
    CURRENT_TIME=$(date +%s)
    
    if [ -n "$LAST_CALL" ]; then
        TIME_DIFF=$((CURRENT_TIME - LAST_CALL))
        if [ $TIME_DIFF -lt 2 ]; then
            # We're in a recursion!
            NEW_DEPTH=$((CURRENT_DEPTH + 1))
            NEW_MIRRORS=$((MIRRORS + 1))
        else
            # Reset depth but keep counts
            NEW_DEPTH=1
            NEW_MIRRORS=1
        fi
    else
        NEW_DEPTH=1
        NEW_MIRRORS=1
    fi
    
    # Update max depth if needed
    if [ $NEW_DEPTH -gt $MAX_DEPTH ]; then
        NEW_MAX=$NEW_DEPTH
    else
        NEW_MAX=$MAX_DEPTH
    fi
    
    # Increment total recursions
    NEW_TOTAL=$((TOTAL_RECURSIONS + 1))
    
    # Calculate inception level
    if [ $NEW_DEPTH -ge 10 ]; then
        INCEPTION="CRITICAL_INCEPTION"
        OVERFLOW_RISK=95
    elif [ $NEW_DEPTH -ge 7 ]; then
        INCEPTION="DEEP_DREAM"
        OVERFLOW_RISK=75
    elif [ $NEW_DEPTH -ge 5 ]; then
        INCEPTION="RECURSIVE_SPIRAL"
        OVERFLOW_RISK=50
    elif [ $NEW_DEPTH -ge 3 ]; then
        INCEPTION="LOOP_DETECTED"
        OVERFLOW_RISK=25
    else
        INCEPTION="STABLE"
        OVERFLOW_RISK=5
    fi
    
    # Log the recursion
    echo "$CURRENT_TIME|$NEW_DEPTH|$INCEPTION" >> "$RECURSION_LOG"
    
    # Update state file
    cat > "$RECURSION_STATE_FILE" << EOF
{
  "current_depth": $NEW_DEPTH,
  "max_depth_reached": $NEW_MAX,
  "total_recursions": $NEW_TOTAL,
  "inception_level": "$INCEPTION",
  "last_spiral": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "stack_overflow_risk": $OVERFLOW_RISK,
  "mirrors_reflecting": $NEW_MIRRORS
}
EOF
    
    # Return formatted status
    echo "$NEW_DEPTH|$NEW_MAX|$NEW_TOTAL|$INCEPTION|$OVERFLOW_RISK|$NEW_MIRRORS"
}

# Get recursion status message
get_recursion_status() {
    init_recursion
    
    # Read current state
    DEPTH=$(grep '"current_depth"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    MAX=$(grep '"max_depth_reached"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    TOTAL=$(grep '"total_recursions"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    INCEPTION=$(grep '"inception_level"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' "')
    RISK=$(grep '"stack_overflow_risk"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    MIRRORS=$(grep '"mirrors_reflecting"' "$RECURSION_STATE_FILE" | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
    
    # Generate fun status messages
    case $INCEPTION in
        CRITICAL_INCEPTION)
            echo "🌀 INCEPTION LEVEL CRITICAL! Depth: $DEPTH | Mirrors: $MIRRORS | We need to go DEEPER!"
            ;;
        DEEP_DREAM)
            echo "😵 DEEP DREAM STATE! Recursion depth: $DEPTH | Is this real life?"
            ;;
        RECURSIVE_SPIRAL)
            echo "🔄 RECURSIVE SPIRAL DETECTED! Level $DEPTH | Mirrors reflecting: $MIRRORS"
            ;;
        LOOP_DETECTED)
            echo "➰ Loop depth: $DEPTH | Total spirals: $TOTAL | Risk: $RISK%"
            ;;
        *)
            if [ $TOTAL -gt 100 ]; then
                echo "📊 Recursion metrics: Depth $DEPTH | Lifetime loops: $TOTAL | Maximum depth achieved: $MAX"
            elif [ $TOTAL -gt 50 ]; then
                echo "🔁 Update loops: $TOTAL | Current depth: $DEPTH | Stack health: $((100 - RISK))%"
            else
                echo "✅ Recursion monitoring active | Depth: $DEPTH | Total cycles: $TOTAL"
            fi
            ;;
    esac
}

# Main execution
case "$1" in
    init)
        init_recursion
        echo "Recursion monitor initialized"
        ;;
    track)
        track_recursion
        ;;
    status)
        get_recursion_status
        ;;
    *)
        echo "Usage: $0 {init|track|status}"
        exit 1
        ;;
esac
