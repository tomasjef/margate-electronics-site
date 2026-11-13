// The admin (Avo), local only. Loaded after Avo's own script; the file of
// the same name in the Avo gem is empty.

// Upload boxes (audio, photos) say nothing once a file is chosen, and the
// file only uploads on Save: show its name and say so. "Clear value" puts
// the box back.
if (!window.meUploadAcknowledged) {
  window.meUploadAcknowledged = true

  const show = (input) => {
    const box = input.closest(".file-upload-input")
    if (!box) return
    const title = box.querySelector(".file-upload-input__title")
    const description = box.querySelector(".file-upload-input__description")
    if (title && !("original" in box.dataset)) box.dataset.original = title.innerHTML
    if (description && !("originalDescription" in box.dataset)) box.dataset.originalDescription = description.textContent

    const names = [...input.files].map((file) => file.name)
    box.classList.toggle("file-upload-input--chosen", names.length > 0)
    if (names.length > 0) {
      if (title) title.textContent = `✓ ${names.join(", ")}`
      if (description) description.textContent = "Ready: press Save to upload"
    } else {
      if (title) title.innerHTML = box.dataset.original ?? title.innerHTML
      if (description) description.textContent = box.dataset.originalDescription ?? ""
    }
  }

  document.addEventListener("change", (event) => {
    if (event.target instanceof HTMLInputElement && event.target.type === "file") show(event.target)
  })

  // Avo's "Clear value" empties the input without a change event
  document.addEventListener("click", (event) => {
    const clear = event.target instanceof Element && event.target.closest("[data-clear-input-target=clearButton]")
    if (!clear) return
    const input = clear.closest("[data-controller~=clear-input]")?.querySelector("input[type=file]")
    if (input) setTimeout(() => show(input))
  })
}

// An event's lineup lines (Live, DJ, Screening, Workshop) are added as
// needed: on the form only the ones in use show, each with a × beside its
// name to remove it (it's emptied, so it's left out on the site), and a
// "+ DJ"-style button brings back any line not in use.
const LINEUP = [ [ "live", "Live" ], [ "dj", "DJ" ], [ "screening", "Screening" ], [ "workshop", "Workshop" ] ]

// The Avo text editor inside a field, to empty it
const editorIn = (wrapper) => {
  const element = wrapper.querySelector("[data-controller~='tiptap-field']")
  return element && window.Stimulus?.getControllerForElementAndIdentifier(element, "tiptap-field")?.editor
}

const setUpLineup = () => {
  const fields = LINEUP.map(([ id, label ]) => ({ id, label, wrapper: document.querySelector(`form .field-wrapper[data-field-id="${id}"][data-field-type="tiptap"]`) }))
  if (fields.some((field) => !field.wrapper)) return
  // Set up once per page. A page Turbo shows from its cache has copies of
  // the buttons without what they do (and without this mark): rebuild those.
  if (document.querySelector(".lineup-add")?.lineupReady) return
  document.querySelectorAll(".lineup-add, .lineup-remove").forEach((element) => element.remove())

  const bar = document.createElement("div")
  bar.className = "lineup-add"
  bar.lineupReady = true
  bar.append("Add to the lineup:")
  const addButtons = new Map()
  const refresh = () => { bar.hidden = [ ...addButtons.values() ].every((button) => button.hidden) }

  const show = (field) => {
    field.wrapper.style.display = ""
    addButtons.get(field.id).hidden = true
    refresh()
    field.wrapper.querySelector(".ProseMirror")?.focus()
  }

  const remove = (field) => {
    editorIn(field.wrapper)?.commands.clearContent(true)
    const input = field.wrapper.querySelector("textarea")
    if (input) input.value = ""
    field.wrapper.style.display = "none"
    addButtons.get(field.id).hidden = false
    refresh()
  }

  for (const field of fields) {
    const add = document.createElement("button")
    add.type = "button"
    add.className = "lineup-add__button"
    add.textContent = `+ ${field.label}`
    add.addEventListener("click", () => show(field))
    addButtons.set(field.id, add)
    bar.append(add)

    const removeButton = document.createElement("button")
    removeButton.type = "button"
    removeButton.className = "lineup-remove"
    removeButton.textContent = "×"
    removeButton.setAttribute("aria-label", `Remove the ${field.label} line`)
    removeButton.title = `Remove the ${field.label} line`
    removeButton.addEventListener("click", () => remove(field))
    field.wrapper.querySelector(".field-wrapper__label")?.append(removeButton)

    const value = field.wrapper.querySelector("textarea")?.value ?? ""
    const empty = value.replace(/<[^>]*>|&nbsp;/g, "").trim() === ""
    field.wrapper.style.display = empty ? "none" : ""
    add.hidden = !empty
  }

  fields.at(-1).wrapper.after(bar)
  refresh()
}

document.addEventListener("turbo:load", setUpLineup)
if (document.readyState !== "loading") setUpLineup()
else document.addEventListener("DOMContentLoaded", setUpLineup)
