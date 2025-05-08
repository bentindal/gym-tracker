// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
console.log("Starting to load application.js")

// Import all required modules
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "@hotwired/stimulus-loading"
import "controllers"
import "chartkick"
import "Chart.bundle"
import "bootstrap"

console.log("Application JavaScript loaded")

// Service Worker registration disabled
// if ('serviceWorker' in navigator) {
//   window.addEventListener('load', function() {
//     navigator.serviceWorker.register('/service_worker.js').then(function(registration) {
//       console.log('ServiceWorker registration successful with scope: ', registration.scope);
//     }, function(error) {
//       console.log('ServiceWorker registration failed: ', error);
//     });
//   });
// }
