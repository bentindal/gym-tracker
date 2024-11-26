self.addEventListener('install', event => {
    // No caching during the install phase
});

self.addEventListener('fetch', event => {
    if (event.request.url.includes('/allset/')) {
        // Don't cache exercise set pages
        event.respondWith(
            fetch(event.request)
                .catch(error => {
                    console.log('Fetch failed for:', event.request.url, error);
                    // Return a response that indicates the network request failed
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
                // Return a response that indicates the network request failed
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
