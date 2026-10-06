import { Controller } from "@hotwired/stimulus"

// Turbo changes pages without a full load, and those changes don't update
// document.referrer, so remember them here (this module lives as long as the
// tab does)
let movedWithinSite = false
document.addEventListener("turbo:visit", () => { movedWithinSite = true })

// "← Back": one step back when you got here from another page on this site,
// otherwise follow the link (the section on the home page).
export default class extends Controller<HTMLAnchorElement> {
  go(event: Event): void {
    const cameFromHere = movedWithinSite ||
      (document.referrer !== "" && new URL(document.referrer).origin === window.location.origin)
    if (cameFromHere && window.history.length > 1) {
      event.preventDefault()
      window.history.back()
    }
  }
}
