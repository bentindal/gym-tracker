import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner", "text", "button"]

  connect() {
    // Initialize controller
  }

  start() {
    this.buttonTarget.disabled = true
    this.spinnerTarget.classList.remove("d-none")
    this.textTarget.textContent = "Generating Analysis..."
  }

  stop() {
    // If the page is about to redirect, don't reset the button state
    if (!this.element.closest('.turbo-progress-bar')) {
      this.buttonTarget.disabled = false
      this.spinnerTarget.classList.add("d-none")
      this.textTarget.innerHTML = '<i class="fa-solid fa-magic mr-2"></i>Generate Analysis'
    }
  }
} 