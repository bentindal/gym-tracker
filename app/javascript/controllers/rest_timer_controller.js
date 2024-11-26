import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timer", "display"]
  
  connect() {
    if (this.hasTimerTarget) {
      this.startTime = new Date(this.timerTarget.dataset.startTime)
      this.updateTimer()
      this.startTimer()
    }
  }

  updateTimer() {
    const now = new Date()
    const diff = now - this.startTime
    const mins = Math.floor(diff / 60000)
    const secs = Math.floor((diff % 60000) / 1000)
    
    if (mins >= 10) {
      this.displayTarget.textContent = ">10m ago"
      if (this.interval) clearInterval(this.interval)
      return
    }
    
    let msg
    if (mins === 0) {
      msg = `${secs}s ago`
    } else {
      msg = `${mins}m ${secs.toString().padStart(2, '0')}s ago`
    }
    
    this.displayTarget.textContent = msg
  }

  startTimer() {
    // Clear any existing timer to prevent duplicates
    if (this.interval) clearInterval(this.interval)
    
    this.interval = setInterval(() => {
      this.updateTimer()
    }, 1000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }
} 