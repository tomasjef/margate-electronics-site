# The home page: published events, releases and products as one list of tiles.
# Items pinned in the admin (home_position) come first, lowest number first.
# Then upcoming events (soonest first), then everything else, newest first;
# items without a date go last. Worked out when the site is built, so
# the daily rebuild moves an event from Next Event to Archived.
class Feed
  include Rails.application.routes.url_helpers

  Item = Data.define(:kind, :tag, :label, :path, :picture, :caption)

  # Home filter paths and the kind of tile each shows
  FILTERS = { "events" => :event, "releases" => :release, "apparel" => :apparel, "prints" => :print }.freeze
  # The tiles' labels: descriptive, not buttons (the tile opens the page)
  ON_SALE = "On Sale"
  SOLD_OUT = "Sold Out"
  TAPE_SOLD_OUT = "Tape Sold Out"
  RELEASE_LABELS = { "pre_order" => "Pre-order", "available" => ON_SALE, "sold_out" => SOLD_OUT }.freeze
  KIND_ORDER = { Event => 0, Release => 1, Product => 2 }.freeze

  def initialize(today: Date.current)
    @today = today
  end

  def items
    @items ||= begin
      events = Event.published.includes(images: { file_attachment: :blob }).to_a
      releases = Release.published.includes(images: { file_attachment: :blob }).to_a
      products = Product.published.includes(images: { file_attachment: :blob }).to_a

      all = events + releases + products
      pinned = all.select(&:home_position).sort_by { |r| [ r.home_position, -(sort_date(r)&.jd || 0) ] }
      upcoming = (events - pinned).select { |e| e.upcoming?(@today) }.sort_by(&:date)
      rest = all - pinned - upcoming
      dated, undated = rest.partition { |record| sort_date(record) }
      ordered = pinned + upcoming + dated.sort_by { |r| [ -sort_date(r).jd, KIND_ORDER[r.class] ] } + undated

      @next_event = events.select { |e| e.upcoming?(@today) }.min_by(&:date)
      @newest_release = releases.select(&:release_date).max_by(&:release_date)
      @records = ordered
      ordered.map { |record| item_for(record) }
    end
  end

  # For the Atom feed (/feed.xml): each record with its tile, newest first
  # by its date (not the home page's pins), undated last
  def latest
    items.each_index.map { |i| [ @records[i], items[i] ] }
      .sort_by { |record, _| -(sort_date(record)&.jd || 0) }
  end

  # A release's label, on its tile and in the Archive: Pre-order, On Sale,
  # Sold Out, or Tape Sold Out while the digital album is still for sale
  def self.release_label(release, today = Date.current)
    status = release.status(today)
    status != "sold_out" && release.tape_sold_out? ? TAPE_SOLD_OUT : RELEASE_LABELS[status]
  end

  def filtered(filter) = filter ? items.select { |item| item.kind == FILTERS.fetch(filter) } : items

  def counts = FILTERS.transform_values { |kind| items.count { |item| item.kind == kind } }

  # The entry after this page's, in the home page's order; after the last,
  # the first again. Nil for a page that isn't on the home page.
  def next_path(path)
    index = items.index { |item| item.path.chomp("/") == path.chomp("/") }
    items[(index + 1) % items.size].path if index && items.size > 1
  end

  # An event's date, a release's release date, a product's listing date
  def sort_date(record)
    case record
    when Event then record.date
    when Release then record.release_date
    when Product then record.listed_on
    end
  end

  private

  # Past its date: Archived and its year ("Archived 2023"); before it, Sold
  # Out or On Sale (with a ticket link)
  def event_label(event)
    return "Archived #{event.date.year}" unless event.upcoming?(@today)
    return SOLD_OUT if event.sold_out?
    ON_SALE if event.book_tickets?(@today)
  end

  def item_for(record)
    case record
    when Event
      Item.new(kind: :event, tag: record == @next_event ? "Next Event" : "Event",
               label: event_label(record),
               path: event_path(record, trailing_slash: true), picture: record.tile_picture, caption: TileText.for(record, @today))
    when Release
      Item.new(kind: :release, tag: record == @newest_release ? "New Release" : "Release",
               label: Feed.release_label(record, @today),
               path: release_path(record, trailing_slash: true), picture: record.tile_picture, caption: TileText.for(record, @today))
    when Product
      apparel = record.kind == "apparel"
      Item.new(kind: apparel ? :apparel : :print, tag: apparel ? "Apparel" : "Print",
               label: record.sold_out? ? SOLD_OUT : ON_SALE,
               path: apparel ? product_path(record, trailing_slash: true) : print_path(record, trailing_slash: true),
               picture: record.tile_picture, caption: TileText.for(record, @today))
    end
  end
end
