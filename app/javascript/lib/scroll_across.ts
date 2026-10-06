// A title too long for its box moves across it on a loop, like a hi-fi
// display, followed by a copy of itself so it comes round without a jump.
// It rests at its start for a moment each time round. Used by the page
// players and the now-playing strip; both move it only while playing.
//
// The box holds a line, the line holds the title: <box><line><title>. Returns
// the animation, paused at its start, or nothing when the title fits or for
// reduced motion (it then ends in … instead).

const REDUCED_MOTION = window.matchMedia("(prefers-reduced-motion: reduce)")
const SPEED = 40 // px a second, about four characters
const REST = 2000 // ms at the start of each time round

export function scrollAcross(box: HTMLElement, copyClass: string): Animation | undefined {
  const line = box.firstElementChild as HTMLElement | null
  line?.querySelector(`.${copyClass}`)?.remove()
  const title = line?.firstElementChild as HTMLElement | null
  if (!line || !title || REDUCED_MOTION.matches || title.offsetWidth <= box.clientWidth) return

  const copy = title.cloneNode(true) as HTMLElement
  copy.className = copyClass
  copy.setAttribute("aria-hidden", "true")
  line.append(copy)
  // From the title's start to the copy's: the title and the gap after it
  const distance = copy.offsetLeft - title.offsetLeft
  const moving = (distance / SPEED) * 1000
  const animation = line.animate([
    { transform: "translateX(0)" },
    { transform: "translateX(0)", offset: REST / (REST + moving) },
    { transform: `translateX(${-distance}px)` }
  ], { duration: REST + moving, iterations: Infinity })
  animation.pause()
  return animation
}

// Moving while playing; stopped, back to its start (and ending in … again,
// through the box's is-scrolling class)
export function moveWhilePlaying(box: HTMLElement, animation: Animation | undefined, playing: boolean): void {
  const moving = Boolean(animation) && playing
  box.classList.toggle("is-scrolling", moving)
  if (!animation) return
  if (moving && animation.playState !== "running") animation.play()
  if (!moving && animation.playState === "running") {
    animation.pause()
    animation.currentTime = 0
  }
}
