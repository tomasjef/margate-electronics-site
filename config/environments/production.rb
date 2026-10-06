require "active_support/core_ext/integer/time"

# Production mode is only ever used by the static build (bin/static-build):
# Parklife requests every page in-process and writes the HTML to build/. There
# is no production server, so nothing here is about serving traffic.
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot, so a missing constant fails the build.
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # The build only needs each file's key to link to it on R2 (MediaUrls), so it
  # runs without R2 keys. With keys (a build on the Mac) it uses R2 itself.
  config.active_storage.service = ENV["R2_ACCESS_KEY_ID"].present? ? :cloudflare_r2 : :without_keys

  # Log to STDOUT; bin/static-build sets RAILS_LOG_LEVEL=warn.
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # One build, one process: an in-memory cache is all it needs.
  config.cache_store = :memory_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # The build only reads the content database; never dump the schema.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]
end
