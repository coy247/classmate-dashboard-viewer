#!/bin/bash

# Script to actually add songs to Apple Music queue
# This will search for songs and add them to the Up Next queue

add_song_to_apple_music() {
    local song_title="$1"
    local artist="$2"
    
    echo "Adding to Apple Music: \"$song_title\" by $artist"
    
    # Create AppleScript to search and add song
    osascript <<EOF 2>/dev/null
tell application "Music"
    try
        -- Search for the song
        set searchQuery to "$song_title $artist"
        set searchResults to search playlist "Library" for searchQuery
        
        if (count of searchResults) > 0 then
            -- Get the first result
            set foundTrack to item 1 of searchResults
            
            -- Add to Up Next queue
            duplicate foundTrack to (get source 1)
            
            -- Alternative: Play the track next
            -- play foundTrack after current track
            
            return "Added: " & (get name of foundTrack) & " by " & (get artist of foundTrack)
        else
            -- Try searching just by song title
            set searchResults to search playlist "Library" for "$song_title"
            if (count of searchResults) > 0 then
                set foundTrack to item 1 of searchResults
                duplicate foundTrack to (get source 1)
                return "Added (partial match): " & (get name of foundTrack)
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

# Read our queue and add songs to Apple Music
echo "Reading queue and adding songs to Apple Music..."

# Add Madonna's Music first
add_song_to_apple_music "Music" "Madonna"

# Add other songs from our queue
add_song_to_apple_music "Welcome to the Jungle" "Guns N' Roses"
add_song_to_apple_music "Bohemian Rhapsody" "Queen"
add_song_to_apple_music "Don't Stop Me Now" "Queen"
add_song_to_apple_music "Sandstorm" "Darude"
add_song_to_apple_music "Sweet Child O' Mine" "Guns N' Roses"

echo "Done adding songs to Apple Music queue"
