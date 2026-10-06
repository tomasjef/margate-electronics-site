import { Controller } from "@hotwired/stimulus"

// "Menu" drops the menu block from the top of the window, over the page
// (shared/_menu). Lives on <body>. While it's open the page behind doesn't
// scroll; Esc, Close or a click on the page closes it, and focus goes back
// to the Menu button. Phones, at the top of the page: the block sits in the
// page instead, in the header's place, pushing the page down (menu-flow on
// <html>; the page scrolls as usual). Mid-page, from the grey bar, it rolls
// down over the page where you are. Over the page, everything else is inert
// while it's open, so Tab and screen readers stay in the menu.
const PHONE = window.matchMedia("(max-width: 767px)")

export default class extends Controller<HTMLElement> {
  static targets = ["panel", "button"]
  declare readonly panelTarget: HTMLElement
  declare readonly buttonTargets: HTMLButtonElement[]

  private opener?: HTMLElement

  // Turbo keeps a copy of the page you leave and shows it for a moment on
  // the way back: closed first, so a page left through the menu never comes
  // back with it open (a flash of the menu; Tomas, 6 Oct)
  private readonly onBeforeCache = (): void => {
    this.panelTarget.hidden = true
    this.setButtons(false)
    this.clearPageState()
  }

  connect(): void {
    // A page change while open (a link in the menu) leaves <html> as it was
    this.clearPageState()
    document.addEventListener("turbo:before-cache", this.onBeforeCache)
  }

  disconnect(): void {
    this.clearPageState()
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
  }

  toggle(event: Event): void {
    if (this.panelTarget.hidden) this.open(event.currentTarget as HTMLElement)
    else this.close()
  }

  close(): void {
    if (this.panelTarget.hidden) return
    this.panelTarget.hidden = true
    this.clearPageState()
    this.setButtons(false)
    this.opener?.focus({ preventScroll: true })
  }

  private open(opener: HTMLElement): void {
    this.opener = opener
    this.panelTarget.hidden = false
    const inFlow = PHONE.matches && !opener.closest(".sticky-name")
    document.documentElement.classList.add(inFlow ? "menu-flow" : "has-menu")
    if (!inFlow) this.makePageInert()
    this.setButtons(true)
    this.panelTarget.querySelector<HTMLElement>(".menu-drop__links a")?.focus({ preventScroll: true })
  }

  private clearPageState(): void {
    document.documentElement.classList.remove("has-menu", "menu-flow")
    for (const element of document.querySelectorAll<HTMLElement>("[data-menu-inert]")) {
      element.inert = false
      delete element.dataset.menuInert
    }
  }

  // Everything on the page but the menu, out of reach while it's over it
  private makePageInert(): void {
    for (const element of document.body.children) {
      if (!(element instanceof HTMLElement) || element === this.panelTarget || element.inert) continue
      element.inert = true
      element.dataset.menuInert = ""
    }
  }

  private setButtons(open: boolean): void {
    for (const button of this.buttonTargets) button.setAttribute("aria-expanded", String(open))
  }
}
