class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @filter = Feed::FILTERS.key?(params[:type]) ? params[:type] : nil
    @tiles = feed.filtered(@filter)
  end

  def about
  end

  def stockists
    @stockists = Stockist.by_city
  end

  # Every event and release as a ledger, newest first, then the artists
  def archive
    events = Event.published.includes(:tracks).order(:date).to_a
    releases = Release.published.order(:release_date).to_a
    @events = events.reverse
    @releases = releases.sort_by { |release| release.release_date || Date.new(0) }.reverse
    @artists = ArtistIndex.new(events: events, releases: releases).entries
    @recordings = events.flat_map { |event| event.tracks.select(&:url) }
  end

  # Built as /404.html, which Cloudflare Pages serves (with status 404) for
  # any address that doesn't exist. Answers 200 here: the static build stops
  # on any page that answers 404.
  def not_found
  end

  # Every public page, for search engines, at the address the site is built
  # for (SITE_URL)
  def sitemap
    counts = feed.counts
    paths = [ root_path ] + Feed::FILTERS.keys.select { |f| counts[f].positive? }.map { |f| filter_path(f) } +
            feed.items.map(&:path) + [ archive_path, about_path, stockists_path, newsletter_path ]
    @urls = paths.uniq.map { |path| "#{request.base_url}#{path}" }
  end

  # The Atom feed (feed.xml), newest first: events, releases and products.
  # Named atom, as the controllers' feed is the home page's (Feed).
  def atom
    @entries = feed.latest
    @updated = @entries.map { |record, _| record.updated_at }.max || Time.current
    render content_type: "application/atom+xml"
  end

  # Search engines may index the real site only; staging and the pages.dev
  # address stay out of search results
  def robots
    @live = request.host == LIVE_HOST
  end

  LIVE_HOST = "margate-electronics.org"
end
