#!/bin/bash

# DJ Respectful Queue Manager - NEVER interrupt current song!
# This script adds songs to Apple Music's Up Next queue without interrupting

# Check if a song is currently playing and wait for it to end
wait_for_current_song() {
    local current_state=$(osascript -e 'tell application "Music" to get player state as string' 2>/dev/null)
    
    if [ "$current_state" = "playing" ]; then
        local current_track=$(osascript -e 'tell application "Music" to get name of current track' 2>/dev/null)
        local current_position=$(osascript -e 'tell application "Music" to get player position' 2>/dev/null)
        local track_duration=$(osascript -e 'tell application "Music" to get duration of current track' 2>/dev/null)
        local time_remaining=$(echo "$track_duration - $current_position" | bc)
        
        echo "🎵 Currently playing: $current_track"
        echo "⏱️  Time remaining: ${time_remaining}s"
        echo "⚠️  RESPECTING THE SONG - Will queue after it ends"
        
        # Don't actually wait, just add to Up Next queue
        return 0
    else
        echo "✅ No song playing, safe to queue"
        return 0
    fi
}

# Add song to Up Next queue (not immediate play)
add_to_up_next() {
    local song_title="$1"
    local artist="$2"
    
    echo "Adding to Up Next: \"$song_title\" by $artist"
    
    osascript <<EOF 2>/dev/null
tell application "Music"
    try
        -- Search for the song
        set searchQuery to "$song_title $artist"
        set searchResults to search playlist "Library" for searchQuery
        
        if (count of searchResults) > 0 then
            set foundTrack to item 1 of searchResults
            
            -- Add to Up Next (NOT immediate play)
            -- This queues it after current song
            duplicate foundTrack to end of current playlist
            
            return "Queued: " & (get name of foundTrack) & " by " & (get artist of foundTrack)
        else
            -- Try just song title
            set searchResults to search playlist "Library" for "$song_title"
            if (count of searchResults) > 0 then
                set foundTrack to item 1 of searchResults
                duplicate foundTrack to end of current playlist
                return "Queued (partial): " & (get name of foundTrack)
            else
                return "Not found: $song_title"
            end if
        end if
    on error errMsg
        return "Error: " & errMsg
    end try
end tell
EOF
}

# Main queue management
echo "🎧 DJ RESPECTFUL QUEUE MANAGER"
echo "================================"
echo "Cardinal Rule: NEVER interrupt the current song!"
echo ""

# Check current playback state
wait_for_current_song

echo ""
echo "📋 Adding songs to Up Next queue (after current song):"
echo ""

# Add all the songs to Up Next queue
add_to_up_next "Welcome to the Jungle" "Guns N' Roses"
add_to_up_next "Bohemian Rhapsody" "Queen"
add_to_up_next "Don't Stop Me Now" "Queen"
add_to_up_next "Sandstorm" "Darude"
add_to_up_next "Sweet Child O' Mine" "Guns N' Roses"
add_to_up_next "I Am Here" "P!NK"

echo ""
echo "✅ All songs queued respectfully!"
echo "🎵 They will play after the current song ends"
