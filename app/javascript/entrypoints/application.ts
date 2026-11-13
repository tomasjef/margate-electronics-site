import "@hotwired/turbo-rails"
import "../lib/dither"
import { Application, type ControllerConstructor } from "@hotwired/stimulus"

const application = Application.start()

const controllers = import.meta.glob<{ default: ControllerConstructor }>(
  "../controllers/*_controller.ts",
  { eager: true },
)

for (const [path, module] of Object.entries(controllers)) {
  const name = path.match(/([\w-]+)_controller\.ts$/)?.[1]?.replace(/_/g, "-")
  if (name) application.register(name, module.default)
}

