import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-dismiss after 4 seconds
    this.timeout = setTimeout(() => this.dismiss(), 4000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.4s ease, max-height 0.4s ease"
    this.element.style.opacity = "0"
    this.element.style.maxHeight = "0"
    this.element.style.overflow = "hidden"
    setTimeout(() => this.element.remove(), 400)
  }
}
