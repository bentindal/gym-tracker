import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner", "text"]

  show() {
    this.spinnerTarget.classList.remove("d-none")
    this.textTarget.classList.add("d-none")
  }
} 