// Cleanup script to fix erroneous "1283th time" entries in dashboard history
// Run this in the browser console at https://coy247.github.io/classmate-dashboard-viewer/

(() => {
    console.log('🧹 Starting history cleanup...');
    
    // Get current history from localStorage
    const historyData = JSON.parse(localStorage.getItem('dashboardHistory') || '[]');
    console.log(`Found ${historyData.length} history entries`);
    
    // Fix erroneous entries
    let fixedCount = 0;
    const cleanedHistory = historyData.map(entry => {
        // Check if this entry has the erroneous "1283th time" text
        if (entry.event && entry.event.includes('1283th time')) {
            fixedCount++;
            // Replace with corrected format
            entry.event = entry.event.replace('for the 1283th time', 'x1283');
            entry.event = entry.event.replace('REPEAT CHAMPIONSHIP!', 'OBSESSION MODE!');
            console.log(`Fixed entry from ${entry.time}: ${entry.event}`);
        }
        return entry;
    });
    
    // Remove duplicate entries (same event within 1 minute)
    const deduped = [];
    const seen = new Set();
    
    cleanedHistory.forEach(entry => {
        // Create a key from event text and approximate time (minute precision)
        const eventTime = new Date(entry.timestamp);
        const minuteKey = `${entry.event}_${eventTime.getHours()}_${eventTime.getMinutes()}`;
        
        if (!seen.has(minuteKey)) {
            seen.add(minuteKey);
            deduped.push(entry);
        }
    });
    
    const duplicatesRemoved = cleanedHistory.length - deduped.length;
    
    // Save cleaned history back to localStorage
    localStorage.setItem('dashboardHistory', JSON.stringify(deduped));
    
    console.log('✅ History cleanup complete!');
    console.log(`📝 Fixed ${fixedCount} erroneous entries`);
    console.log(`🗑️ Removed ${duplicatesRemoved} duplicate entries`);
    console.log(`📊 Final history count: ${deduped.length} entries`);
    
    // Force reload the page to show cleaned history
    console.log('🔄 Reloading page to show cleaned history...');
    setTimeout(() => location.reload(true), 1000);
})();
