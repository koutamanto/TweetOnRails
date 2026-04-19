import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    if (!this.hasMenuTarget) return
    this.menuTarget.classList.toggle('hidden')
  }

  close(event) {
    if (!this.hasMenuTarget) return
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('hidden')
    }
  }
}
