import { Controller } from "@hotwired/stimulus"
import type { TransportCommand, TransportState } from "./transport_controller"

// Keyboard shortcuts, on <body>: Space plays or pauses what's in the
// transport, ← goes Back and → to the Next entry (the links' own behaviour,
// by clicking them). Left alone while typing, on a focused button or player
// (a player's own arrows skip 10 seconds), with a modifier key, or while the
// lightbox or the phone menu is open.
export default class extends Controller<HTMLElement> {
  private transportActive = false

  private readonly onState = (event: Event): void => {
    this.transportActive = (event as CustomEvent<TransportState>).detail.active
  }

  connect(): void {
    window.addEventListener("transport:state", this.onState)
    window.addEventListener("keydown", this.onKey)
    window.dispatchEvent(new CustomEvent("transport:request"))
  }

  disconnect(): void {
    window.removeEventListener("transport:state", this.onState)
    window.removeEventListener("keydown", this.onKey)
  }

  private onKey = (event: KeyboardEvent): void => {
    if (event.defaultPrevented || event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return
    const target = event.target as Element | null
    if (target?.closest("input, textarea, select, button, [contenteditable], .track")) return
    if (document.querySelector("dialog[open], .site-menu:not([hidden])")) return

    if (event.key === " ") {
      // Nothing loaded: Space scrolls the page as usual
      if (!this.transportActive) return
      event.preventDefault()
      window.dispatchEvent(new CustomEvent<TransportCommand>("transport:command", { detail: { action: "toggle" } }))
    } else if (event.key === "ArrowLeft") {
      this.follow(".back-link", event)
    } else if (event.key === "ArrowRight") {
      this.follow("a.next-link[rel=next]", event)
    }
  }

  private follow(selector: string, event: KeyboardEvent): void {
    const link = document.querySelector<HTMLAnchorElement>(selector)
    if (!link) return
    event.preventDefault()
    link.click()
  }
}
