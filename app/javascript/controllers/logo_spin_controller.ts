import { Controller } from "@hotwired/stimulus"

// Turns the ME logo clockwise with scroll, a whole number of turns over the
// page, so it is upright at the very top and back upright at the very bottom.
// It turns for reduced motion too (Tomas's choice, 28 Sep): it only moves as
// you scroll, and it is part of the identity. Scroll is the only thing that
// turns it: the drift while music played is gone (Tomas, 6 Oct), as it left
// the logo crooked at the ends.
export default class extends Controller<HTMLElement> {
  private frame = 0
  private turnDistance = 1440

  connect(): void {
    const distance = parseFloat(getComputedStyle(this.element).getPropertyValue("--logo-turn-distance"))
    if (distance > 0) this.turnDistance = distance
    window.addEventListener("scroll", this.onScroll, { passive: true })
    window.addEventListener("resize", this.onScroll, { passive: true })
    this.update()
  }

  disconnect(): void {
    window.removeEventListener("scroll", this.onScroll)
    window.removeEventListener("resize", this.onScroll)
    cancelAnimationFrame(this.frame)
  }

  private onScroll = (): void => {
    cancelAnimationFrame(this.frame)
    this.frame = requestAnimationFrame(this.update)
  }

  private update = (): void => {
    const scrollable = document.documentElement.scrollHeight - window.innerHeight
    if (scrollable <= 0) {
      this.element.style.transform = ""
      return
    }
    // About one turn per turnDistance of scroll, rounded to whole turns
    const turns = Math.max(1, Math.round(scrollable / this.turnDistance))
    const progress = Math.min(1, window.scrollY / scrollable)
    this.element.style.transform = `rotate(${progress * turns * 360}deg)`
  }
}
