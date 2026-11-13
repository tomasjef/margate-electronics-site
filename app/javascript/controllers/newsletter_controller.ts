import { Controller } from "@hotwired/stimulus"

// Newsletter sign-up, posted straight to MailerLite's embedded form (the site
// is static, nothing posts to Rails). Sends in the background and shows the
// result in place: "Thanks, you're on the list." or what went wrong. Without
// JavaScript the form still posts to MailerLite directly.
type MailerLiteReply = {
  success?: boolean
  errors?: { fields?: Record<string, string[]> }
}

export default class extends Controller<HTMLElement> {
  static targets = ["form", "email", "submit", "message"]
  declare readonly formTarget: HTMLFormElement
  declare readonly emailTarget: HTMLInputElement
  declare readonly submitTarget: HTMLInputElement
  declare readonly messageTarget: HTMLElement

  async submit(event: SubmitEvent): Promise<void> {
    event.preventDefault()
    this.submitTarget.disabled = true
    try {
      const response = await fetch(this.formTarget.action, {
        method: "POST",
        body: new FormData(this.formTarget),
        headers: { Accept: "application/json" },
      })
      const reply = (await response.json()) as MailerLiteReply
      if (reply.success) {
        this.formTarget.hidden = true
        this.show("Thanks, you're on the list.", "status")
      } else {
        this.showError(reply.errors?.fields?.email?.[0] ?? "Please enter a valid email address.")
      }
    } catch {
      this.showError("Something went wrong. Please try again.")
    } finally {
      this.submitTarget.disabled = false
    }
  }

  private showError(text: string): void {
    this.emailTarget.setAttribute("aria-invalid", "true")
    this.show(text, "alert")
    this.emailTarget.focus()
  }

  private show(text: string, role: "status" | "alert"): void {
    this.messageTarget.setAttribute("role", role)
    this.messageTarget.textContent = text
    this.messageTarget.hidden = false
  }
}
