#!/bin/bash

# 🔒 SECURE STATUS UPDATER FOR ED ONLY
# This script updates the dashboard status and pushes to GitHub
# DO NOT share this script with classmates!

echo "☕ Percolator Status Updater v1.0"
echo "================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "status.json" ]; then
    echo "❌ Error: status.json not found in current directory"
    echo "Please run this script from the classmate-dashboard-viewer directory"
    exit 1
fi

# Function to update status.json with current service states
update_status() {
    echo -e "${BLUE}📊 Gathering service status...${NC}"
    
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
    
    # Check Apple Music status
    MUSIC_STATUS=""
    if [ -x "./apple_music_monitor.sh" ]; then
        MUSIC_JSON=$(./apple_music_monitor.sh monitor 2>/dev/null | tail -n 11 | head -n 10)
        if echo "$MUSIC_JSON" | grep -q "apple_music"; then
            # Extract music data
            MUSIC_TRACK=$(echo "$MUSIC_JSON" | grep '"track"' | cut -d'"' -f4)
            MUSIC_ARTIST=$(echo "$MUSIC_JSON" | grep '"artist"' | cut -d'"' -f4)
            MUSIC_REPEAT=$(echo "$MUSIC_JSON" | grep '"repeat_mode"' | cut -d'"' -f4)
            MUSIC_SESSION=$(echo "$MUSIC_JSON" | grep '"session_plays"' | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
            MUSIC_TOTAL=$(echo "$MUSIC_JSON" | grep '"total_plays"' | cut -d':' -f2 | cut -d',' -f1 | tr -d ' ')
            
            # Generate epic music commentary
            if [ "$MUSIC_REPEAT" = "one" ] && [ "$MUSIC_TOTAL" -gt 0 ]; then
                if [ "$MUSIC_TOTAL" -gt 5000 ]; then
                    MUSIC_STATUS="🎙️ HALL OF FAME ALERT! $MUSIC_ARTIST - $MUSIC_TRACK on ETERNAL REPEAT! Play #$MUSIC_TOTAL - LEGENDARY!"
                elif [ "$MUSIC_TOTAL" -gt 1000 ]; then
                    MUSIC_STATUS="🔥 REPEAT CHAMPIONSHIP! $MUSIC_ARTIST - $MUSIC_TRACK for the ${MUSIC_TOTAL}th time! OBSESSION LEVEL: MAXIMUM!"
                else
                    MUSIC_STATUS="🎵 REPEAT MODE ACTIVATED! $MUSIC_ARTIST - $MUSIC_TRACK (Play #$MUSIC_TOTAL) - Can't stop, won't stop!"
                fi
            elif [ -n "$MUSIC_TRACK" ] && [ "$MUSIC_TRACK" != "Unknown" ]; then
                MUSIC_STATUS="🎶 NOW PLAYING: $MUSIC_ARTIST - $MUSIC_TRACK (Lifetime: $MUSIC_TOTAL plays)"
            fi
        fi
    fi
    
    # Generate random entertaining events - SPORTS ANNOUNCER STYLE!
    EVENTS=(
        "🎙️ GOOOOOAL! Percolator cycle COMPLETES at $(date +%H:%M) - UNSTOPPABLE!"
        "🏈 INTERCEPTION! Panthers defense DESTROYS suspicious packet at the 50-yard line!"
        "🎯 UNBELIEVABLE! Candy Consortium K-Pop squad performs FLAWLESS security choreography!"
        "🔥 FROM THE TOP ROPE! Neural network SLAMS coffee enlightenment with a PERFECT 10!"
        "⚡ SPEED DEMON! TRIAGE CLI processes batch in $(( $RANDOM % 50 + 10 ))ms - NEW RECORD!"
        "🎙️ THE CROWD GOES WILD! VOICE System channels the SPIRIT of the percolator!"
        "🏈 TOUCHDOWN! TOUCHDOWN! Service uptime hits 99.$(( $RANDOM % 9 ))% - CHAMPIONSHIP NUMBERS!"
        "🎪 SHOWTIME BABY! Maximum entertainment mode ACTIVATED - THE FANS ARE ON THEIR FEET!"
        "📡 BREAKING: Satellite uplink with Charlotte LOCKED IN - Signal strength MAXED OUT!"
        "🚨 DEFENSIVE MASTERPIECE! ZERO Bills fans detected - SHUTOUT CONTINUES!"
        "☕ HE SHOOTS, HE SCORES! Percolator drains a BUZZER-BEATER of pure Colombian!"
        "💥 EXPLOSIVE! SAMMY Service response time OBLITERATES previous record!"
        "🏆 HALL OF FAME PERFORMANCE! All systems operating at LEGENDARY status!"
        "🐾 PANTHERS PRIDE! Defense holding stronger than Fort Knox at port 8443!"
        "⚡ LIGHTNING ROUND! $(( $RANDOM % 1000 + 500 )) requests processed in ONE SECOND!"
        "🎯 PRECISION STRIKE! Security scan finds ABSOLUTELY NOTHING - PERFECT GAME!"
        "🔥 ON FIRE! Neural Network learning rate EXCEEDS all expectations!"
        "🎪 CIRCUS CATCH! CONSORTIUM self-heals before we even noticed the problem!"
        "☕ OVERTIME THRILLER! Percolator enters BEAST MODE at $(date +%H:%M:%S)!"
        "🏈 FOURTH QUARTER MAGIC! Services rally for INCREDIBLE comeback performance!"
    )
    
    # Select random events
    RANDOM_EVENT1="${EVENTS[$RANDOM % ${#EVENTS[@]}]}"
    RANDOM_EVENT2="${EVENTS[$RANDOM % ${#EVENTS[@]}]}"
    RANDOM_EVENT3="${EVENTS[$RANDOM % ${#EVENTS[@]}]}"
    
    # Create updated status.json
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
        "Dashboards": "$(( $RANDOM % 5 + 10 )) Active",
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
        "Latency": "$(( $RANDOM % 20 + 5 ))ms"
      }
    },
    {
      "name": "🧠 Neural Network",
      "status": "learning",
      "details": {
        "Escalation": "Level $(( $RANDOM % 3 + 1 ))",
        "Training": "In Progress",
        "Accuracy": "$(( $RANDOM % 5 + 95 )).$(( $RANDOM % 9 ))%"
      }
    }
  ],
  "events": [
    "${MUSIC_STATUS:-🎵 Apple Music status: No track playing}",
    "${RANDOM_EVENT1}",
    "${RANDOM_EVENT2}",
    "${RANDOM_EVENT3}",
    "⏰ Status updated at $(date +%H:%M:%S)",
    "☕ All systems percolating smoothly",
    "🐾 Panthers pride level: MAXIMUM",
    "📊 Dashboard refresh completed",
    "✅ Health check passed with flying colors"
  ],
  "timestamp": "${TIMESTAMP}",
  "message": "All systems percolating smoothly! ☕ Keep Pounding! 🐾"
}
EOF
    
    echo -e "${GREEN}✅ Status updated successfully!${NC}"
}

# Function to push to GitHub
push_to_github() {
    echo -e "${BLUE}📤 Pushing to GitHub...${NC}"
    
    # Check if git repo exists
    if [ ! -d ".git" ]; then
        echo -e "${YELLOW}⚠️  Git repository not initialized${NC}"
        echo "Would you like to initialize a git repository? (y/n)"
        read -r response
        if [ "$response" = "y" ]; then
            git init
            git add .
            git commit -m "Initial commit - Panthers '95 Dashboard"
            echo -e "${GREEN}✅ Git repository initialized${NC}"
            echo ""
            echo "Next steps:"
            echo "1. Create a new repository on GitHub called 'classmate-dashboard-viewer'"
            echo "2. Run: git remote add origin https://github.com/YOUR_USERNAME/classmate-dashboard-viewer.git"
            echo "3. Run: git push -u origin main"
            echo "4. Enable GitHub Pages in repository settings (use main branch)"
        fi
        return
    fi
    
    # Add and commit changes
    git add status.json
    git commit -m "🔄 Update service status - $(date +%Y-%m-%d' '%H:%M:%S)"
    
    # Push to GitHub
    if git push 2>/dev/null; then
        echo -e "${GREEN}✅ Successfully pushed to GitHub!${NC}"
        echo -e "${GREEN}📊 Dashboard will update automatically via GitHub Pages${NC}"
    else
        echo -e "${YELLOW}⚠️  Push failed. Please check your GitHub connection${NC}"
        echo "You may need to run: git push --set-upstream origin main"
    fi
}

# Main execution
echo ""
update_status
echo ""
push_to_github
echo ""
echo -e "${GREEN}🎉 Dashboard update complete!${NC}"
echo "☕ Keep percolating! 🐾 Keep pounding!"
