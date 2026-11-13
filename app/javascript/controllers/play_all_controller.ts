import { Controller } from "@hotwired/stimulus"
import { clock, type TransportCommand, type TransportState, type TransportTrack } from "./transport_controller"
import { drawLedgerRule } from "../lib/ledger_rule"
import { moveWhilePlaying, scrollAcross } from "../lib/scroll_across"

// [ PLAY ALL ] on the Archive page, drawn like a page player (Ledger). At
// rest it shows how many recordings and their total time. Playing, it's the
// player of the recording that's on: its title, its own time and progress,
// a rule to click to jump along it (and the arrow keys on the button, 10
// seconds), and [ NEXT ] to load the next while more are to come. The
// transport shuffles the recordings and plays them one after another; its
// bar only shows once you leave this page.
export default class extends Controller<HTMLElement> {
  static targets = ["bar", "button", "title", "time", "previous", "next", "ascii"]
  static values = { tracks: Array }
  declare readonly barTarget: HTMLElement
  declare readonly buttonTarget: HTMLButtonElement
  declare readonly titleTarget: HTMLElement
  declare readonly timeTarget: HTMLElement
  declare readonly previousTarget: HTMLButtonElement
  declare readonly nextTarget: HTMLButtonElement
  declare readonly asciiTarget: HTMLElement
  declare readonly tracksValue: TransportTrack[]

  private restTitle = ""
  private restTime = ""
  private active = false // the set is playing or paused
  private progress = 0
  private started = false
  private resizeObserver?: ResizeObserver
  private titleObserver?: ResizeObserver
  private titleWidth = 0
  private playing = false
  private scrolling?: Animation // a title too long for its line, moving across while playing

  private readonly onState = (event: Event): void => this.show((event as CustomEvent<TransportState>).detail)

  connect(): void {
    this.restTitle = this.titleTarget.textContent ?? ""
    // Measured again when the title's room changes, and when the font arrives
    this.titleObserver = new ResizeObserver(() => requestAnimationFrame(() => {
      if (this.titleTarget.clientWidth !== this.titleWidth) this.scrollTitle()
    }))
    this.titleObserver.observe(this.titleTarget)
    void document.fonts.ready.then(() => this.scrollTitle())
    this.restTime = this.timeTarget.textContent ?? ""
    window.addEventListener("transport:state", this.onState)
    window.dispatchEvent(new CustomEvent("transport:request"))
    this.resizeObserver = new ResizeObserver(() => requestAnimationFrame(() => this.draw()))
    this.resizeObserver.observe(this.asciiTarget)
    void document.fonts.ready.then(() => this.draw())
  }

  disconnect(): void {
    window.removeEventListener("transport:state", this.onState)
    this.resizeObserver?.disconnect()
    this.titleObserver?.disconnect()
    this.scrolling?.cancel()
  }

  // Starts a new shuffle; while the set is on, pauses and resumes it
  toggle(): void {
    this.send(this.active ? { action: "toggle" } : { action: "queue", tracks: this.tracksValue })
  }

  // The set's next recording
  next(): void {
    this.send({ action: "next" })
  }

  // Back to the start of this recording, or in its first seconds to the one
  // before (as the lock screen's previous)
  previous(): void {
    this.send({ action: "previous" })
  }

  // A click on the rule jumps along the recording that's on
  seek(event: MouseEvent): void {
    if (!this.active) return
    const rule = this.asciiTarget.getBoundingClientRect()
    this.send({ action: "seek", ratio: Math.min(1, Math.max(0, (event.clientX - rule.left) / rule.width)) })
  }

  back(event: KeyboardEvent): void {
    this.skip(event, -10)
  }

  forward(event: KeyboardEvent): void {
    this.skip(event, 10)
  }

  private skip(event: KeyboardEvent, seconds: number): void {
    if (!this.active) return
    event.preventDefault()
    this.send({ action: "skip", seconds })
  }

  private show(state: TransportState): void {
    const queue = state.queue
    this.active = Boolean(queue)
    const playing = this.active && state.playing
    this.barTarget.classList.toggle("is-playing", playing)
    this.barTarget.classList.toggle("is-active", this.active)
    this.nextTarget.hidden = !queue || queue.remaining === 0
    this.previousTarget.hidden = !queue || queue.before === 0
    this.buttonTarget.setAttribute("aria-label", playing ? "Pause all recordings" : this.active ? "Play all recordings" : "Play all recordings, shuffled")
    this.playing = playing
    if (queue) {
      this.setTitle(queue.source ? `${queue.title} · ${queue.source}` : queue.title)
      const total = state.duration
      this.timeTarget.textContent = total > 0 ? `${clock(state.currentTime)} / ${clock(total)}` : clock(state.currentTime)
      this.progress = state.ended ? 1 : total > 0 ? state.currentTime / total : 0
      this.started = state.started
    } else {
      this.setTitle(this.restTitle)
      this.timeTarget.textContent = this.restTime
      this.progress = 0
      this.started = false
    }
    this.draw()
  }

  // A new title starts from its beginning, measured afresh; the same one
  // carries on moving (or not) as playback goes
  private setTitle(text: string): void {
    const line = this.titleTarget.querySelector(".pl-ledger__line > span:first-child")
    if (line && line.textContent !== text) {
      line.textContent = text
      this.scrollTitle()
    } else {
      moveWhilePlaying(this.titleTarget, this.scrolling, this.playing)
    }
  }

  // One line always: a title too long for it ends in … and moves across
  // while it plays (scrollAcross, as page players)
  private scrollTitle(): void {
    this.scrolling?.cancel()
    this.titleWidth = this.titleTarget.clientWidth
    this.scrolling = scrollAcross(this.titleTarget, "pl-ledger__copy")
    moveWhilePlaying(this.titleTarget, this.scrolling, this.playing)
  }

  private draw(): void {
    drawLedgerRule(this.asciiTarget, this.progress, this.started)
  }

  private send(command: TransportCommand): void {
    window.dispatchEvent(new CustomEvent<TransportCommand>("transport:command", { detail: command }))
  }
}
