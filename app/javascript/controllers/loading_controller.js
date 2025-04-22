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
    this.buttonTarget.disabled = true
    this.spinnerTarget.classList.remove("d-none")
    this.textTarget.textContent = "Generating Analysis..."
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("d-none")
    }
  }

  hideLoading() {
    this.buttonTarget.disabled = false
    this.spinnerTarget.classList.add("d-none")
    this.textTarget.innerHTML = '<i class="fa-solid fa-magic mr-2"></i>Generate Analysis'
  }

  submitForm() {
    const form = this.element
    const formData = new FormData(form)
    
    // Add a loading class to the body to handle Safari-specific styles
    document.body.classList.add('loading-analysis')
    
    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'text/html' // Change from turbo-stream to html for better Safari support
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      // Remove loading class
      document.body.classList.remove('loading-analysis')
      // After successful submission, reload the page to show the analysis
      window.location.reload()
    })
    .catch(error => {
      // Remove loading class on error
      document.body.classList.remove('loading-analysis')
      this.hideLoading()
      if (this.hasErrorTarget && this.hasErrorMessageTarget) {
        this.errorTarget.classList.remove("d-none")
        this.errorMessageTarget.textContent = "Failed to generate analysis. Please try again later."
      }
      console.error('Error:', error)
    })
  }
} 