self.addEventListener('install', event => {
    // No caching during the install phase
});

self.addEventListener('fetch', event => {
    event.respondWith(fetch(event.request));
});
