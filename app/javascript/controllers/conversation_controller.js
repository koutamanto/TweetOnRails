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
  }

  disconnect() {
    this.channel?.unsubscribe()
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  clearInput() {
    if (this.hasInputTarget) this.inputTarget.value = ""
  }
}
