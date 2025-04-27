import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner", "text", "button", "error", "errorMessage"]

  connect() {
    // Initialize controller
  }

  submit(event) {
    event.preventDefault()
    this.showLoading()
    this.submitForm()
  }

  showLoading() {
    // Show the spinner and update button text
    this.spinnerTarget.classList.remove("d-none")
    this.textTarget.textContent = "Generating Analysis..."
    this.buttonTarget.disabled = true
    this.buttonTarget.classList.add('disabled')
    
    // Hide any previous error messages
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("d-none")
    }
  }

  hideLoading() {
    // Hide the spinner and restore button text
    this.spinnerTarget.classList.add("d-none")
    this.textTarget.innerHTML = '<i class="fa-solid fa-magic mr-2"></i>Generate Analysis'
    this.buttonTarget.disabled = false
    this.buttonTarget.classList.remove('disabled')
  }

  submitForm() {
    const form = this.element
    const formData = new FormData(form)
    
    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/html'
      },
      redirect: 'follow' // Ensure we follow redirects
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      // Follow the redirect
      window.location.href = response.url
    })
    .catch(error => {
      this.hideLoading()
      if (this.hasErrorTarget && this.hasErrorMessageTarget) {
        this.errorTarget.classList.remove("d-none")
        this.errorMessageTarget.textContent = "Failed to generate analysis. Please try again later."
      }
      console.error('Error:', error)
    })
  }
} 