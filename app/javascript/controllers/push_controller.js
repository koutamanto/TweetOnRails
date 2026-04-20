import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["prompt"]
  static values  = { vapidKey: String }

  async connect() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) return

    const reg = await navigator.serviceWorker.ready

    if (Notification.permission === "granted") {
      const existing = await reg.pushManager.getSubscription()
      if (existing) { await this.sync(existing); return }
      await this.subscribe(reg)
      return
    }

    if (Notification.permission === "default") {
      const dismissed = localStorage.getItem("push_prompt_dismissed")
      if (!dismissed && this.hasPromptTarget) {
        this.promptTarget.classList.remove("hidden")
      }
    }
  }

  async requestPermission() {
    const permission = await Notification.requestPermission()
    if (this.hasPromptTarget) this.promptTarget.classList.add("hidden")
    if (permission !== "granted") return
    const reg = await navigator.serviceWorker.ready
    await this.subscribe(reg)
  }

  dismiss() {
    localStorage.setItem("push_prompt_dismissed", "1")
    if (this.hasPromptTarget) this.promptTarget.classList.add("hidden")
  }

  async subscribe(reg) {
    try {
      const sub = await reg.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidKeyValue)
      })
      await this.sync(sub)
    } catch (e) {
      console.warn("[Push] subscribe failed:", e)
    }
  }

  async sync(sub) {
    const json = sub.toJSON()
    const csrf = document.querySelector("meta[name='csrf-token']")?.content
    await fetch("/push_subscriptions", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrf },
      body: JSON.stringify({ endpoint: json.endpoint, p256dh: json.keys.p256dh, auth: json.keys.auth })
    })
  }

  urlBase64ToUint8Array(b64) {
    const padding = "=".repeat((4 - (b64.length % 4)) % 4)
    const base64  = (b64 + padding).replace(/-/g, "+").replace(/_/g, "/")
    const raw     = atob(base64)
    return Uint8Array.from([...raw].map(c => c.charCodeAt(0)))
  }
}
