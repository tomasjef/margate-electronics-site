Rails.application.routes.draw do
  mount_avo
  resource :session
  root "pages#home"

  get "events/:slug" => "events#show", as: :event
  # "Add to Calendar": a calendar file, built as /events/<slug>/calendar.ics
  get "events/:slug/calendar" => "events#calendar", as: :event_calendar, constraints: { format: :ics }
  get "releases/:slug" => "releases#show", as: :release
  get "apparel/:slug" => "products#show", as: :product
  get "prints/:slug" => "products#show", as: :print
  get "about" => "pages#about", as: :about
  get "stockists" => "pages#stockists", as: :stockists
  get "archive" => "pages#archive", as: :archive

  # Home page filters as real paths, so each one is pre-rendered as its own page
  get ":type" => "pages#home", as: :filter, constraints: { type: /events|releases|apparel|prints/ }

  get "newsletter" => "newsletter_subscriptions#new", as: :newsletter

  # Written into the static build as 404.html, sitemap.xml, robots.txt and feed.xml (Parkfile)
  get "404" => "pages#not_found", as: :not_found
  get "sitemap" => "pages#sitemap", defaults: { format: :xml }
  get "robots" => "pages#robots", defaults: { format: :text }
  # Built as feed.xml: an Atom feed of every entry, for feed readers
  get "feed" => "pages#atom", defaults: { format: :xml }

  # Browser tests only: stands in for R2's public address (see TestMediaController)
  get "test-media/*path" => "test_media#show", format: false if Rails.env.test?
end
