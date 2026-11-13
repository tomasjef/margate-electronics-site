require "test_helper"

# Statuses worked out from dates when the site is built, and the home feed,
# on the launch content (db/seeds/content.rb)
class ContentTest < ActiveSupport::TestCase
  test "an event is upcoming until its day, then archived" do
    event = Event.find_by!(slug: "me-13")
    assert event.upcoming?(Date.new(2026, 10, 9))
    refute event.upcoming?(Date.new(2026, 10, 10))
    travel_to Date.new(2026, 9, 28) do
      assert_equal "Upcoming – 9 Oct 2026", event.status_text
      assert event.book_tickets?
    end
    travel_to Date.new(2026, 10, 10) do
      assert_equal "Archived – 9 Oct 2026", event.status_text
      refute event.book_tickets?
    end
  end

  test "status lines are always automatic, for events and releases" do
    assert_not Event.column_names.include?("status_line")
    assert_not Release.column_names.include?("status_line")
  end

  test "a release is a pre-order before its date, then available; sold out when marked" do
    release = Release.find_by!(slug: "me004")
    assert_equal "pre_order", release.status(Date.new(2026, 10, 8))
    assert_equal "available", release.status(Date.new(2026, 10, 9))
    release.sold_out = true
    assert_equal "sold_out", release.status(Date.new(2026, 10, 8))
    assert_equal "available", Release.new(slug: "x").status, "no date: out already"
  end

  test "the Buy button says pre-order until the release date, then buy" do
    me004 = Release.find_by!(slug: "me004") # out on 9 Oct 2026
    assert_equal "Pre-order on Bandcamp", me004.button_label(Date.new(2026, 10, 8))
    assert_equal "Buy on Bandcamp", me004.button_label(Date.new(2026, 10, 9))
    assert_equal "Buy on Bandcamp", me004.button_label(Date.new(2026, 10, 10))
    me004.sold_out = true
    assert_equal "sold_out", me004.status(Date.new(2026, 10, 8))
  end

  test "a release track shows its preview's length; a recording its own" do
    track = Release.find_by!(slug: "me004").tracks.build(title: "Track one", duration: "7:41")
    assert_equal "0:45", track.shown_duration
    recording = Event.find_by!(slug: "me-12").tracks.build(title: "Set", duration: "33:28")
    assert_equal "33:28", recording.shown_duration
  end

  test "a release's status line: its catalogue number, with the pre-order date until it's out" do
    me004 = Release.find_by!(slug: "me004") # out on 9 Oct 2026
    assert_equal "ME004 – Pre-order, out on 9 Oct 2026", me004.status_text(Date.new(2026, 10, 8))
    assert_equal "ME004", me004.status_text(Date.new(2026, 10, 9))
    assert_equal "ME003", Release.find_by!(slug: "me003").status_text(Date.new(2026, 9, 28))
    assert_nil Release.new(title: "No number yet").status_text
    assert_equal "Pre-order, out on 9 Oct 2026", Release.new(release_date: Date.new(2026, 10, 9)).status_text(Date.new(2026, 10, 1))
  end

  test "previews are filed under the catalogue number, or the slug without one" do
    assert_equal "ME004", Release.find_by!(slug: "me004").folder
    assert_equal "systems-ep", Release.new(slug: "systems-ep").folder
  end

  test "prices in pence show as pounds" do
    assert_equal "£12", Release.new(price_pence: 1200).price
    assert_equal "£12.50", Release.new(price_pence: 1250).price
  end

  test "an emptied editor field is stored as nothing" do
    release = Release.find_by!(slug: "me003")
    release.update!(info: "<p></p>", heading: "<p> </p>", credits: "<p><br></p>")
    assert_nil release.info
    assert_nil release.heading
    assert_nil release.credits
    colour = ProductColour.first
    colour.update!(info: "<p></p>")
    assert_nil colour.info
  end

  test "the admin enters prices in pounds" do
    release = Release.find_by!(slug: "me003")
    { "12" => 1200, "12.5" => 1250, "12.50" => 1250, "£30" => 3000, " 8.99 " => 899, "" => nil }.each do |typed, pence|
      release.price_pounds = typed
      assert_nil release.price_pence if pence.nil?
      assert_equal pence, release.price_pence, typed.inspect unless pence.nil?
      assert release.valid?, typed.inspect
    end
    assert_equal "12.50", Release.new(price_pence: 1250).price_pounds
    release.price_pounds = "twelve"
    assert_not release.valid?
    assert_includes release.errors[:price_pounds].first, "in pounds"
    release.price_pounds = "-1"
    assert_not release.valid?
    assert_nil Product.new.price
  end

  test "the T-shirt's stock comes from its variants" do
    inventory = Product.find_by!(slug: "t-shirt").inventory
    assert_equal %w[XL L M S], inventory.sizes
    assert_equal %w[Natural Black], inventory.colours
    assert_equal 1, inventory.count("XL", "Black")
    assert_equal %w[L M S], inventory.sold_out_sizes("Natural")
    assert_nil Product.find_by!(slug: "waffle").inventory
  end

  test "each colour has its own Bandcamp listing and text" do
    tshirt = Product.find_by!(slug: "t-shirt")
    assert_equal "https://margate-electronics.bandcamp.com/merch/m-e-t-shirt-2", tshirt.buy_url_for("Black")
    assert_includes tshirt.info_for("Black"), "Print: white"
  end

  test "the feed: upcoming events first, then newest first, undated last" do
    travel_to Date.new(2026, 9, 28) do
      items = Feed.new.items
      assert_equal %w[/events/me-13/ /releases/me004/ /releases/me003/ /events/me-12/ /apparel/t-shirt/ /prints/waffle/],
                   items.map(&:path)
      assert_equal [ "Next Event", "New Release", "Release", "Event", "Apparel", "Print" ], items.map(&:tag)
      assert_equal [ "On Sale", "Pre-order", "On Sale", "Archived 2026", "On Sale", "On Sale" ], items.map(&:label)
    end
  end

  test "an event's details: date and time before the night, the venue always" do
    me13 = Event.find_by!(slug: "me-13")
    assert_equal "Fri 9 Oct 2026", me13.date_line
    assert_equal "Doors 7PM / Music 8PM", me13.time_line
    assert_equal [ [ "Venue", "Margate Arts Club, Margate, UK" ], [ "Date", "Fri 9 Oct 2026" ], [ "Time", "Doors 7PM / Music 8PM" ],
                   [ "Tickets", "£8, £10 adv / £13 otd / £20 ticket+tape" ] ], me13.details(Date.new(2026, 10, 1))
    assert_equal [ [ "Venue", "Margate Arts Club, Margate, UK" ] ], me13.details(Date.new(2026, 10, 10))
    assert_equal "Music 8PM", Event.new(music_at: "8PM").time_line
    assert_nil Event.new.time_line
    assert_equal [ "Live", "Screening" ], Event.find_by!(slug: "me-12").lineup.map(&:first)
  end

  test "home tile text is written from each item's fields, and can be switched off" do
    today = Date.new(2026, 9, 28)
    me13 = TileText.for(Event.find_by!(slug: "me-13"), today)
    assert_match(/\AMargate Electronics #13: Ambient Garden<br> ?Kodama こだま \(ME004\) Tape Launch Party<br>Live: Kodama こだま/, me13)
    assert_not_includes me13, "<a ", "the tile is a link: no links inside it"
    %w[Date: Venue: Time: <em>].each { |gone| assert_not_includes me13, gone, "event tiles: heading and lineup only" }
    assert_equal me13, TileText.for(Event.find_by!(slug: "me-13"), Date.new(2026, 10, 10)), "the same before and after the night"

    me004 = TileText.for(Release.find_by!(slug: "me004"), today)
    assert me004.end_with?("Out on 9 Oct 2026")
    assert_not_includes TileText.for(Release.find_by!(slug: "me004"), Date.new(2026, 10, 9)), "Out on"

    waffle = TileText.for(Product.find_by!(slug: "waffle"), today)
    assert waffle.start_with?("<em>Waffle</em> by Tomas Jefanovas")

    Release.find_by!(slug: "me003").update!(show_tile_text: false)
    assert_nil TileText.for(Release.find_by!(slug: "me003"), today)
    item = Feed.new(today: today).items.find { |i| i.path == "/releases/me003/" }
    assert_nil item.caption
  end

  test "photos and tracks are numbered from 1, in each set" do
    assert_equal 1, Image.new.position
    assert_equal 1, Track.new.position
    %w[me-13 me-12].each do |slug|
      event = Event.find_by!(slug: slug)
      assert_equal (1..event.images.size).to_a, event.images.map(&:position), slug
    end
  end

  test "pinned items come first in number order; the rest keep the date order" do
    Product.find_by!(slug: "waffle").update!(home_position: 1)
    Release.find_by!(slug: "me003").update!(home_position: 2)
    travel_to Date.new(2026, 9, 28) do
      items = Feed.new.items
      assert_equal %w[/prints/waffle/ /releases/me003/ /events/me-13/ /releases/me004/ /events/me-12/ /apparel/t-shirt/],
                   items.map(&:path)
      assert_equal "Next Event", items[2].tag, "ME#13 is still the next event, just below the pins"
    end
  end

  test "after the night, ME#13 is archived and nothing is Next Event" do
    items = Feed.new(today: Date.new(2026, 10, 10)).items
    event = items.find { |item| item.path == "/events/me-13/" }
    assert_equal [ "Event", "Archived 2026" ], [ event.tag, event.label ]
    assert_equal "On Sale", items.find { |item| item.path == "/releases/me004/" }.label
  end

  test "sold out things say Sold Out; a sold-out event is Archived after its date" do
    Event.find_by!(slug: "me-13").update!(sold_out: true)
    Release.find_by!(slug: "me004").update!(sold_out: true)
    Product.find_by!(slug: "waffle").update!(sold_out: true)
    ProductVariant.update_all(stock: 0)
    label = ->(items, path) { items.find { |item| item.path == path }.label }

    items = Feed.new(today: Date.new(2026, 9, 28)).items
    %w[/events/me-13/ /releases/me004/ /prints/waffle/ /apparel/t-shirt/].each do |path|
      assert_equal "Sold Out", label.(items, path), path
    end
    assert_equal "Archived 2026", label.(Feed.new(today: Date.new(2026, 10, 10)).items, "/events/me-13/")
  end

  test "apparel is sold out when every size and colour is at 0" do
    tshirt = Product.find_by!(slug: "t-shirt")
    assert_not tshirt.sold_out?
    tshirt.variants.update_all(stock: 0)
    assert tshirt.reload.sold_out?
  end

  test "Next: the entry after this one in the home page's order, the first after the last" do
    feed = Feed.new
    paths = feed.items.map(&:path)
    paths.each_cons(2) { |here, after| assert_equal after, feed.next_path(here) }
    assert_equal paths.first, feed.next_path(paths.last)
    assert_equal paths.second, feed.next_path(paths.first.chomp("/")), "with or without the closing /"
    assert_nil feed.next_path("/about/")
  end

  test "a release's heading, first info lines, © line and button words come from its fields" do
    release = Release.new(artist: "Kodama こだま", title: "koke no ne こけのね", catalogue_number: "ME004",
                          format: "Cassette + digital", edition_size: 25, release_date: Date.new(2026, 10, 9),
                          external_buy_url: "https://margate-electronics.bandcamp.com/album/koke-no-ne")
    assert_equal "Kodama こだま – koke no ne こけのね", release.headline
    assert_equal "<p>Kodama こだま – koke no ne こけのね (ME004)<br>Cassette + digital, edition of 25</p>", release.info_html
    release.info = "<p>Recorded at M.E.#11</p><p>Second line</p>"
    assert_equal "<p>Kodama こだま – koke no ne こけのね (ME004)<br>Cassette + digital, edition of 25<br>Recorded at M.E.#11<br>Second line</p>", release.info_html
    release.heading = "<p>Something else</p>"
    assert_equal "<p>Something else</p>", release.headline, "a typed heading wins"

    assert_equal "<p><em>© 2026 Margate Electronics</em></p>", release.credits_html
    release.credits = "<p><em>Mastering: X</em></p><p><em>Design: Y</em></p>"
    assert_equal "<p><em>Mastering: X</em></p><p><em>Design: Y<br>© 2026 Margate Electronics</em></p>", release.credits_html
    release.credits = "<p>Plain</p>"
    assert_equal "<p>Plain<br>© 2026 Margate Electronics</p>", release.credits_html

    assert_equal "Pre-order on Bandcamp", release.button_label(Date.new(2026, 10, 1))
    assert_equal "Buy on Bandcamp", release.button_label(Date.new(2026, 10, 9))
    release.external_buy_url = "https://shop.example.com/tape"
    assert_equal "Buy", release.button_label(Date.new(2026, 10, 9))
    release.edition_size = nil
    release.format = nil
    assert_equal [ "Kodama こだま – koke no ne こけのね (ME004)" ], release.automatic_info
  end

  test "a caption's credit starts its own line" do
    line = ->(caption) { Image.new(caption: caption).caption_lines }
    assert_equal "Sculpture, Margate Arts Club.\nPhoto © Oliver Goodrich", line.("Sculpture, Margate Arts Club. Photo © Oliver Goodrich")
    assert_equal "Chupacabras.\nPhoto by Jeremy Duffy", line.("Chupacabras. Photo by Jeremy Duffy")
    assert_equal "Ali Renault.\nCourtesy of the Artist", line.("Ali Renault. Courtesy of the Artist")
    assert_equal "Design © Tomas Jefanovas", line.("Design © Tomas Jefanovas"), "only a credit: one line"
    assert_equal "Rhizocorp", line.("Rhizocorp")
    assert_nil line.(nil)
  end

  test "unpublished items stay off the site" do
    Event.find_by!(slug: "me-12").update!(published: false)
    assert_equal 1, Feed.new.counts["events"]
  end

  test "tiles use their own shape when one is set" do
    tile = Release.find_by!(slug: "me004").tile_picture
    assert_equal [ 440, 330 ], [ tile.width, tile.height ]
    cover = Release.find_by!(slug: "me004").main_picture
    assert_equal [ 440, 587 ], [ cover.width, cover.height ], "the photo's own shape"
  end
end
