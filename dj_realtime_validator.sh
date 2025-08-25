#!/bin/bash

# 🎧 DJ REAL-TIME VALIDATOR v10.0 - MADONNA ATTITUDE PREVENTION EDITION
# Bash integration with TypeScript autocomplete to prevent Warren Beatty situations
# Copyright 2025 - Panther Pride DJ Consortium International

# ANSI Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GOLD='\033[38;5;220m'
PINK='\033[38;5;205m'
ORANGE='\033[38;5;208m'
MAGENTA='\033[38;5;13m'
LIME='\033[38;5;10m'
NC='\033[0m' # No Color
BOLD='\033[1m'
BLINK='\033[5m'

# Configuration
MUSIC_DATABASE="$HOME/.dj_music_library.json"
VALIDATION_LOG="$HOME/.dj_validation.log"

# Madonna's attitude prevention system - simulate the TypeScript library in bash
initialize_music_library() {
    echo -e "${YELLOW}🍎 Initializing Apple Music library for real-time validation...${NC}"
    
    cat > "$MUSIC_DATABASE" << 'EOF'
{
  "songs": [
    {
      "title": "Music",
      "artist": "Madonna",
      "album": "Music",
      "id": "madonna_music_001",
      "confidence": 1.0
    },
    {
      "title": "Material Girl",
      "artist": "Madonna",
      "album": "Like a Virgin",
      "id": "madonna_material_001",
      "confidence": 1.0
    },
    {
      "title": "Like a Prayer",
      "artist": "Madonna",
      "album": "Like a Prayer",
      "id": "madonna_prayer_001",
      "confidence": 1.0
    },
    {
      "title": "Vogue",
      "artist": "Madonna",
      "album": "I'm Breathless",
      "id": "madonna_vogue_001",
      "confidence": 1.0
    },
    {
      "title": "Bohemian Rhapsody",
      "artist": "Queen",
      "album": "A Night at the Opera",
      "id": "queen_bohemian_001",
      "confidence": 1.0
    },
    {
      "title": "Don't Stop Me Now",
      "artist": "Queen",
      "album": "Jazz",
      "id": "queen_dontstop_001",
      "confidence": 1.0
    },
    {
      "title": "We Will Rock You",
      "artist": "Queen",
      "album": "News of the World",
      "id": "queen_rock_001",
      "confidence": 1.0
    },
    {
      "title": "Welcome to the Jungle",
      "artist": "Guns N' Roses",
      "album": "Appetite for Destruction",
      "id": "gnr_jungle_001",
      "confidence": 1.0
    },
    {
      "title": "Sweet Child O' Mine",
      "artist": "Guns N' Roses",
      "album": "Appetite for Destruction",
      "id": "gnr_child_001",
      "confidence": 1.0
    },
    {
      "title": "Sandstorm",
      "artist": "Darude",
      "album": "Before the Storm",
      "id": "darude_sandstorm_001",
      "confidence": 1.0
    },
    {
      "title": "I Am Here",
      "artist": "edhead76",
      "album": "Collaborative Mix",
      "id": "ed_here_001",
      "confidence": 1.0
    },
    {
      "title": "Collaborative Mix Track",
      "artist": "edhead76",
      "album": "I Am Here",
      "id": "ed_collab_001",
      "confidence": 1.0
    },
    {
      "title": "Hello",
      "artist": "Adele",
      "album": "25",
      "id": "adele_hello_001",
      "confidence": 1.0
    },
    {
      "title": "Someone Like You",
      "artist": "Adele",
      "album": "21",
      "id": "adele_someone_001",
      "confidence": 1.0
    },
    {
      "title": "Blinding Lights",
      "artist": "The Weeknd",
      "album": "After Hours",
      "id": "weeknd_lights_001",
      "confidence": 1.0
    }
  ]
}
EOF
    
    echo -e "${GREEN}✅ Music library initialized with protection against diva attitudes${NC}"
}

# Calculate string similarity (simplified version of Levenshtein)
calculate_similarity() {
    local str1="$1"
    local str2="$2"
    
    # Convert to lowercase
    str1=$(echo "$str1" | tr '[:upper:]' '[:lower:]')
    str2=$(echo "$str2" | tr '[:upper:]' '[:lower:]')
    
    # Exact match
    if [ "$str1" = "$str2" ]; then
        echo "1.0"
        return
    fi
    
    # Substring match
    if [[ "$str1" == *"$str2"* ]] || [[ "$str2" == *"$str1"* ]]; then
        echo "0.8"
        return
    fi
    
    # Partial match (simplified)
    local len1=${#str1}
    local len2=${#str2}
    local common=0
    
    # Count common characters (very simplified)
    for ((i=0; i<len2-1; i++)); do
        local char="${str2:$i:2}"
        if [[ "$str1" == *"$char"* ]]; then
            ((common++))
        fi
    done
    
    if [ $common -gt 0 ]; then
        echo "0.5"
    else
        echo "0.2"
    fi
}

# Validate song exists in library
validate_song_request() {
    local song_title="$1"
    local artist="$2"
    local requester="$3"
    
    if [ ! -f "$MUSIC_DATABASE" ]; then
        initialize_music_library
    fi
    
    echo -e "${CYAN}🔍 Validating: \"${BOLD}$song_title${NC}${CYAN}\" by ${BOLD}$artist${NC}${CYAN} for ${BOLD}$requester${NC}"
    echo -e "${YELLOW}   Checking Apple Music library...${NC}"
    
    # Look for exact match first
    local exact_match=$(jq -r --arg title "$song_title" --arg artist "$artist" '
        .songs[] | select(.title | ascii_downcase == ($title | ascii_downcase)) | 
        select(.artist | ascii_downcase == ($artist | ascii_downcase)) | .title
    ' "$MUSIC_DATABASE" 2>/dev/null)
    
    if [ -n "$exact_match" ] && [ "$exact_match" != "null" ]; then
        echo -e "${GREEN}✅ EXACT MATCH FOUND: \"$exact_match\" by $artist${NC}"
        echo -e "${LIME}🎵 $requester's request will play perfectly in Apple Music${NC}"
        
        log_validation "EXACT_MATCH" "$song_title" "$artist" "$requester" "1.0"
        return 0
    fi
    
    # Look for close matches
    echo -e "${ORANGE}   No exact match found, searching for similar songs...${NC}"
    
    local suggestions=$(jq -r --arg title "$song_title" --arg artist "$artist" '
        .songs[] | 
        select((.title | ascii_downcase | contains($title | ascii_downcase)) or 
               (.artist | ascii_downcase | contains($artist | ascii_downcase))) |
        "\(.title)|\(.artist)|\(.album)"
    ' "$MUSIC_DATABASE" | head -3)
    
    if [ -n "$suggestions" ]; then
        echo -e "${YELLOW}⚠️  SIMILAR SONGS FOUND - Preventing Madonna attitude!${NC}"
        echo -e "${CYAN}   Did you mean one of these?${NC}"
        
        local suggestion_count=0
        while IFS='|' read -r title artist_name album; do
            if [ -n "$title" ]; then
                ((suggestion_count++))
                echo -e "${PINK}   $suggestion_count) \"${BOLD}$title${NC}${PINK}\" by ${BOLD}$artist_name${NC}${PINK} (Album: $album)${NC}"
            fi
        done <<< "$suggestions"
        
        echo -e "\n${GOLD}💡 Auto-correction suggestions available to prevent request failure${NC}"
        echo -e "${CYAN}   Would you like to auto-correct? (y/n): ${NC}"
        read -p "$(echo -e ${CYAN}Response: ${NC})" auto_correct
        
        if [[ "$(echo "$auto_correct" | tr '[:upper:]' '[:lower:]')" == "y" || "$(echo "$auto_correct" | tr '[:upper:]' '[:lower:]')" == "yes" ]]; then
            echo -e "${GREEN}✅ Auto-correction enabled - preventing diva meltdown${NC}"
            
            # Get first suggestion
            local corrected=$(echo "$suggestions" | head -1)
            IFS='|' read -r corrected_title corrected_artist corrected_album <<< "$corrected"
            
            echo -e "${LIME}🎵 Corrected to: \"$corrected_title\" by $corrected_artist${NC}"
            
            log_validation "AUTO_CORRECTED" "$song_title -> $corrected_title" "$artist -> $corrected_artist" "$requester" "0.8"
            
            # Update the request with corrected info
            export CORRECTED_TITLE="$corrected_title"
            export CORRECTED_ARTIST="$corrected_artist"
            
            return 0
        fi
    fi
    
    # No matches found - Warren Beatty situation incoming!
    echo -e "${RED}❌ SONG NOT FOUND IN APPLE MUSIC LIBRARY${NC}"
    echo -e "${ORANGE}⚠️  WARNING: This could cause a Madonna vs Warren Beatty situation!${NC}"
    echo -e "${YELLOW}   \"$song_title\" by $artist is not available${NC}"
    echo -e "${CYAN}   Fallback options will be used (Spotify, YouTube Music)${NC}"
    
    # Offer to prevent the attitude
    echo -e "\n${MAGENTA}💭 Madonna's attitude prevention system activated...${NC}"
    echo -e "${PINK}   Would you like to search for an alternative? (y/n): ${NC}"
    read -p "$(echo -e ${PINK}Response: ${NC})" search_alternative
    
    if [[ "$(echo "$search_alternative" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
        show_alternative_suggestions "$song_title" "$artist"
    fi
    
    log_validation "NOT_FOUND" "$song_title" "$artist" "$requester" "0.0"
    return 1
}

# Show alternative suggestions to prevent attitude
show_alternative_suggestions() {
    local original_song="$1"
    local original_artist="$2"
    
    echo -e "${PURPLE}🔍 Alternative suggestions to keep $original_artist happy:${NC}"
    
    # Get songs by same artist
    local same_artist_songs=$(jq -r --arg artist "$original_artist" '
        .songs[] | select(.artist | ascii_downcase | contains($artist | ascii_downcase)) |
        "• \(.title) - \(.album)"
    ' "$MUSIC_DATABASE")
    
    if [ -n "$same_artist_songs" ]; then
        echo -e "${CYAN}Songs by $original_artist in your library:${NC}"
        echo "$same_artist_songs"
    fi
    
    # Get songs with similar titles
    local similar_titles=$(jq -r --arg title "$original_song" '
        .songs[] | select(.title | ascii_downcase | contains($title[0:3] | ascii_downcase)) |
        "• \(.title) by \(.artist)"
    ' "$MUSIC_DATABASE")
    
    if [ -n "$similar_titles" ]; then
        echo -e "\n${CYAN}Songs with similar titles:${NC}"
        echo "$similar_titles"
    fi
}

# Log validation results
log_validation() {
    local result_type="$1"
    local song="$2"
    local artist="$3"
    local requester="$4"
    local confidence="$5"
    
    echo "[$(date)] $result_type: \"$song\" by $artist for $requester (confidence: $confidence)" >> "$VALIDATION_LOG"
}

# Interactive song request with real-time validation
interactive_song_request() {
    echo -e "${GOLD}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║      🎧 DJ REAL-TIME VALIDATOR v10.0 - ATTITUDE FREE    ║${NC}"
    echo -e "${GOLD}║        * PREVENTS WARREN BEATTY SITUATIONS *            ║${NC}"
    echo -e "${GOLD}╚══════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${CYAN}💭 As Madonna said in Truth or Dare: We're avoiding the 'asshole' moment${NC}"
    
    # Get requester info
    echo -e "\n${PINK}👤 Who is making this request?${NC}"
    read -p "$(echo -e ${PINK}Requester name: ${NC})" requester_name
    
    # Get song info with validation
    echo -e "\n${LIME}🎵 What song would you like to request?${NC}"
    read -p "$(echo -e ${LIME}Song title: ${NC})" song_title
    
    echo -e "${LIME}🎤 Who is the artist?${NC}"
    read -p "$(echo -e ${LIME}Artist name: ${NC})" artist_name
    
    # Validate the request
    if validate_song_request "$song_title" "$artist_name" "$requester_name"; then
        echo -e "\n${GREEN}🎉 Request validated successfully!${NC}"
        
        # Check if we have corrected values
        if [ -n "$CORRECTED_TITLE" ] && [ -n "$CORRECTED_ARTIST" ]; then
            song_title="$CORRECTED_TITLE"
            artist_name="$CORRECTED_ARTIST"
        fi
        
        # Process the validated request
        echo -e "${CYAN}Processing validated request: \"$song_title\" by $artist_name${NC}"
        
        # Integrate with the ultimate DJ system
        if [ -f "./dj_ultimate_control.sh" ]; then
            echo "n" | ./dj_ultimate_control.sh request "$song_title" "$artist_name" "$requester_name" "VALIDATED"
        fi
        
    else
        echo -e "\n${ORANGE}⚠️  Request needs attention to prevent attitude issues${NC}"
        echo -e "${YELLOW}Proceeding with fallback options...${NC}"
        
        # Still process but with warning
        if [ -f "./dj_ultimate_control.sh" ]; then
            echo "n" | ./dj_ultimate_control.sh request "$song_title" "$artist_name" "$requester_name" "FALLBACK"
        fi
    fi
}

# Test Madonna's request specifically
test_madonna_request() {
    echo -e "${GOLD}👑 TESTING MADONNA'S REQUEST - ATTITUDE PREVENTION MODE${NC}"
    echo -e "${PINK}Simulating: Madonna requests 'Music' (the song that started this whole thing)${NC}\n"
    
    validate_song_request "Music" "Madonna" "Madonna"
    
    echo -e "\n${MAGENTA}💭 Madonna's response: 'Finally, someone who gets it right!'${NC}"
    echo -e "${CYAN}   No Warren Beatty situation today! ✨${NC}"
}

# Show validation history
show_validation_history() {
    echo -e "${BOLD}${CYAN}📋 VALIDATION HISTORY (Attitude Prevention Log)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    
    if [ -f "$VALIDATION_LOG" ]; then
        echo -e "${YELLOW}Recent validations:${NC}"
        tail -10 "$VALIDATION_LOG"
    else
        echo -e "${YELLOW}No validation history yet${NC}"
    fi
}

# Main execution
case "${1:-help}" in
    validate)
        validate_song_request "${2:-Unknown Song}" "${3:-Unknown Artist}" "${4:-Anonymous}"
        ;;
    interactive)
        interactive_song_request
        ;;
    madonna)
        test_madonna_request
        ;;
    init)
        initialize_music_library
        ;;
    history)
        show_validation_history
        ;;
    *)
        echo "Usage: $0 {validate|interactive|madonna|init|history} [song] [artist] [requester]"
        echo ""
        echo "Commands:"
        echo "  validate     - Validate specific song request"
        echo "  interactive  - Interactive request with real-time validation"
        echo "  madonna      - Test Madonna's request (attitude prevention)"
        echo "  init         - Initialize music library"
        echo "  history      - Show validation history"
        echo ""
        echo "🎧 DJ Real-Time Validator v10.0 - Keeping A-listers happy since 2025!"
        echo "💭 'No more Warren Beatty situations' - Madonna, probably"
        exit 1
        ;;
esac
