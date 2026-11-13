import { Controller } from "@hotwired/stimulus"

// A ledger row opens its entry wherever it's clicked. (A link stretched
// over the row with CSS went wrong in Safari: the row isn't reliably the
// link's containing block there, so rows covered each other.) The title's
// link stays the real link for keyboards and screen readers.
export default class extends Controller<HTMLTableElement> {
  open(event: MouseEvent): void {
    const target = event.target as Element
    if (target.closest("a") || window.getSelection()?.toString()) return
    const link = target.closest("tbody tr")?.querySelector<HTMLAnchorElement>(".ledger__title a")
    if (!link) return
    link.dispatchEvent(new MouseEvent("click", {
      bubbles: true, cancelable: true,
      ctrlKey: event.ctrlKey, metaKey: event.metaKey, shiftKey: event.shiftKey, altKey: event.altKey
    }))
  }
}
