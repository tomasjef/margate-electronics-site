import { Controller } from "@hotwired/stimulus"
import { drawLedgerRule } from "../lib/ledger_rule"
import { moveWhilePlaying, scrollAcross } from "../lib/scroll_across"

// The site's one audio element, in the layout and kept across page changes by
// Turbo (data-turbo-permanent), so a recording keeps playing while you browse.
// While something plays or is paused, a bar at the bottom shows [ STOP ] /
// [ PLAY ], what it is (a link back to its page), the progress rule, the time
// and [ CLOSE ]. Page players (player controller) are remote controls: they
// send "transport:command" events and draw the state this sends back as
// "transport:state".
//
// [ PLAY ALL ] on the Archive page sends a queue: every recording, shuffled.
// Each plays after the last; [ NEXT ] (wider screens) and the lock screen's
// next button skip on, its previous button goes back to the start of the
// recording, or to the one before it in the first seconds. Playing a single
// track, or [ CLOSE ], ends the queue.

const PHONE = window.matchMedia("(max-width: 767px)")
const SKIP_SECONDS = 10 // the lock screen's skip back and forward, like the arrow keys
const RESTART_SECONDS = 3 // previous, past this: back to the start of the recording

export type TransportTrack = { src: string; title: string; source: string; sourceUrl: string }

// While [ PLAY ALL ] plays: the recording that's on, how many came before it
// and how many are still to come (its time and progress are the state's own)
export type QueueState = { title: string; source: string; before: number; remaining: number }

export type TransportState = {
  src: string | null
  playing: boolean // playing, or about to (requested)
  started: boolean // sound has actually come through
  currentTime: number
  duration: number // 0 while unknown
  ended: boolean
  active: boolean // playing or paused (the bar's [ CLOSE ] not pressed)
  queue: QueueState | null // [ PLAY ALL ] playing or paused
}

export type TransportCommand =
  | ({ action: "play" } & TransportTrack)
  | { action: "queue"; tracks: TransportTrack[] }
  | { action: "toggle" }
  | { action: "next" }
  | { action: "previous" }
  | { action: "stop" }
  | { action: "seek"; ratio: number }
  | { action: "skip"; seconds: number }

export default class extends Controller<HTMLElement> {
  static targets = ["audio", "bar", "button", "link", "time", "rule", "next"]
  declare readonly audioTarget: HTMLAudioElement
  declare readonly barTarget: HTMLElement
  declare readonly buttonTarget: HTMLButtonElement
  declare readonly linkTarget: HTMLAnchorElement
  declare readonly timeTarget: HTMLElement
  declare readonly ruleTarget: HTMLElement
  declare readonly nextTarget: HTMLButtonElement

  private resizeObserver?: ResizeObserver
  private scrolling?: Animation // a long title moving across, on phones

  private track: TransportTrack | null = null
  private started = false
  private ended = false
  private active = false // playing or paused, not stopped: the bar may show
  private queue: TransportTrack[] = [] // [ PLAY ALL ]: the tracks still to come
  private queueActive = false
  private played: TransportTrack[] = [] // [ PLAY ALL ]: the tracks before this one, for previous
  private queueOnLockScreen = false // its next and previous buttons are set

  private readonly onCommand = (event: Event): void => this.command((event as CustomEvent<TransportCommand>).detail)
  private readonly onRequest = (): void => this.broadcast()
  private readonly onPageChange = (): void => this.refreshBar()

  // Turbo moves this element into each new page, which reconnects it: the
  // listeners are added and removed each time, the audio carries on.
  connect(): void {
    window.addEventListener("transport:command", this.onCommand)
    window.addEventListener("transport:request", this.onRequest)
    document.addEventListener("turbo:load", this.onPageChange)
    this.setUpMediaSession()
    // The rule fills the space left: redraw when the bar's size changes
    this.resizeObserver = new ResizeObserver(() => requestAnimationFrame(() => { this.fit(); this.scrollTitle(); this.render() }))
    this.resizeObserver.observe(this.barTarget)
    this.broadcast()
  }

  disconnect(): void {
    window.removeEventListener("transport:command", this.onCommand)
    window.removeEventListener("transport:request", this.onRequest)
    document.removeEventListener("turbo:load", this.onPageChange)
    this.resizeObserver?.disconnect()
    this.scrolling?.cancel()
  }

  command(command: TransportCommand): void {
    switch (command.action) {
      case "play": this.endQueue(); this.play(command); break
      case "queue": this.startQueue(command.tracks); break
      case "toggle": if (this.active) this.toggle(); break
      case "next": this.next(); break
      case "previous": if (this.queueActive) this.previous(); break
      case "stop": this.pause(); break
      case "seek": this.seek(command.ratio); break
      case "skip": this.skip(command.seconds); break
    }
  }

  // The bar's [ STOP ] / [ PLAY ]: pauses and resumes; the bar stays
  toggle(): void {
    if (this.audioTarget.paused) this.resume()
    else this.pause()
  }

  // The bar's [ NEXT ] and the lock screen's next: the queue's next track
  next(): void {
    const track = this.queue.shift()
    if (!track) return
    if (this.track && this.queueActive) this.played.push(this.track)
    this.play(track)
    this.updateQueue()
  }

  // The lock screen's previous, while the queue plays: back to the start of
  // this recording, or in its first seconds to the one before
  previous(): void {
    const before = this.played.at(-1)
    if (this.audioTarget.currentTime > RESTART_SECONDS || !before || !this.track) {
      this.seekTo(0)
      return
    }
    this.played.pop()
    this.queue.unshift(this.track)
    this.play(before)
    this.updateQueue()
  }

  // The bar's [ CLOSE ]: stops and removes the bar
  close(): void {
    this.audioTarget.pause()
    this.endQueue()
    this.active = false
    this.refreshBar()
    this.update()
  }

  // A click on the strip's rule jumps there
  seekAt(event: MouseEvent): void {
    const rule = this.ruleTarget.getBoundingClientRect()
    this.seek(Math.min(1, Math.max(0, (event.clientX - rule.left) / rule.width)))
  }

  // Audio element events
  update(): void {
    this.render()
    this.broadcast()
  }

  // Sound is actually coming through: page players show their first bar
  soundStarted(): void {
    this.started = true
    this.update()
  }

  finished(): void {
    if (this.queue.length > 0) {
      this.next()
      return
    }
    this.endQueue()
    this.ended = true
    this.active = false
    this.refreshBar()
    this.update()
  }

  private play(track: TransportTrack): void {
    if (this.track?.src !== track.src) {
      this.audioTarget.src = track.src
      this.started = false
      // The lock screen's progress starts again with the new file
      // (syncPosition sends it once its length is known)
      try { navigator.mediaSession?.setPositionState?.() } catch { /* not supported here */ }
    }
    this.track = track
    this.ended = false
    // The title, then " · ME#12" in its own span, so phones can leave it out;
    // both in a line that can move across when it doesn't fit (scrollTitle)
    const line = document.createElement("span")
    line.className = "transport__line"
    const title = document.createElement("span")
    title.textContent = track.title
    const source = document.createElement("span")
    source.className = "transport__source"
    source.textContent = track.source ? ` · ${track.source}` : ""
    line.append(title, source)
    this.linkTarget.replaceChildren(line)
    this.linkTarget.href = track.sourceUrl
    this.active = true
    this.refreshBar()
    this.setMediaMetadata(track)
    this.resume()
  }

  private resume(): void {
    // [ STOP ] pressed before the stream starts rejects play() with an
    // AbortError; that is expected, anything else still surfaces
    this.audioTarget.play().catch((error: unknown) => {
      if (!(error instanceof DOMException && error.name === "AbortError")) throw error
    })
    this.update()
  }

  // Stops (pauses: playing it again carries on from here); the bar stays
  private pause(): void {
    this.audioTarget.pause()
    this.update()
  }

  private startQueue(tracks: TransportTrack[]): void {
    this.queue = shuffled(tracks)
    this.queueActive = true
    this.played = []
    this.next()
  }

  private endQueue(): void {
    this.queue = []
    this.played = []
    this.queueActive = false
    this.updateQueue()
  }

  // [ NEXT ] while there's a next track; the lock screen's next and
  // previous buttons while the queue plays (a phone shows them in place of
  // the 10-second skips; set only once and cleared once, so a single
  // track's lock screen is as before)
  private updateQueue(): void {
    this.nextTarget.hidden = this.queue.length === 0
    if (!("mediaSession" in navigator) || this.queueActive === this.queueOnLockScreen) return
    this.queueOnLockScreen = this.queueActive
    const handlers: [MediaSessionAction, MediaSessionActionHandler | null][] = this.queueActive
      ? [ [ "nexttrack", () => this.next() ], [ "previoustrack", () => this.previous() ] ]
      : [ [ "nexttrack", null ], [ "previoustrack", null ] ]
    for (const [action, handler] of handlers) {
      try { navigator.mediaSession.setActionHandler(action, handler) } catch { /* not supported here */ }
    }
  }


  // The bar shows while a track is active, except on a page that has that
  // track's own player (it shows the same thing: no doubling); while
  // [ PLAY ALL ] plays, on the Archive, which has the set's player
  private refreshBar(): void {
    const src = this.track?.src
    const onThisPage = this.queueActive
      ? document.querySelector("main [data-controller~='play-all']")
      : src ? document.querySelector(`main .track[data-player-src-value="${CSS.escape(src)}"]`) : null
    this.barTarget.hidden = !this.active || Boolean(onThisPage)
    this.fit()
    this.scrollTitle()
    this.render()
  }

  // The footer moves up by the bar's height while it shows
  private fit(): void {
    const height = this.barTarget.hidden ? 0 : this.barTarget.offsetHeight
    document.documentElement.style.setProperty("--transport-height", `${height}px`)
  }

  // Phones: a title too long for its line moves across it while playing
  // (scrollAcross). On wider screens the whole title and its source fit.
  private scrollTitle(): void {
    this.scrolling?.cancel()
    this.scrolling = !this.barTarget.hidden && PHONE.matches ? scrollAcross(this.linkTarget, "transport__copy") : undefined
    moveWhilePlaying(this.linkTarget, this.scrolling, !this.audioTarget.paused)
  }

  private seek(ratio: number): void {
    const audio = this.audioTarget
    if (Number.isFinite(audio.duration)) {
      audio.currentTime = ratio * audio.duration
    } else {
      // Duration not known before the first load: jump once it is
      audio.addEventListener("loadedmetadata", () => { audio.currentTime = ratio * audio.duration }, { once: true })
    }
  }

  private seekTo(seconds: number): void {
    const audio = this.audioTarget
    if (!Number.isFinite(audio.duration)) return
    audio.currentTime = Math.min(audio.duration, Math.max(0, seconds))
  }

  private skip(seconds: number): void {
    this.seekTo(this.audioTarget.currentTime + seconds)
  }

  private render(): void {
    const audio = this.audioTarget
    const total = Number.isFinite(audio.duration) ? audio.duration : 0
    // Elapsed and total in their own spans: phones show only the elapsed time
    const elapsed = document.createElement("span")
    elapsed.textContent = clock(audio.currentTime)
    const whole = document.createElement("span")
    whole.className = "transport__total"
    whole.textContent = total > 0 ? ` / ${clock(total)}` : ""
    this.timeTarget.replaceChildren(elapsed, whole)
    const playing = !audio.paused
    this.barTarget.classList.toggle("is-paused", !playing)
    moveWhilePlaying(this.linkTarget, this.scrolling, playing)
    this.buttonTarget.querySelector(".transport__word--stop")!.toggleAttribute("hidden", !playing)
    this.buttonTarget.querySelector(".transport__word--play")!.toggleAttribute("hidden", playing)
    this.buttonTarget.setAttribute("aria-label", `${playing ? "Stop" : "Play"} ${this.track?.title ?? ""}`.trim())
    if (!this.barTarget.hidden && this.ruleTarget.offsetParent) {
      drawLedgerRule(this.ruleTarget, this.ended ? 1 : total > 0 ? audio.currentTime / total : 0, this.started)
    }
  }

  private broadcast(): void {
    const audio = this.audioTarget
    const state: TransportState = {
      src: this.track?.src ?? null,
      playing: !audio.paused,
      started: this.started,
      currentTime: audio.currentTime,
      duration: Number.isFinite(audio.duration) ? audio.duration : 0,
      ended: this.ended,
      active: this.active,
      queue: this.queueActive && this.track
        ? { title: this.track.title, source: this.track.source, before: this.played.length, remaining: this.queue.length }
        : null
    }
    window.dispatchEvent(new CustomEvent<TransportState>("transport:state", { detail: state }))
  }

  // The phone's lock screen and Control Centre show the track and can pause
  // it, move along its progress bar and skip back or forward
  private setUpMediaSession(): void {
    if (!("mediaSession" in navigator)) return
    const handlers: [MediaSessionAction, MediaSessionActionHandler][] = [
      ["play", () => this.resume()],
      ["pause", () => { this.audioTarget.pause() }],
      ["stop", () => this.close()],
      ["seekto", (details) => { if (details.seekTime !== undefined) this.seekTo(details.seekTime) }],
      ["seekbackward", (details) => this.skip(-(details.seekOffset ?? SKIP_SECONDS))],
      ["seekforward", (details) => this.skip(details.seekOffset ?? SKIP_SECONDS)]
    ]
    for (const [action, handler] of handlers) {
      // Browsers that don't know an action throw; the others still work
      try { navigator.mediaSession.setActionHandler(action, handler) } catch { /* not supported here */ }
    }
  }

  // Audio element events that move the lock screen's progress bar: it runs
  // on by itself from the last position given, so only changes are sent
  syncPosition(): void {
    if (!("mediaSession" in navigator) || !navigator.mediaSession.setPositionState) return
    const audio = this.audioTarget
    if (!Number.isFinite(audio.duration) || audio.duration <= 0) return
    navigator.mediaSession.setPositionState({
      duration: audio.duration,
      playbackRate: audio.playbackRate,
      position: Math.min(audio.currentTime, audio.duration)
    })
  }

  private setMediaMetadata(track: TransportTrack): void {
    if (!("mediaSession" in navigator)) return
    navigator.mediaSession.metadata = new MediaMetadata({ title: track.title, artist: track.source, album: "Margate Electronics" })
  }
}

export function clock(seconds: number): string {
  const s = Math.floor(seconds)
  const h = Math.floor(s / 3600)
  const m = Math.floor((s % 3600) / 60)
  const sec = String(s % 60).padStart(2, "0")
  return h > 0 ? `${h}:${String(m).padStart(2, "0")}:${sec}` : `${m}:${sec}`
}

// A new order each time (Fisher–Yates)
function shuffled<T>(items: T[]): T[] {
  const copy = [...items]
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[copy[i], copy[j]] = [copy[j]!, copy[i]!]
  }
  return copy
}
