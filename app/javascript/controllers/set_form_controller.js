import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  submit(event) {
    event.preventDefault()
    
    const form = this.formTarget
    const formData = new FormData(form)
    
    fetch(form.action, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.text()
    })
    .then(html => {
      // Parse the Turbo Stream response
      const parser = new DOMParser()
      const doc = parser.parseFromString(html, "text/html")
      
      // Find and execute all turbo-stream elements
      const turboStreams = doc.querySelectorAll("turbo-stream")
      turboStreams.forEach(stream => {
        const action = stream.getAttribute("action")
        const target = stream.getAttribute("target")
        const content = stream.querySelector("template").content
        
        switch(action) {
          case "replace":
            const element = document.getElementById(target)
            if (element) {
              element.replaceWith(content)
            }
            break
          default:
            console.warn(`Unhandled Turbo Stream action: ${action} for target: ${target}`)
            break
        }
      })
      
      // Reset the form but preserve checkbox states
      const checkboxes = form.querySelectorAll("input[type='checkbox']")
      const checkboxStates = Array.from(checkboxes).map(checkbox => ({
        name: checkbox.name,
        checked: checkbox.checked
      }))
      
      form.reset()
      
      // Restore checkbox states
      checkboxStates.forEach(state => {
        const checkbox = form.querySelector(`input[name="${state.name}"]`)
        if (checkbox) {
          checkbox.checked = state.checked
        }
      })
    })
    .catch(error => {
      console.error("Error:", error)
      // Show error message to user
      const errorDiv = document.createElement('div')
      errorDiv.className = 'alert alert-danger mt-2'
      errorDiv.textContent = 'Failed to create set. Please try again.'
      form.parentNode.insertBefore(errorDiv, form.nextSibling)
      
      // Remove error message after 3 seconds
      setTimeout(() => {
        errorDiv.remove()
      }, 3000)
    })
  }
} 