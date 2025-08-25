// Force clear cache and reload the dashboard
// Run this in browser console at https://coy247.github.io/classmate-dashboard-viewer/

console.log('🔄 Forcing cache clear and reload...');

// Clear all caches
if ('caches' in window) {
    caches.keys().then(names => {
        names.forEach(name => {
            caches.delete(name);
            console.log(`Deleted cache: ${name}`);
        });
    });
}

// Clear localStorage history to force fresh data
localStorage.clear();
sessionStorage.clear();

// Force hard reload with cache bypass
setTimeout(() => {
    console.log('Reloading page...');
    window.location.href = window.location.href.split('#')[0] + '?cachebust=' + Date.now();
}, 1000);
