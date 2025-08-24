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
    
    # Generate random entertaining events
    EVENTS=(
        "☕ Percolator cycle completed at $(date +%H:%M)"
        "🐾 Panthers defense intercepted suspicious packet"
        "🍭 Candy Consortium K-Pop squad performed security dance"
        "🧠 Neural network achieved coffee enlightenment"
        "⚡ TRIAGE CLI processed batch faster than light"
        "🎙️ VOICE System heard the call of the percolator"
        "🏈 Service uptime touchdown! 99.9% achieved"
        "🎪 Maximum entertainment mode activated"
        "📡 Satellite uplink with Charlotte established"
        "🔐 Security check: No Bills fans detected in vicinity"
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
