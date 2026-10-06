import { Controller } from "@hotwired/stimulus"

// src and srcset: the main photo at the column width (1x and 2x);
// full, fullSrcset, fullWidth, fullHeight: what the lightbox opens (see
// lightbox_image); height: the photo's height at the column width, in its
// own shape; dither: its stand-in while loading ("" without one)
type ShowParams = { src: string; srcset: string; height: number; full: string; fullSrcset: string; fullWidth: string; fullHeight: string; dither: string; alt: string }

// Thumbnails swap into the main image, in their own shape; the main image
// opens the lightbox.
export default class extends Controller<HTMLElement> {
  static targets = ["main", "thumb"]
  declare readonly hasMainTarget: boolean
  declare readonly mainTarget: HTMLImageElement
  declare readonly thumbTargets: HTMLButtonElement[]

  show(event: Event & { params: ShowParams }): void {
    if (!this.hasMainTarget) return
    const { src, srcset, height, full, fullSrcset, fullWidth, fullHeight, dither, alt } = event.params
    const main = this.mainTarget
    main.srcset = srcset
    main.src = src
    main.alt = alt
    // Its own stand-in while it loads (lib/dither unmarks it once it's in)
    if (dither) main.style.setProperty("--dither", `url(${dither})`)
    else main.style.removeProperty("--dither")
    main.classList.toggle("media--dithered", Boolean(dither))
    main.classList.toggle("is-loading", Boolean(dither) && !main.complete)
    // The main photo takes this photo's shape (the page below moves with it)
    if (height > 0) {
      main.setAttribute("height", String(height))
      main.style.aspectRatio = `${main.getAttribute("width")} / ${height}`
    }

    const opener = this.mainTarget.closest<HTMLButtonElement>(".media-button")
    if (opener) {
      opener.dataset.dialogSrcParam = full
      opener.dataset.dialogSrcsetParam = fullSrcset
      opener.dataset.dialogWidthParam = fullWidth
      opener.dataset.dialogHeightParam = fullHeight
      opener.dataset.dialogDitherParam = dither
      opener.dataset.dialogAltParam = alt
      opener.setAttribute("aria-label", `Enlarge: ${alt}`)
    }

    for (const thumb of this.thumbTargets) {
      thumb.setAttribute("aria-pressed", String(thumb === event.currentTarget))
    }
  }
}
