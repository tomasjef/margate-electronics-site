import { Controller } from "@hotwired/stimulus"

// Keeps the photos, the size and colour chips and the stock notes in step with
// the chosen colour and the stock (mirrors the Inventory class on the server).
export default class extends Controller<HTMLElement> {
  static targets = ["size", "colour", "remaining", "soldOut", "byColour", "buy"]
  static values = { stock: Object, low: Number }

  declare readonly sizeTargets: HTMLInputElement[]
  declare readonly colourTargets: HTMLInputElement[]
  declare readonly remainingTarget: HTMLElement
  declare readonly soldOutTarget: HTMLElement
  declare readonly byColourTargets: HTMLElement[]
  declare readonly hasBuyTarget: boolean
  declare readonly buyTarget: HTMLAnchorElement
  declare readonly stockValue: Record<string, number>
  declare readonly lowValue: number

  update(): void {
    const colour = this.chosen(this.colourTargets)
    if (!colour) return

    // Show this colour's photos and details
    for (const part of this.byColourTargets) part.hidden = part.dataset.colour !== colour

    // Buy goes to this colour's Bandcamp listing
    if (this.hasBuyTarget) {
      const urls = JSON.parse(this.buyTarget.dataset.buyUrls ?? "{}") as Record<string, string>
      const url = urls[colour]
      if (url) this.buyTarget.href = url
    }

    // Sizes: disable the ones with none left in this colour
    for (const input of this.sizeTargets) this.setAvailable(input, this.count(input.value, colour) > 0)

    // If the chosen size just sold out, move to the first size in stock
    let size = this.chosen(this.sizeTargets)
    if (!size || this.count(size, colour) === 0) {
      const next = this.sizeTargets.find((input) => !input.disabled)
      if (next) next.checked = true
      size = next?.value
    }

    const left = size ? this.count(size, colour) : 0
    this.note(this.remainingTarget, left > 0 && left <= this.lowValue ? `${left} remaining in ${size} ${colour}` : null)

    const soldOut = this.sizeTargets.filter((input) => input.disabled).map((input) => input.value)
    const allGone = soldOut.length === this.sizeTargets.length
    this.note(this.soldOutTarget, allGone ? `${colour}: sold out` : soldOut.length ? `Sold out: ${soldOut.join(", ")}` : null)
  }

  private count(size: string, colour: string): number {
    return this.stockValue[`${size}|${colour}`] ?? 0
  }

  private chosen(inputs: HTMLInputElement[]): string | undefined {
    return inputs.find((input) => input.checked)?.value
  }

  private setAvailable(input: HTMLInputElement, available: boolean): void {
    input.disabled = !available
    const chip = input.closest(".chip")
    chip?.classList.toggle("chip--sold-out", !available)
    const status = chip?.querySelector(".chip__status")
    if (status) status.textContent = available ? "" : ", sold out"
  }

  private note(element: HTMLElement, text: string | null): void {
    element.textContent = text ?? ""
    element.hidden = text === null
  }
}
