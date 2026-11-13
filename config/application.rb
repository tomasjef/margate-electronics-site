require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MargateElectronicsApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "London"

    # Where the public R2 bucket is served: every image and audio link on the
    # site starts here (MediaUrls). Not secret.
    config.x.media_host = ENV.fetch("R2_PUBLIC_DOMAIN", "https://media.margate-electronics.org").chomp("/")

    # Newsletter: our form posts straight to MailerLite's embedded form
    # ("Sign up", account 1452160), which adds the address to its groups. Not
    # secret: it's the same address MailerLite's own embed code uses.
    config.x.newsletter_form_action = "https://assets.mailerlite.com/jsonp/1452160/forms/151678393090311535/subscribe"

    # config.eager_load_paths << Rails.root.join("extras")
  end
end
