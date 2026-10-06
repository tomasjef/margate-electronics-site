class ApplicationController < ActionController::Base
  include Authentication

  # Every link to a page ends in "/": the static build writes each page as
  # path/index.html, which Cloudflare Pages serves at path/ without a redirect.
  # Set here rather than on the routes, because Parklife replaces the routes'
  # default URL options when it sets the site's address.
  def default_url_options
    super.merge(trailing_slash: true)
  end

  private

  # The home feed, shared by the home page and the filter counts in the header
  def feed = @feed ||= Feed.new
  helper_method :feed
end
