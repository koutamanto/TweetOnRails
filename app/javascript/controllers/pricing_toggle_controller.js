import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["monthlyBtn", "yearlyBtn", "monthlyPrice", "yearlyPrice", "monthlyForm", "yearlyForm"]

  showMonthly() {
    this.monthlyPriceTarget.classList.remove("hidden")
    this.yearlyPriceTarget.classList.add("hidden")
    this.monthlyFormTarget.classList.remove("hidden")
    this.yearlyFormTarget.classList.add("hidden")
    this.monthlyBtnTarget.classList.add("bg-white", "shadow", "text-gray-900")
    this.monthlyBtnTarget.classList.remove("text-gray-500")
    this.yearlyBtnTarget.classList.remove("bg-white", "shadow", "text-gray-900")
    this.yearlyBtnTarget.classList.add("text-gray-500")
  }

  showYearly() {
    this.yearlyPriceTarget.classList.remove("hidden")
    this.monthlyPriceTarget.classList.add("hidden")
    this.yearlyFormTarget.classList.remove("hidden")
    this.monthlyFormTarget.classList.add("hidden")
    this.yearlyBtnTarget.classList.add("bg-white", "shadow", "text-gray-900")
    this.yearlyBtnTarget.classList.remove("text-gray-500")
    this.monthlyBtnTarget.classList.remove("bg-white", "shadow", "text-gray-900")
    this.monthlyBtnTarget.classList.add("text-gray-500")
  }
}
