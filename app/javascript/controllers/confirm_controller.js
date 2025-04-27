import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('click', this.handleClick.bind(this))
  }

  handleClick(event) {
    if (this.element.dataset.confirm) {
      if (!confirm(this.element.dataset.confirm)) {
        event.preventDefault()
        event.stopPropagation()
      }
    }
  }
} 