import { Controller } from "@hotwired/stimulus"

// srcset: the sharper version for sharp screens; width and height: the
// original's, in pixels, 0 when unknown; dither: its stand-in while loading
// (a data URI, or "" without one)
type Slide = { src: string; srcset: string; width: number; height: number; dither: string; alt: string; caption: string }

// Opens the image lightbox (the site's one <dialog>).
// Lives on <body> so any element on the page can trigger it.
export default class extends Controller<HTMLElement> {
  static targets = ["figure", "image", "caption", "prev", "next"]
  declare readonly figureTarget: HTMLElement
  declare readonly imageTarget: HTMLImageElement
  declare readonly captionTarget: HTMLElement
  declare readonly prevTarget: HTMLButtonElement
  declare readonly nextTarget: HTMLButtonElement

  private slides: Slide[] = []
  private index = 0
  private shown = 0 // counts shows, so only the latest one's loading finishes it

  // Opens the lightbox on the clicked image. Prev and Next then step through
  // every image on the page in page order, wrapping round at either end.
  openImage({ params }: { params: Slide }): void {
    this.slides = this.pageSlides()
    this.index = Math.max(0, this.slides.findIndex((slide) => slide.src === params.src))
    if (this.slides.length === 0) this.slides = [ { ...params, srcset: params.srcset ?? "", width: Number(params.width) || 0, height: Number(params.height) || 0, dither: params.dither ?? "", caption: params.caption ?? "" } ]

    const several = this.slides.length > 1
    this.prevTarget.hidden = !several
    this.nextTarget.hidden = !several

    // Open first, so the photo's room can be measured (sizeForDither)
    this.imageTarget.closest("dialog")?.showModal()
    this.show()
  }

  prev(): void {
    this.step(-1)
  }

  next(): void {
    this.step(1)
  }

  close(event: Event): void {
    const dialog = (event.currentTarget as HTMLElement).closest("dialog")
    dialog?.close()
  }

  // A click on the dialog's own padding (not its content) closes it.
  backdrop(event: MouseEvent): void {
    if (event.target === event.currentTarget) (event.currentTarget as HTMLDialogElement).close()
  }

  // The next image loads out of sight and swaps in whole once it's ready, so
  // the lightbox never goes blank or jumps in size while it loads. A newer
  // step (quick clicks) wins over one still loading.
  private async step(by: number): Promise<void> {
    if (this.slides.length < 2) return
    this.index = (this.index + by + this.slides.length) % this.slides.length
    const index = this.index
    await this.load(this.slides[index])
    if (index === this.index) this.show()
  }

  // Loads and decodes a slide's image (the same srcset and sizes as the
  // lightbox's, so the lightbox then picks the copy already loaded)
  private load(slide: Slide | undefined): Promise<void> {
    if (!slide) return Promise.resolve()
    const image = new Image()
    image.sizes = "100vw"
    image.srcset = slide.srcset
    image.src = slide.src
    return image.decode().catch(() => undefined)
  }

  private show(): void {
    const slide = this.slides[this.index]
    if (!slide) return
    // The images either side, ready for the next step
    const count = this.slides.length
    if (count > 1) [ 1, -1 ].forEach((by) => this.load(this.slides[(this.index + by + count) % count]))
    const image = this.imageTarget
    image.srcset = slide.srcset
    image.sizes = "100vw"
    image.src = slide.src
    image.alt = slide.alt
    // Never larger than the original: its pixels, in the screen's own pixels
    // (half as many CSS pixels on a sharp screen), so it's never blown up.
    // Set on the figure, so the figure is exactly as wide as the image and
    // the caption starts at the image's left edge.
    const figure = this.figureTarget
    figure.style.maxWidth = slide.width > 0 ? `min(100%, ${slide.width / window.devicePixelRatio}px)` : ""
    // Show the image's caption under it, when it has one
    this.captionTarget.textContent = slide.caption
    this.captionTarget.hidden = slide.caption === ""
    // Opening on a photo not loaded yet: its dithered stand-in shows at the
    // photo's size, caption and all, until it's in. Without one (or without
    // its size), the photo and caption wait together, rather than the
    // caption showing alone and jumping.
    const shown = ++this.shown
    const loading = !image.complete
    // Never a size left from a photo before (stepped on before it loaded:
    // its own clean-up is skipped, as this show is newer)
    this.clearDither()
    const dithering = loading && this.sizeForDither(slide)
    figure.classList.toggle("is-loading", loading && !dithering)
    image.classList.toggle("is-dithering", dithering)
    if (loading) {
      void image.decode().catch(() => undefined).finally(() => {
        if (shown !== this.shown) return
        figure.classList.remove("is-loading")
        this.clearDither()
      })
    }
  }

  // Sizes the empty image as the photo will show (its own pixels at most,
  // inside the lightbox's room) and puts its stand-in in it. False when the
  // slide has no stand-in or no size.
  private sizeForDither(slide: Slide): boolean {
    const image = this.imageTarget
    this.clearDither()
    if (!slide.dither || slide.width <= 0 || slide.height <= 0) return false
    const room = this.figureTarget.parentElement?.clientWidth ?? window.innerWidth
    const maxHeight = parseFloat(getComputedStyle(image).maxHeight) || window.innerHeight
    const natural = { width: slide.width / window.devicePixelRatio, height: slide.height / window.devicePixelRatio }
    const scale = Math.min(1, room / natural.width, maxHeight / natural.height)
    image.style.width = `${Math.round(natural.width * scale)}px`
    image.style.height = `${Math.round(natural.height * scale)}px`
    image.style.setProperty("--dither", `url(${slide.dither})`)
    return true
  }

  private clearDither(): void {
    const image = this.imageTarget
    image.classList.remove("is-dithering")
    image.style.removeProperty("width")
    image.style.removeProperty("height")
    image.style.removeProperty("--dither")
  }

  // Every visible real image on the page that can be enlarged: lightbox images
  // and gallery thumbnails, in page order, each image once.
  private pageSlides(): Slide[] {
    const seen = new Set<string>()
    const slides: Slide[] = []
    const sources = document.querySelectorAll<HTMLElement>("main [data-dialog-src-param], main [data-gallery-src-param]")
    for (const el of sources) {
      if (el.closest("[hidden]")) continue // another colour's photos
      // Thumbnails carry their full-size address separately from the size they swap in at
      const src = el.dataset.dialogSrcParam ?? el.dataset.galleryFullParam ?? el.dataset.gallerySrcParam
      if (!src || seen.has(src)) continue
      seen.add(src)
      slides.push({
        src,
        srcset: el.dataset.dialogSrcsetParam ?? el.dataset.galleryFullSrcsetParam ?? "",
        width: Number(el.dataset.dialogWidthParam ?? el.dataset.galleryFullWidthParam) || 0,
        height: Number(el.dataset.dialogHeightParam ?? el.dataset.galleryFullHeightParam) || 0,
        dither: el.dataset.dialogDitherParam ?? el.dataset.galleryDitherParam ?? "",
        alt: el.dataset.dialogAltParam ?? el.dataset.galleryAltParam ?? "",
        caption: el.dataset.dialogCaptionParam ?? ""
      })
    }
    return slides
  }
}
