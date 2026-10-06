// The Ledger player's progress rule, drawn in characters and sized to its box:
// [||||||......]: bars where played, dots after. Used by the page players and
// the now-playing strip.
//
// progress: 0 to 1. started: sound has come through, so at least one bar
// shows even at 0:00 (it's clear the stream works).
export function drawLedgerRule(el: HTMLElement, progress: number, started: boolean): void {
  const width = el.clientWidth
  if (width === 0) return
  const charWidth = measureCharWidth(el)
  let cells = Math.max(4, Math.floor(width / charWidth) - 2)

  // Draw, then check the rule really fits its box (a device's font can differ
  // from the measurement); if it overflows, drop a character and redraw
  for (let attempt = 0; attempt < 4; attempt++) {
    // Spread the leftover fraction of a character across the rule, so the
    // closing ] lands on the right edge
    const spacing = Math.max(0, (width - (cells + 2) * charWidth) / (cells + 2))
    el.style.letterSpacing = `${spacing}px`
    // At least one bar once the track has started, then a bar for each
    // cell reached
    const filled = started || progress > 0
      ? Math.min(cells, Math.max(1, Math.ceil(progress * cells)))
      : 0

    const rest = document.createElement("span")
    rest.className = "pl-ledger__rest"
    rest.textContent = ".".repeat(cells - filled)
    el.replaceChildren("[", "|".repeat(filled), rest, "]")

    if (el.scrollWidth <= width + 0.5) return
    cells -= 1
  }
}

// The real width of one character in the element's font, measured rather than
// assumed (Plex Mono is 0.6em, but a fallback font may differ)
function measureCharWidth(el: HTMLElement): number {
  const style = getComputedStyle(el)
  const context = document.createElement("canvas").getContext("2d")
  if (!context) return parseFloat(style.fontSize) * 0.6
  context.font = `${style.fontStyle} ${style.fontWeight} ${style.fontSize} ${style.fontFamily}`
  return context.measureText(".".repeat(10)).width / 10
}
