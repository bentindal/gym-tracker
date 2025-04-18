self.addEventListener('install', event => {
    // No caching during the install phase
});

self.addEventListener('fetch', event => {
    // Don't cache Turbo Stream responses
    if (event.request.headers.get('Accept') === 'text/vnd.turbo-stream.html') {
        event.respondWith(fetch(event.request));
        return;
    }

    // Don't cache dynamic content
    if (event.request.url.includes('/allset/') || 
        event.request.url.includes('rest-timer') ||
        event.request.url.includes('timer') ||
        event.request.url.includes('dashboard-content') ||
        event.request.url.includes('workout-summary')) {
        event.respondWith(
            fetch(event.request)
                .catch(error => {
                    console.log('Fetch failed for:', event.request.url, error);
                    return new Response('Network error', {
                        status: 503,
                        statusText: 'Service Unavailable',
                        headers: new Headers({
                            'Content-Type': 'text/plain'
                        })
                    });
                })
        );
        return;
    }
    
    event.respondWith(
        fetch(event.request)
            .catch(error => {
                console.log('Fetch failed for:', event.request.url, error);
                return new Response('Network error', {
                    status: 503,
                    statusText: 'Service Unavailable',
                    headers: new Headers({
                        'Content-Type': 'text/plain'
                    })
                });
            })
    );
});
