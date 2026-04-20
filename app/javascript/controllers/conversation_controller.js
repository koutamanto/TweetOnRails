import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["messages", "input"]
  static values = { conversationId: Number }

  connect() {
    this.scrollToBottom()
    this.channel = consumer.subscriptions.create(
      { channel: "ConversationChannel", conversation_id: this.conversationIdValue },
      {
        received: (data) => {
          this.messagesTarget.insertAdjacentHTML("beforeend", data.html)
          this.scrollToBottom()
        }
      }
    )

    // Scroll to bottom after any turbo stream append
    document.addEventListener("turbo:before-stream-render", this._onTurboStream = () => {
      requestAnimationFrame(() => this.scrollToBottom())
    })
  }

  disconnect() {
    this.channel?.unsubscribe()
    document.removeEventListener("turbo:before-stream-render", this._onTurboStream)
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  clearInput() {
    if (this.hasInputTarget) this.inputTarget.value = ""
    requestAnimationFrame(() => this.scrollToBottom())
  }

  submitOnEnter(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.element.querySelector("form").requestSubmit()
    }
  }
}
