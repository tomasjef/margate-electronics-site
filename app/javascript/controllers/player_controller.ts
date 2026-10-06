import { Controller } from "@hotwired/stimulus"
import { clock, type TransportCommand, type TransportState } from "./transport_controller"
import { drawLedgerRule } from "../lib/ledger_rule"
import { moveWhilePlaying, scrollAcross } from "../lib/scroll_across"

// A track on a page: [ PLAY ] / [ STOP ], progress, elapsed / total time, click
// the rule to jump. The sound plays in the shared transport (transport
// controller), so it carries on across pages; this sends it commands and
// draws the state it reports for this track.
export default class extends Controller<HTMLElement> {
  static targets = ["bar", "button", "time", "ascii", "title"]
  static values = { src: String, title: String, source: String, sourceUrl: String }
  declare readonly barTarget: HTMLElement
  declare readonly buttonTarget: HTMLButtonElement
  declare readonly timeTargets: HTMLElement[]
  declare readonly hasAsciiTarget: boolean
  declare readonly asciiTarget: HTMLElement
  declare readonly hasTitleTarget: boolean
  declare readonly titleTarget: HTMLElement
  declare readonly srcValue: string
  declare readonly titleValue: string
  declare readonly sourceValue: string
  declare readonly sourceUrlValue: string

  private resizeObserver?: ResizeObserver
  private titleObserver?: ResizeObserver
  private titleWidth = 0
  private scrolling?: Animation // a title too long for its line, moving across while playing
  private progress = 0
  private hasStarted = false
  private current = false // this track is the transport's
  private playing = false
  private initialTime: string[] = []

  private readonly onState = (event: Event): void => this.show((event as CustomEvent<TransportState>).detail)

  connect(): void {
    this.initialTime = this.timeTargets.map((time) => time.textContent ?? "")
    window.addEventListener("transport:state", this.onState)
    // A new page asks what's playing, so a track already playing shows it
    window.dispatchEvent(new CustomEvent("transport:request"))

    if (this.hasTitleTarget) {
      // Measured again when the title's room changes (screen width, the
      // time growing a digit) and when the web font arrives
      this.titleObserver = new ResizeObserver(() => requestAnimationFrame(() => {
        if (this.titleTarget.clientWidth !== this.titleWidth) this.scrollTitle()
      }))
      this.titleObserver.observe(this.titleTarget)
      void document.fonts.ready.then(() => this.scrollTitle())
    }

    if (!this.hasAsciiTarget) return
    // Redraw on the next frame, so redrawing never feeds back into the observer
    this.resizeObserver = new ResizeObserver(() => requestAnimationFrame(() => this.drawAscii()))
    this.resizeObserver.observe(this.asciiTarget)
    // Character widths change when the web font arrives: redraw then too
    void document.fonts.ready.then(() => this.drawAscii())
  }

  disconnect(): void {
    window.removeEventListener("transport:state", this.onState)
    this.resizeObserver?.disconnect()
    this.titleObserver?.disconnect()
    this.scrolling?.cancel()
  }

  toggle(): void {
    if (!this.srcValue) return
    if (this.current && this.playing) this.send({ action: "stop" })
    else this.play()
  }

  seek(event: MouseEvent): void {
    if (!this.srcValue) return
    const bar = this.barTarget.getBoundingClientRect()
    const ratio = Math.min(1, Math.max(0, (event.clientX - bar.left) / bar.width))
    if (!this.current || !this.playing) this.play()
    this.send({ action: "seek", ratio })
  }

  back(event: KeyboardEvent): void {
    this.skip(event, -10)
  }

  forward(event: KeyboardEvent): void {
    this.skip(event, 10)
  }

  private play(): void {
    this.send({ action: "play", src: this.srcValue, title: this.titleValue, source: this.sourceValue, sourceUrl: this.sourceUrlValue })
  }

  private skip(event: KeyboardEvent, seconds: number): void {
    if (!this.current) return
    event.preventDefault()
    this.send({ action: "skip", seconds })
  }

  private send(command: TransportCommand): void {
    window.dispatchEvent(new CustomEvent<TransportCommand>("transport:command", { detail: command }))
  }

  // Draws the transport's state if it's this track's, otherwise the resting state
  private show(state: TransportState): void {
    this.current = Boolean(this.srcValue) && state.src === this.srcValue
    const starting = !this.playing && this.current && state.playing
    this.playing = this.current && state.playing
    this.barTarget.classList.toggle("is-playing", this.playing)
    // Measured afresh as it starts, then moving while it plays
    if (this.hasTitleTarget && starting) this.scrollTitle()
    else if (this.hasTitleTarget) moveWhilePlaying(this.titleTarget, this.scrolling, this.playing)
    const label = this.buttonTarget.getAttribute("aria-label") ?? ""
    this.buttonTarget.setAttribute("aria-label", label.replace(/^(Play|Pause)/, this.playing ? "Pause" : "Play"))

    if (this.current) {
      this.hasStarted = state.started
      const total = state.duration
      // Listened to the end: the whole rule stays filled
      this.setProgress(state.ended ? 1 : total > 0 ? state.currentTime / total : 0)
      const text = total > 0 ? `${clock(state.currentTime)} / ${clock(total)}` : clock(state.currentTime)
      for (const time of this.timeTargets) time.textContent = text
    } else {
      this.hasStarted = false
      this.setProgress(0)
      this.timeTargets.forEach((time, i) => { time.textContent = this.initialTime[i] ?? "" })
    }
  }

  // One line always: a title too long for it ends in … and moves across
  // while its track plays (scrollAcross)
  private scrollTitle(): void {
    this.scrolling?.cancel()
    this.titleWidth = this.titleTarget.clientWidth
    this.scrolling = scrollAcross(this.titleTarget, "pl-ledger__copy")
    moveWhilePlaying(this.titleTarget, this.scrolling, this.playing)
  }

  private setProgress(progress: number): void {
    this.progress = progress
    this.drawAscii()
  }

  private drawAscii(): void {
    if (this.hasAsciiTarget) drawLedgerRule(this.asciiTarget, this.progress, this.hasStarted)
  }
}
