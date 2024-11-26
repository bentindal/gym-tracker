import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "count", "likedBy"]

  toggle(event) {
    event.preventDefault()
    
    const url = this.buttonTarget.getAttribute("href")
    
    fetch(url, {
      headers: {
        "Accept": "application/json"
      }
    })
    .then(response => response.json())
    .then(data => {
      this.buttonTarget.classList.toggle("btn-danger")
      this.buttonTarget.classList.toggle("btn-outline-danger")
      
      const heartIcon = this.buttonTarget.querySelector("i")
      heartIcon.classList.toggle("text-white")
      heartIcon.classList.toggle("text-danger")
      
      this.countTarget.textContent = data.count
      this.likedByTarget.textContent = this.getLikedByText(data)
    })
  }

  getLikedByText(data) {
    if (data.count === 0) {
      return "No one has liked this workout yet."
    }
    return `Liked by ${data.liked_by.join(", ")}`
  }
} 