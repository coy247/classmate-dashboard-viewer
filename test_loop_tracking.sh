#!/bin/bash

# Test script to verify loop tracking is working correctly

echo "=== LOOP TRACKING TEST ==="
echo ""

# 1. Check current state
echo "1. Current loop state:"
cat ~/.loop_tracker_state.json
echo ""

# 2. Check if Music is playing
echo "2. Music player status:"
PLAYER_STATE=$(osascript -e 'tell application "Music" to get player state as string' 2>/dev/null)
echo "   Player state: $PLAYER_STATE"

REPEAT_MODE=$(osascript -e 'tell application "Music" to get song repeat' 2>/dev/null)
echo "   Repeat mode: $REPEAT_MODE"

CURRENT_TRACK=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null)
CURRENT_ARTIST=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null)
echo "   Current track: $CURRENT_ARTIST - $CURRENT_TRACK"
echo ""

# 3. Test loop tracker count
echo "3. Loop tracker count:"
./loop_tracker.sh count
echo ""

# 4. Test loop tracker status
echo "4. Loop tracker status message:"
./loop_tracker.sh status
echo ""

# 5. Test bar detection logic
echo "5. Testing bar detection:"
if [[ "$REPEAT_MODE" == "one" ]]; then
    echo "   ✅ Repeat mode is ON - Bar should be OPEN"
else
    echo "   ❌ Repeat mode is OFF - Bar should be CLOSED"
fi
echo ""

# 6. Check if status.json has correct music event
echo "6. Music event in status.json:"
grep -E "OBSESSION|REPEAT|LOOP CHAMPION|HALL OF FAME" status.json | head -1
echo ""

echo "=== TEST COMPLETE ==="
echo ""
echo "Summary:"
echo "- Loop count should be 1283 (base count)"
echo "- Bar should be OPEN if repeat mode is 'one'"
echo "- Status.json should have music event with x1283"
echo "- Each actual loop should increment the count"
