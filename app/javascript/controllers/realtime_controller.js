import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["notifBadge", "notifDot", "dmBadge", "dmDot"]

  connect() {
    this.channel = consumer.subscriptions.create("UserChannel", {
      received: (data) => {
        if (data.type === "notif_count") this.updateNotif(data.count)
        if (data.type === "dm_count")    this.updateDm(data.count)
      }
    })
  }

  disconnect() {
    this.channel?.unsubscribe()
  }

  updateNotif(count) {
    this.notifBadgeTargets.forEach(el => {
      el.textContent = count > 99 ? "99+" : count
      el.classList.toggle("hidden", count === 0)
    })
    this.notifDotTargets.forEach(el => el.classList.toggle("hidden", count === 0))
  }

  updateDm(count) {
    this.dmBadgeTargets.forEach(el => {
      el.textContent = count > 99 ? "99+" : count
      el.classList.toggle("hidden", count === 0)
    })
    this.dmDotTargets.forEach(el => el.classList.toggle("hidden", count === 0))
  }
}
