import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["monthlyBtn", "yearlyBtn", "monthlyPrice", "yearlyPrice", "monthlyForm", "yearlyForm"]

  connect() {
    this._setActive("monthly", false)
  }

  showMonthly() {
    this._setActive("monthly", true)
  }

  showYearly() {
    this._setActive("yearly", true)
  }

  _setActive(interval, animate) {
    const isMonthly = interval === "monthly"

    if (animate) {
      this._fadeSwap(
        isMonthly ? this.yearlyPriceTarget  : this.monthlyPriceTarget,
        isMonthly ? this.monthlyPriceTarget : this.yearlyPriceTarget
      )
      if (this.hasMonthlyFormTarget && this.hasYearlyFormTarget) {
        this._fadeSwap(
          isMonthly ? this.yearlyFormTarget  : this.monthlyFormTarget,
          isMonthly ? this.monthlyFormTarget : this.yearlyFormTarget
        )
      }
    } else {
      this.monthlyPriceTarget.classList.toggle("hidden", !isMonthly)
      this.yearlyPriceTarget.classList.toggle("hidden", isMonthly)
      if (this.hasMonthlyFormTarget && this.hasYearlyFormTarget) {
        this.monthlyFormTarget.classList.toggle("hidden", !isMonthly)
        this.yearlyFormTarget.classList.toggle("hidden", isMonthly)
      }
    }

    // Toggle button styles
    this._setBtn(this.monthlyBtnTarget, isMonthly)
    this._setBtn(this.yearlyBtnTarget, !isMonthly)

    this.monthlyBtnTarget.setAttribute("aria-pressed", isMonthly)
    this.yearlyBtnTarget.setAttribute("aria-pressed", !isMonthly)
  }

  _setBtn(btn, active) {
    btn.classList.toggle("bg-white", active)
    btn.classList.toggle("shadow", active)
    btn.classList.toggle("text-gray-900", active)
    btn.classList.toggle("text-gray-500", !active)
  }

  _fadeSwap(outEl, inEl) {
    outEl.style.opacity = "0"
    outEl.style.transform = "translateY(-4px)"
    setTimeout(() => {
      outEl.classList.add("hidden")
      outEl.style.opacity = ""
      outEl.style.transform = ""
      inEl.classList.remove("hidden")
      inEl.style.opacity = "0"
      inEl.style.transform = "translateY(4px)"
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          inEl.style.transition = "opacity 150ms ease, transform 150ms ease"
          inEl.style.opacity = "1"
          inEl.style.transform = "translateY(0)"
          inEl.addEventListener("transitionend", () => {
            inEl.style.transition = ""
            inEl.style.opacity = ""
            inEl.style.transform = ""
          }, { once: true })
        })
      })
    }, 120)
  }
}
