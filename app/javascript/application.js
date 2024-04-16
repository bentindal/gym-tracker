// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"
import "chartkick/chart.js"

if (navigator.serviceWorker) {
    navigator.serviceWorker.register("/service-worker.js", { scope: "/" })
      .then(() => navigator.serviceWorker.ready)
      .then((registration) => {
        if ("SyncManager" in window) {
          registration.sync.register("sync-forms");
        } else {
          window.alert("This browser does not support background sync.")
        }
      }).then(() => console.log("[Companion]", "Service worker registered!"));
}