import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  
  connect() {
    if (this.hasDisplayTarget) {
      this.startTime = new Date(this.displayTarget.dataset.startTime)
      this.updateTimer()
      this.startTimer()
    }
  }

  updateTimer() {
    const now = new Date()
    const diff = now - this.startTime
    const hours = Math.floor(diff / 3600000)
    const minutes = Math.floor((diff % 3600000) / 60000)
    const seconds = Math.floor((diff % 60000) / 1000)
    
    this.displayTarget.textContent = 
      `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
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