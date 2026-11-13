import { defineConfig } from "vite"
import RubyPlugin from "vite-plugin-ruby"

export default defineConfig({
  plugins: [RubyPlugin()],
  // Bundle the site's dependencies once, when the dev server starts. Found
  // on the fly instead, they were re-bundled mid-session and pages got
  // "504 Outdated Optimize Dep" for Turbo and Stimulus, so nothing worked
  // until the Vite cache was cleared.
  optimizeDeps: {
    include: ["@hotwired/turbo-rails", "@hotwired/stimulus"],
  },
})
