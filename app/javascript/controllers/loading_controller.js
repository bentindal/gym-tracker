import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["spinner", "text", "error", "errorMessage", "button"]

  connect() {
    this.originalHTML = this.element.innerHTML
  }

  start() {
    this.buttonTarget.disabled = true
    this.spinnerTarget.classList.remove("d-none")
    this.textTarget.textContent = "Generating Analysis..."
  }

  stop() {
    this.buttonTarget.disabled = false
    this.spinnerTarget.classList.add("d-none")
    this.textTarget.innerHTML = '<i class="fa-solid fa-magic mr-2"></i>Generate Analysis'
  }

  submit(event) {
    event.preventDefault()
    this.showLoading()
    this.submitForm()
  }

  showLoading() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("d-none")
    }
    if (this.hasTextTarget) {
      this.textTarget.classList.add("d-none")
    }
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("d-none")
    }
  }

  submitForm() {
    const form = this.element
    const formData = new FormData(form)
    
    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.json()
    })
    .then(data => {
      if (data.success) {
        this.handleSuccess(data)
      } else {
        this.handleError({ error: data.error })
      }
    })
    .catch(error => {
      this.handleError({ error: error.message })
    })
  }

  handleSuccess(data) {
    // Create the analysis card HTML
    const analysisHTML = `
      <div class="container">
        <div class="row pt-4">
          <div class="col-12">
            <div class="card shadow-sm">
              <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                  <i class="fa-solid fa-robot mr-2"></i>
                  AI Analysis
                </h5>
                <small class="text-white-50">
                  ${new Date(data.analysis.created_at).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                </small>
              </div>
              <div class="card-body">
                <div class="p-3 rounded bg-light border-left border-primary border-4">
                  ${data.analysis.feedback.split('\n\n').map(paragraph => `<p class="mb-3">${paragraph.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')}</p>`).join('')}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    `
    
    // Replace the form with the analysis
    const container = this.element.closest('.container')
    container.outerHTML = analysisHTML
  }

  handleError(error) {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove("d-none")
    }
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.textContent = error.error || "An error occurred while generating the analysis"
    }
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("d-none")
    }
    if (this.hasTextTarget) {
      this.textTarget.classList.remove("d-none")
    }
  }
} 