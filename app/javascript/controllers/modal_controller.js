import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setupKeyboardShortcuts()
  }

  show() {
    this.element.classList.remove('hidden')
    this.element.classList.add('flex')
    setTimeout(() => {
      const backdrop = this.element.querySelector('[data-action*="modal#close"]')
      const modal = this.element.querySelector('div[role="dialog"]') || this.element.querySelector('div:last-child > div')
      if (backdrop) backdrop.classList.remove('opacity-0')
      if (modal) modal.classList.remove('scale-95', 'opacity-0')
    }, 10)
  }

  close() {
    const backdrop = this.element.querySelector('[data-action*="modal#close"]')
    const modal = this.element.querySelector('div[role="dialog"]') || this.element.querySelector('div:last-child > div')

    if (backdrop) backdrop.classList.add('opacity-0')
    if (modal) modal.classList.add('scale-95', 'opacity-0')

    setTimeout(() => {
      this.element.classList.add('hidden')
      this.element.classList.remove('flex')
    }, 300)
  }

  handleBackdropClick(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  setupKeyboardShortcuts() {
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        this.close()
      }
    })
  }

  confirm(callback) {
    callback?.()
    this.close()
  }
}
