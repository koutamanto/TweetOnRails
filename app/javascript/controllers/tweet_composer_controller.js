import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "counter", "submitBtn", "mediaPreview", "mediaInput"]
  static values = { maxLength: { type: Number, default: 280 } }

  connect() {
    this.updateCounter()
  }

  update() {
    this.updateCounter()
  }

  updateCounter() {
    const len = this.textareaTarget.value.length
    const remaining = this.maxLengthValue - len
    this.counterTarget.textContent = remaining

    this.counterTarget.classList.remove("text-gray-400", "text-yellow-500", "text-red-500")
    if (remaining < 0) {
      this.counterTarget.classList.add("text-red-500")
      this.submitBtnTarget.disabled = true
    } else if (remaining < 20) {
      this.counterTarget.classList.add("text-yellow-500")
      this.submitBtnTarget.disabled = false
    } else {
      this.counterTarget.classList.add("text-gray-400")
      this.submitBtnTarget.disabled = len === 0
    }
  }

  previewMedia(event) {
    const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB
    const files = Array.from(event.target.files)
    const oversized = files.filter(f => f.size > MAX_FILE_SIZE)

    if (oversized.length > 0) {
      alert(`ファイルサイズは10MB以内にしてください（${oversized.map(f => f.name).join(", ")}）`)
      event.target.value = ""
      this.mediaPreviewTarget.innerHTML = ""
      this.mediaPreviewTarget.classList.add("hidden")
      return
    }

    this.mediaPreviewTarget.innerHTML = ""
    this.mediaPreviewTarget.classList.toggle("hidden", files.length === 0)

    files.forEach(file => {
      const reader = new FileReader()
      reader.onload = (e) => {
        let el
        if (file.type.startsWith("image/")) {
          el = document.createElement("img")
          el.src = e.target.result
          el.className = "w-full h-40 object-cover rounded-xl"
        } else if (file.type.startsWith("video/")) {
          el = document.createElement("video")
          el.src = e.target.result
          el.className = "w-full h-40 object-cover rounded-xl"
          el.controls = true
        }
        if (el) this.mediaPreviewTarget.appendChild(el)
      }
      reader.readAsDataURL(file)
    })
  }

  autoResize() {
    this.textareaTarget.style.height = "auto"
    this.textareaTarget.style.height = this.textareaTarget.scrollHeight + "px"
    this.update()
  }
}
