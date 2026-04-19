import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { duration: { type: Number, default: 5000 } }

  connect() {
    this.setupDismissal()
    this.autoRemove()
  }

  setupDismissal() {
    const dismissBtn = this.element.querySelector('[data-dismissible="toast"]')
    if (dismissBtn) {
      dismissBtn.addEventListener('click', () => this.remove())
    }
  }

  autoRemove() {
    setTimeout(() => this.remove(), this.durationValue)
  }

  remove() {
    this.element.style.animation = 'fadeOut 300ms ease-out'
    setTimeout(() => this.element.remove(), 300)
  }
}
