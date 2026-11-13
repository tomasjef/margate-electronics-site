// Photos with a dithered stand-in (media--dithered) show it while they
// load: marked is-loading when a page arrives, unmarked once the photo is
// in (or fails). Without this script, photos simply load as before.

const SELECTOR = "img.media--dithered"

function markLoading(): void {
  document.querySelectorAll<HTMLImageElement>(SELECTOR).forEach((img) => {
    img.classList.toggle("is-loading", !img.complete)
  })
}

function loaded(event: Event): void {
  if (event.target instanceof HTMLImageElement) event.target.classList.remove("is-loading")
}

document.addEventListener("turbo:load", markLoading)
// load and error don't bubble: listen as they pass down instead
document.addEventListener("load", loaded, true)
document.addEventListener("error", loaded, true)
