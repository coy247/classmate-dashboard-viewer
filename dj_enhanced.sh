#!/bin/bash

# 🎵 ENHANCED DJ SYSTEM WITH LOOP COUNTING 🎵
# Tracks loops, manages queue, bot requests annoying songs

LOOP_COUNT_FILE="$HOME/.dj_loop_counts.json"
REQUEST_QUEUE="$HOME/.dj_request_queue.json"
BOT_FAVORITES="$HOME/.dj_bot_favorites.txt"
QUEUE_WAIT_FILE="$HOME/.dj_queue_wait.txt"

# Initialize loop counting
init_loop_counter() {
    if [ ! -f "$LOOP_COUNT_FILE" ]; then
        echo '{}' > "$LOOP_COUNT_FILE"
    fi
}

# Update loop count for current song
update_loop_count() {
    local CURRENT_TRACK=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null)
    local CURRENT_ARTIST=$(osascript -e 'tell application "Music" to get artist of current track' 2>/dev/null)
    
    if [ -n "$CURRENT_TRACK" ] && [ -n "$CURRENT_ARTIST" ]; then
        local SONG_KEY="${CURRENT_ARTIST}:::${CURRENT_TRACK}"
        
        # Read current counts
        local CURRENT_COUNT=$(grep -o "\"$SONG_KEY\":[0-9]*" "$LOOP_COUNT_FILE" | cut -d':' -f3)
        
        if [ -z "$CURRENT_COUNT" ]; then
            CURRENT_COUNT=0
        fi
        
        # Increment count
        NEW_COUNT=$((CURRENT_COUNT + 1))
        
        # Update file (simple approach for now)
        if [ $CURRENT_COUNT -eq 0 ]; then
            # Add new entry
            sed -i '' "s/^{/{\"$SONG_KEY\":$NEW_COUNT,/" "$LOOP_COUNT_FILE" 2>/dev/null
        else
            # Update existing
            sed -i '' "s/\"$SONG_KEY\":$CURRENT_COUNT/\"$SONG_KEY\":$NEW_COUNT/" "$LOOP_COUNT_FILE" 2>/dev/null
        fi
        
        echo "$NEW_COUNT"
    else
        echo "0"
    fi
}

# Get songs with 500+ loops
get_loop_champions() {
    if [ -f "$LOOP_COUNT_FILE" ]; then
        grep -o '"[^"]*":[0-9]*' "$LOOP_COUNT_FILE" | while IFS=':' read -r song count; do
            # Remove quotes and check count
            song=$(echo "$song" | tr -d '"')
            count=$(echo "$count" | tr -d '"')
            
            if [ "$count" -ge 500 ]; then
                IFS=':::' read -r artist track <<< "$song"
                echo "🔁 LOOP CHAMPION: $artist - $track (${count}x)"
            fi
        done
    fi
}

# Bot's annoying song selection
get_bot_request() {
    # Primary annoying choices
    local ANNOYING_SONGS=(
        "The Percolator|Cajmere"
        "Glitter in the Air|P!nk"
        "Blue Bayou|Linda Ronstadt"
        "La Charreada|Linda Ronstadt"
        "Por Un Amor|Linda Ronstadt"
        "Ray of Light (William Orbit Mix)|Madonna"
        "Music (Deep Dish Dot Com Mix)|Madonna"
        "What It Feels Like for a Girl (Above & Beyond Mix)|Madonna"
        "Baby Shark|Pinkfong"
        "Friday|Rebecca Black"
        "Barbie Girl|Aqua"
        "MMMBop|Hanson"
        "Mambo No. 5|Lou Bega"
        "Who Let the Dogs Out|Baha Men"
        "Cotton Eye Joe|Rednex"
        "Crazy Frog|Axel F"
        "The Hamster Dance|Hampton the Hamster"
        "Call Me Maybe|Carly Rae Jepsen"
        "Gangnam Style|PSY"
        "The Macarena|Los Del Rio"
    )
    
    # Check time of day for selection
    HOUR=$(date +%H)
    
    # During slow times (2-6 AM), get extra annoying
    if [ $HOUR -ge 2 ] && [ $HOUR -le 6 ]; then
        echo "🤖 BOT REQUEST (3AM SPECIAL): ${ANNOYING_SONGS[$RANDOM % ${#ANNOYING_SONGS[@]}]}"
    else
        echo "🤖 BOT REQUEST: ${ANNOYING_SONGS[$RANDOM % ${#ANNOYING_SONGS[@]}]}"
    fi
}

# Calculate queue wait time
calculate_wait_time() {
    if [ ! -f "$REQUEST_QUEUE" ]; then
        echo "0 minutes"
        return
    fi
    
    # Count pending requests
    local QUEUE_LENGTH=$(grep -o '"pending"' "$REQUEST_QUEUE" | wc -l)
    
    # Assume average song is 3.5 minutes
    local WAIT_MINUTES=$((QUEUE_LENGTH * 3))
    
    if [ $WAIT_MINUTES -eq 0 ]; then
        echo "Playing next!"
    elif [ $WAIT_MINUTES -lt 60 ]; then
        echo "$WAIT_MINUTES minutes"
    else
        local HOURS=$((WAIT_MINUTES / 60))
        local MINS=$((WAIT_MINUTES % 60))
        echo "${HOURS}h ${MINS}m"
    fi
}

# Get fake karaoke lyrics (no copyrighted content)
get_karaoke_display() {
    local SONG="$1"
    local ARTIST="$2"
    local IS_PANTHER="$3"
    
    if [ "$IS_PANTHER" = "y" ]; then
        cat << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎤 NOW PLAYING: PANTHER REQUESTED SONG
🎵 $SONG by $ARTIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎤 ● ○ ○ ○ ○ ○ ○ ○ ○ ○
[Lyrics display disabled for copyright]
[Imagine a bouncing ball here!]
🎵 ♪ ♫ ♪ ♫ ♪ ♫ ♪ ♫ ♪

🐾 PANTHER PRIDE SELECTION 🐾
EOF
    else
        cat << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎤 NOW PLAYING: GUEST REQUEST
🎵 $SONG by $ARTIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ NON-PANTHER ALERT ⚠️
A rival mascot has infiltrated the queue!

🎤 ● ○ ○ ○ ○ ○ ○ ○ ○ ○
[Karaoke mode activated]
[No lyrics shown - we don't trust outsiders]
EOF
    fi
}

# Generate mascot rivalry message
get_rival_message() {
    local MASCOT="$1"
    local SCHOOL="$2"
    
    local MESSAGES=(
        "Oh look, a $MASCOT from $SCHOOL thinks they have taste in music!"
        "A wild $MASCOT appears! They probably can't even spell 'Panther'!"
        "$SCHOOL's $MASCOT in the house! Did you get lost on the way to mediocrity?"
        "Welcome $MASCOT! Your song choice probably matches your school spirit: questionable!"
        "A $MASCOT? In OUR queue? This is why Panthers rule the jungle!"
    )
    
    echo "${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}"
}

# Main execution
case "$1" in
    init)
        init_loop_counter
        echo "Enhanced DJ system initialized"
        ;;
    
    loop-count)
        update_loop_count
        ;;
    
    champions)
        get_loop_champions
        ;;
    
    bot-request)
        get_bot_request
        ;;
    
    wait-time)
        calculate_wait_time
        ;;
    
    karaoke)
        # Usage: karaoke "song" "artist" "y/n"
        get_karaoke_display "$2" "$3" "$4"
        ;;
    
    rival)
        # Usage: rival "mascot" "school"
        get_rival_message "$2" "$3"
        ;;
    
    *)
        echo "Usage: $0 {init|loop-count|champions|bot-request|wait-time|karaoke|rival}"
        exit 1
        ;;
esac
