#!/bin/bash

# 🏥 GITHUB PAGES SELF-HEALER 🏥
# Monitors and automatically fixes GitHub Pages deployment issues
# Based on cli-triage self-healing patterns

REPO_NAME="classmate-dashboard-viewer"
GH_USER="coy247"
LOG_FILE="$HOME/.github_pages_healer.log"
STATE_FILE="$HOME/.github_pages_state.json"

log_health() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_pages_health() {
    # Check if GitHub Pages is responding
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://${GH_USER}.github.io/${REPO_NAME}/" 2>/dev/null)
    
    if [ "$RESPONSE" = "200" ]; then
        log_health "✅ GitHub Pages healthy (HTTP $RESPONSE)"
        return 0
    else
        log_health "⚠️ GitHub Pages unhealthy (HTTP $RESPONSE)"
        return 1
    fi
}

self_heal() {
    log_health "🔧 Initiating self-healing sequence..."
    
    # Step 1: Ensure we have index.html
    if [ ! -f "index.html" ]; then
        log_health "❌ index.html missing! Recreating..."
        create_emergency_index
    fi
    
    # Step 2: Check .nojekyll file
    if [ ! -f ".nojekyll" ]; then
        log_health "📝 Creating .nojekyll file"
        touch .nojekyll
        git add .nojekyll
    fi
    
    # Step 3: Verify gh-pages branch exists or use main
    CURRENT_BRANCH=$(git branch --show-current)
    log_health "📌 Current branch: $CURRENT_BRANCH"
    
    # Step 4: Force push if needed
    if [ -f "index.html" ] && [ -f "status.json" ]; then
        log_health "🚀 Pushing healing commit..."
        git add index.html status.json .nojekyll 2>/dev/null
        git commit -m "🏥 Self-heal: GitHub Pages restoration $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null
        git push origin main --force-with-lease 2>/dev/null
        
        # Wait for GitHub to process
        sleep 10
        
        # Check again
        if check_pages_health; then
            log_health "✅ Self-healing successful!"
            return 0
        else
            log_health "⚠️ Self-healing needs manual intervention"
            return 1
        fi
    fi
}

create_emergency_index() {
    # Create a basic but functional index.html if missing
    cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🐾 Panther Pride Dashboard - Emergency Recovery</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: rgba(0,0,0,0.3);
            padding: 30px;
            border-radius: 15px;
        }
        h1 { font-size: 2.5em; }
        .status { 
            background: rgba(255,255,255,0.1);
            padding: 20px;
            margin: 20px 0;
            border-radius: 10px;
        }
        .healing {
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0% { opacity: 0.6; }
            50% { opacity: 1; }
            100% { opacity: 0.6; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏥 Dashboard Self-Healing in Progress</h1>
        <div class="status healing">
            <h2>⚡ Emergency Recovery Mode</h2>
            <p>The dashboard is automatically repairing itself...</p>
            <p>This page will refresh in <span id="countdown">30</span> seconds</p>
        </div>
        <div class="status">
            <h3>🔧 Recovery Steps:</h3>
            <ul style="text-align: left; display: inline-block;">
                <li>✅ Emergency page deployed</li>
                <li>⏳ Restoring dashboard components...</li>
                <li>⏳ Reconnecting to services...</li>
                <li>⏳ Rebuilding status feed...</li>
            </ul>
        </div>
    </div>
    <script>
        let count = 30;
        setInterval(() => {
            count--;
            document.getElementById('countdown').textContent = count;
            if (count <= 0) {
                window.location.reload();
            }
        }, 1000);
        
        // Try to load the real dashboard after healing
        setTimeout(() => {
            fetch('status.json')
                .then(r => r.json())
                .then(data => {
                    if (data.services) {
                        window.location.href = window.location.href;
                    }
                })
                .catch(() => {});
        }, 5000);
    </script>
</body>
</html>
EOF
    log_health "✅ Emergency index.html created"
}

update_state() {
    cat > "$STATE_FILE" << EOF
{
  "last_check": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "status": "$1",
  "response_code": "$2",
  "healed_count": ${3:-0}
}
EOF
}

# Main execution
main() {
    cd "/Volumes/TOSHIBA EXT/projects/nano-systems/playground/ollama_llm/classmate-dashboard-viewer" || exit 1
    
    if check_pages_health; then
        update_state "healthy" "200" 0
        echo "✅ GitHub Pages is healthy"
    else
        echo "🔧 GitHub Pages needs healing..."
        if self_heal; then
            update_state "healed" "200" 1
            echo "✅ Successfully healed!"
        else
            update_state "unhealthy" "404" 0
            echo "❌ Manual intervention required"
        fi
    fi
}

main
