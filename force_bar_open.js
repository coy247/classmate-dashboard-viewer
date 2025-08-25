// Force Bar Open Immediately
// Copy this entire code and run in browser console, or save as bookmarklet

javascript:(function(){
    console.log('🍺 Forcing bar OPEN!');
    
    // Find the bar elements
    const djBar = document.getElementById('djBar');
    const barStatus = document.getElementById('barStatus');
    const barMessage = document.getElementById('barMessage');
    const requestForm = document.getElementById('requestForm');
    
    if (djBar && barStatus && barMessage) {
        // Open the bar
        djBar.classList.remove('closed');
        barStatus.innerHTML = '🍺🎉 GIA & MELISSA\'S ALL YOU CAN DRINK BAR IS OPEN!! 🎉🍺';
        barMessage.innerHTML = `
            🎵 Your AWESOME Bot DJ is NOW ACCEPTING REQUESTS! 🎵<br>
            🎧 El Sonidito on ETERNAL REPEAT (x1283 and counting!) 🎧<br>
            🎶 To enhance your Big Brother surveillance interactive experience!
        `;
        if (requestForm) {
            requestForm.classList.add('active');
        }
        
        console.log('✅ Bar is now OPEN!');
        console.log('🎵 El Sonidito x1283 - OBSESSION MODE ACTIVATED!');
        
        // Also update the events to show music status
        const eventsList = document.getElementById('eventsList');
        if (eventsList && eventsList.children.length > 0) {
            eventsList.children[0].innerHTML = '🔥 OBSESSION MODE! Hechizeros Band - El Sonidito x1283!';
        }
        
        // Save state to prevent it from closing
        window.barOpen = true;
        
    } else {
        console.error('Could not find bar elements. Make sure you are on the dashboard page.');
    }
})();
