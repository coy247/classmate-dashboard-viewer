#!/bin/bash

# 🎧 DJ REQUEST WEBHOOK HANDLER WITH INDUSTRIAL NOTIFICATION SYSTEM
# Monitors the dashboard for new requests and triggers professional notifications

REQUESTS_FILE="$HOME/.dj_requests_processed.json"
DASHBOARD_URL="https://coy247.github.io/classmate-dashboard-viewer/status.json"
CHECK_INTERVAL=10  # seconds

# Initialize request tracking
if [ ! -f "$REQUESTS_FILE" ]; then
    echo '{"processed": []}' > "$REQUESTS_FILE"
fi

# Function to check for new requests in localStorage (simulated)
check_for_new_requests() {
    # In a real implementation, this would check the dashboard's request queue
    # For now, we'll simulate detecting a new request
    
    # Check if there's a pending request file (created when someone submits via the dashboard)
    if [ -f "$HOME/.pending_dj_request.json" ]; then
        local REQUEST_DATA=$(cat "$HOME/.pending_dj_request.json")
        local SONG=$(echo "$REQUEST_DATA" | jq -r '.song')
        local ARTIST=$(echo "$REQUEST_DATA" | jq -r '.artist')
        local REQUESTER=$(echo "$REQUEST_DATA" | jq -r '.requester')
        local REQUEST_ID=$(echo "$REQUEST_DATA" | jq -r '.id')
        
        # Check if already processed
        local ALREADY_PROCESSED=$(jq ".processed[] | select(. == \"$REQUEST_ID\")" "$REQUESTS_FILE")
        
        if [ -z "$ALREADY_PROCESSED" ]; then
            echo "🎵 NEW REQUEST DETECTED!"
            
            # Trigger the industrial notification system
            ./dj_notification_system.sh notify "$SONG" "$ARTIST" "$REQUESTER" "PRIORITY"
            
            # Mark as processed
            jq ".processed += [\"$REQUEST_ID\"]" "$REQUESTS_FILE" > "$REQUESTS_FILE.tmp" && \
                mv "$REQUESTS_FILE.tmp" "$REQUESTS_FILE"
            
            # Move to processed folder
            mkdir -p "$HOME/.processed_requests"
            mv "$HOME/.pending_dj_request.json" "$HOME/.processed_requests/request_${REQUEST_ID}.json"
            
            # Send confirmation back to dashboard (via status update)
            echo "{\"confirmation\": \"Request $REQUEST_ID queued successfully\"}" > "$HOME/.dj_confirmation.json"
        fi
    fi
}

# Function to simulate a test request
create_test_request() {
    local TEST_ID="REQ-$(date +%s)"
    cat > "$HOME/.pending_dj_request.json" << EOF
{
    "id": "$TEST_ID",
    "song": "${1:-Thunderstruck}",
    "artist": "${2:-AC/DC}",
    "requester": "${3:-Panther 1995}",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    echo "✅ Test request created: $TEST_ID"
}

# Main monitoring loop
monitor_requests() {
    echo "🎧 DJ Request Monitor Started"
    echo "📡 Monitoring dashboard for new requests..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    while true; do
        check_for_new_requests
        sleep $CHECK_INTERVAL
    done
}

# Integration with dashboard JavaScript
generate_request_listener() {
    cat > "$HOME/dj_request_listener.js" << 'EOF'
// DJ Request Listener for Dashboard Integration
// Add this to your dashboard to send requests to the notification system

function sendDJRequest(song, artist, requester) {
    const request = {
        id: 'REQ-' + Date.now(),
        song: song,
        artist: artist,
        requester: requester,
        timestamp: new Date().toISOString()
    };
    
    // Save to localStorage for the monitor to pick up
    localStorage.setItem('pending_dj_request', JSON.stringify(request));
    
    // Visual confirmation
    console.log('🎧 DJ Request Submitted:', request);
    
    // In production, this would send to a webhook endpoint
    fetch('/api/dj-request', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(request)
    }).catch(err => {
        // Fallback to localStorage method
        console.log('Using localStorage fallback for request');
    });
    
    return request.id;
}

// Auto-attach to the existing DJ request form
document.addEventListener('DOMContentLoaded', function() {
    const submitButton = document.getElementById('submitRequest');
    if (submitButton) {
        const originalOnClick = submitButton.onclick;
        submitButton.onclick = function() {
            // Get form values
            const song = document.getElementById('songTitle').value;
            const artist = document.getElementById('artist').value;
            const isPanther = document.getElementById('isPanther').value;
            const gradYear = document.getElementById('gradYear').value;
            
            const requester = isPanther === 'y' ? `Panther ${gradYear}` : 'Guest';
            
            // Send to notification system
            if (song && artist) {
                sendDJRequest(song, artist, requester);
            }
            
            // Call original handler
            if (originalOnClick) originalOnClick();
        };
    }
});
EOF
    echo "✅ Request listener JavaScript generated"
}

# Main execution
case "${1:-monitor}" in
    monitor)
        monitor_requests
        ;;
    test)
        # Create a test request to trigger notification
        create_test_request "$2" "$3" "$4"
        echo "Wait 10 seconds for the monitor to pick it up..."
        ;;
    setup)
        generate_request_listener
        echo "✅ Setup complete. Add dj_request_listener.js to your dashboard"
        ;;
    *)
        echo "Usage: $0 {monitor|test|setup} [song] [artist] [requester]"
        echo ""
        echo "Examples:"
        echo "  $0 monitor              # Start monitoring for requests"
        echo "  $0 test                 # Create test request with default values"
        echo "  $0 test 'Song' 'Artist' 'Name'  # Create custom test request"
        echo "  $0 setup                # Generate JavaScript integration code"
        exit 1
        ;;
esac
