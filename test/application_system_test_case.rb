require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1440, 900 ]

  # Photos and audio come from the test app itself instead of R2, so the
  # browser tests see real images and play audio without the network.
  setup do
    @media_host = Rails.configuration.x.media_host
    Rails.configuration.x.media_host = "/test-media"
  end

  teardown { Rails.configuration.x.media_host = @media_host }
end
