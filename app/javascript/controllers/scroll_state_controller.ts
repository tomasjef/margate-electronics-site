import { Controller } from "@hotwired/stimulus"

// Marks <body> with .is-scrolled once the page leaves the top, for the
// sticky site name.
export default class extends Controller<HTMLElement> {
  private frame = 0

  connect(): void {
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.update()
  }

  disconnect(): void {
    window.removeEventListener("scroll", this.onScroll)
    cancelAnimationFrame(this.frame)
  }

  private onScroll = (): void => {
    cancelAnimationFrame(this.frame)
    this.frame = requestAnimationFrame(this.update)
  }

  private update = (): void => {
    this.element.classList.toggle("is-scrolled", window.scrollY > 0)
  }
}
