import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timer", "display"]
  
  connect() {
    console.log("Rest timer controller connected")
    console.log("Element:", this.element)
    console.log("Element HTML:", this.element.outerHTML)
    
    if (this.hasTimerTarget && this.hasDisplayTarget) {
      console.log("Timer targets found")
      this.startTime = new Date(this.timerTarget.dataset.startTime)
      console.log("Start time:", this.startTime)
      this.updateTimer()
      this.startTimer()
    } else {
      console.log("Missing timer targets:", {
        hasTimer: this.hasTimerTarget,
        hasDisplay: this.hasDisplayTarget
      })
    }
  }

  updateTimer() {
    const now = new Date()
    const diff = now - this.startTime
    const mins = Math.floor(diff / 60000)
    const secs = Math.floor((diff % 60000) / 1000)
    
    if (mins >= 10) {
      this.displayTarget.textContent = ">10m ago"
      this.stopTimer()
      return
    }
    
    let msg
    if (mins === 0) {
      msg = `${secs}s ago`
    } else {
      msg = `${mins}m ${secs.toString().padStart(2, '0')}s ago`
    }
    
    console.log("Updating timer display:", msg)
    this.displayTarget.textContent = msg
  }

  startTimer() {
    console.log("Starting timer")
    this.stopTimer()
    this.interval = setInterval(() => {
      this.updateTimer()
    }, 1000)
  }

  stopTimer() {
    if (this.interval) {
      console.log("Stopping timer")
      clearInterval(this.interval)
      this.interval = null
    }
  }

  disconnect() {
    console.log("Rest timer controller disconnected")
    this.stopTimer()
  }
} 