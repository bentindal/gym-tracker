// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"
import "chartkick/chart.js"


// This file is newly created to register the service worker

if ('serviceWorker' in navigator) {

  navigator.serviceWorker.register('/service_worker/service_worker.js')

    .then(function(registration) {

      //console.log('ServiceWorker registration successful with scope: ', registration.scope);

    })

    .catch(function(error) {

      console.log('ServiceWorker registration failed: ', error);

    });

}
