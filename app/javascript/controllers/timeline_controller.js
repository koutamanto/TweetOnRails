import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["banner", "count"]

  connect() {
    this.since = new Date().toISOString()
    this.pending = 0

    this.channel = consumer.subscriptions.create("TimelineChannel", {
      received: () => {
        this.pending++
        this.countTarget.textContent = this.pending
        this.bannerTarget.classList.remove("hidden")
      }
    })
  }

  disconnect() {
    this.channel?.unsubscribe()
  }

  async load() {
    const csrf = document.querySelector("meta[name='csrf-token']")?.content
    const res = await fetch(`/home/new_tweets?since=${encodeURIComponent(this.since)}`, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": csrf
      }
    })
    if (!res.ok) return
    const html = await res.text()
    Turbo.renderStreamMessage(html)
    this.since = new Date().toISOString()
    this.pending = 0
    this.bannerTarget.classList.add("hidden")
    window.scrollTo({ top: 0, behavior: "smooth" })
  }
}
