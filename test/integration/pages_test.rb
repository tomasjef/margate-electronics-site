require "test_helper"

# The pages, rendered from the launch content (db/seeds/content.rb)
class PagesTest < ActionDispatch::IntegrationTest
  test "every page renders without signing in" do
    %w[/ /events/me-13 /events/me-12 /releases/me004 /releases/me003 /apparel/t-shirt /prints/waffle /about /archive].each do |path|
      get path
      assert_response :success, path
    end
  end

  test "upcoming events have Add to Calendar, a calendar file of the night" do
    get "/events/me-13"
    assert_select ".price-row a.button[href='/events/me-13/calendar.ics'][data-turbo=false]", text: "Add to Calendar"
    get "/events/me-13/calendar.ics"
    assert_response :success
    assert_equal "text/calendar", response.media_type
    assert_includes response.body, "DTSTART;TZID=Europe/London:20261009T190000"
    get "/events/me-12"
    assert_select "a[href$='calendar.ics']", 0
  end

  test "the Archive lists every event and release, newest first, and the artists" do
    get "/archive/"
    assert_select ".breadcrumb__chip", 0 # the top line names it
    assert_select ".site-header__status", text: "Index"
    assert_select "title", text: "Index · Margate Electronics"
    assert_select ".ledger--events tbody tr", Event.published.count
    assert_select ".ledger--events .ledger__no", 0
    assert_select ".ledger--events thead th", text: "Event"
    assert_select ".ledger--events tbody tr:first-child" do
      assert_select ".ledger__date", text: "9 Oct 2026"
      assert_select ".ledger__title a[href='/events/me-13/']", text: "Margate Electronics #13"
      assert_select ".ledger__lineup", text: /\AKodama こだま \(Akiharu Kitagawa & Clementine Blue\), Pond/
    end
    assert_select ".ledger--events tbody tr:nth-child(2) .ledger__count", text: "1 recording"
    assert_select ".ledger .tag", 0
    assert_equal [ "Cat #", "Artist", "Title", "Format", "Date", "Status" ], css_select(".ledger--releases thead th").map(&:text)
    assert_select ".ledger--releases tbody tr:first-child" do
      assert_select ".ledger__no", text: "ME004"
      assert_select ".ledger__artist", text: "Kodama こだま"
      assert_select ".ledger__title a[href='/releases/me004/']", text: "koke no ne こけのね"
      assert_select ".ledger__format", text: "Cassette + digital"
      assert_select ".ledger__date", text: "9 Oct 2026"
      assert_select ".ledger__status", text: "Pre-order"
    end
    assert_select ".artist-index li", AboutPage.current.artist_names.size
    assert_select ".artist-index li", text: /\AKodama こだま/ do
      assert_select "a[href='/events/me-13/']", text: "M.E.#13"
      assert_select "a[href='/releases/me004/']", text: "ME004"
    end
  end

  test "a photo with a dither carries it, for while it loads; one without doesn't" do
    image = Event.find_by!(slug: "me-12").main_image
    image.update_column(:dither, "data:image/png;base64,AAAA")
    get "/events/me-12"
    assert_select "img.media.media--dithered[style*='--dither: url(data:image/png;base64,AAAA)']"
    # The lightbox gets it too, with the original's size to show it at
    width, height = image.file.blob.metadata.values_at("width", "height")
    assert_select ".media-button[data-dialog-dither-param='data:image/png;base64,AAAA'][data-dialog-width-param='#{width}'][data-dialog-height-param='#{height}']"
    image.update_column(:dither, nil)
    get "/events/me-12"
    assert_select "img.media--dithered", 0
    assert_select ".media-button[data-dialog-dither-param]", 0
  end

  test "filtering the feed by type" do
    get "/releases/"
    assert_select ".tile", 2
    assert_select ".tile .tag--release", 2
    assert_select ".filter-key a[aria-current=page]", text: "Releases(2)"
  end

  test "no filter is selected by default and there is nothing to clear" do
    get "/"
    assert_select ".filter-key a[aria-current=page]", 0
    assert_select ".filter-key__clear", 0
    assert_select ".tile", Feed.new.items.size
  end

  test "an active filter has a clear link back to everything" do
    get "/events/"
    assert_select ".filter-key__clear[href='/'][aria-label]", text: "×"
  end

  test "inner pages have Back to their section instead of the filters" do
    get "/events/me-12"
    assert_select ".filter-key", 0
    assert_select "a.back-link[href='/events/']", text: "← Back"
    assert_select ".entry-nav a.next-link[rel=next][href='#{Feed.new.next_path('/events/me-12/')}']", text: "Next →"
    get "/"
    assert_select ".filter-key", 1
    assert_select "a.back-link", 0
    assert_select "a.next-link", 0
    get "/about"
    assert_select "a.next-link", 0, "not on the home page, so no Next"
  end

  test "an event recording streams from R2" do
    get "/events/me-12"
    assert_select ".track[data-player-src-value='https://media.margate-electronics.org/ME12_Hellocatfood_master_streaming.mp3']" \
                  "[data-player-source-value='M.E.#12'][data-player-source-url-value='/events/me-12/']", 1
    # One shared audio element for the whole site, none per track
    assert_select "#transport[data-turbo-permanent] audio[preload=none]", 1
    assert_select ".track audio", 0
    assert_select ".track .pl-ledger__title", text: "hellocatfood"
    assert_select ".track .pl-ledger__rule", 1
  end

  test "a release lists only its tracks with a preview, as Previews of 0:45" do
    me004 = Release.find_by!(slug: "me004")
    me004.tracks.create!(title: "Track one", position: 1, duration: "7:41", audio_path: "previews/ME004/01-track-one.mp3")
    me004.tracks.create!(title: "Track two", position: 2, audio_path: "previews/ME004/02-track-two.mp3")
    me004.tracks.create!(title: "Track three", position: 3) # its preview isn't made yet
    get "/releases/me004"
    assert_select ".detail__section--audio[aria-label=Previews] .tracks__label.tag--audio", text: "Previews"
    assert_select ".track", 2
    assert_select ".track[data-player-src-value^='https://media.margate-electronics.org/previews/ME004/'][data-player-source-value=ME004]", 2
    assert_select ".track [data-player-target=time]", text: "0:45", count: 2 # at rest just the length
    assert_select ".track", text: /Track three/, count: 0
  end

  test "audio comes before the scattered photos; a recording without a file isn't listed" do
    Event.find_by!(slug: "me-12").tracks.create!(title: "Not uploaded yet", position: 2)
    get "/events/me-12"
    sections = css_select(".detail__body > *").map { |el| el["class"].to_s.split.first }
    assert_operator sections.index("detail__section"), :<, sections.index("gallery"), "recordings before the photos"
    assert_select ".track", 1
    assert_select ".track", text: /Not uploaded yet/, count: 0

    Release.find_by!(slug: "me004").tracks.create!(title: "Track one", position: 1, audio_path: "previews/ME004/01.mp3")
    get "/releases/me004"
    sections = css_select(".detail__body > *").map { |el| el["class"].to_s.split.first }
    audio = css_select(".detail__body > *").index { |el| el["aria-label"] == "Previews" }
    assert audio, "previews listed"
    assert_operator audio, :<, sections.index("price-row") + 3, "previews straight after the price and Buy (and their notes)"
  end

    test "a release without previews has no Previews section" do
    get "/releases/me003"
    assert_select ".detail__section--audio", 0
  end

  test "ME004's button says Pre-order before 9 Oct and Buy from it" do
    travel_to Date.new(2026, 9, 28) do
      get "/releases/me004"
      assert_select ".price-row a.button", text: "Pre-order on Bandcamp"
    end
    travel_to Date.new(2026, 10, 9) do
      get "/releases/me004"
      assert_select ".price-row a.button", text: "Buy on Bandcamp"
    end
  end

  test "photos come from R2 through Cloudflare's resizing, never from Rails" do
    get "/events/me-12"
    assert_select "img.media[src^='https://media.margate-electronics.org/cdn-cgi/image/width=440,'][srcset*='width=880']"
    assert_select ".gallery figure", 3
    assert_select ".gallery figcaption", text: "Rhizocorp"
    assert_no_match %r{/rails/active_storage}, response.body
  end

  test "a print has no size chips; its price shows" do
    get "/prints/waffle"
    assert_select ".chips", 0
    assert_select ".price-row__price", text: "£20"
    assert_select "a.back-link[href='/prints/']"
  end

  test "the print tile opens the print page" do
    get "/"
    assert_select ".tile--print a.tile__link[href='/prints/waffle/']"
  end

  test "release credits are in the credits style; the editor's White shows white" do
    Release.find_by!(slug: "me004").update!(credits: "<p>Mastering: <u>Nicholas de Carlo</u></p>")
    get "/releases/me004"
    assert_select "p.credits span.text-white", text: "Nicholas de Carlo"
    assert_select ".prose u", 0
  end

  test "bracketed words are kept whole, in copy and plain titles" do
    helpers = ApplicationController.helpers
    html = helpers.copy(%(<p>Kodama こだま – koke no ne こけのね (ME004)</p>))
    assert_includes html, %(<span class="nowrap">(ME004)</span>)
    assert_includes helpers.words("Tomas Jefanovas – (Ne)Žmogus"), %(<span class="nowrap">(Ne)Žmogus</span>)
    assert_equal %(Margate Electronics <span class="nowrap">T-shirt</span>), helpers.words("Margate Electronics T-shirt")
    assert_includes helpers.copy("<p>a cross-genre collaboration – live</p>"), %(<span class="nowrap">cross-genre</span> collaboration – live)
    assert_not_includes helpers.words("https://margate-electronics.bandcamp.com/merch"), '"nowrap">https:'
    assert_includes helpers.words("<b>(x)"), "&lt;b&gt;"
    linked = helpers.copy('<a href="/x">link</a> (a)(b)')
    assert_includes linked, %(<a href="/x">link</a>)
    assert_includes linked, %(<span class="nowrap">(a)(b)</span>)
  end

  test "editor text: paragraphs become lines where Enter means a new line; <br> still works" do
    helpers = ApplicationController.helpers
    assert_equal "Cassette + digital<br> Out on 9 Oct", helpers.lines("<p>Cassette + digital</p><p>Out on 9 Oct</p>")
    assert_equal "Cassette + digital<br> Out on 9 Oct", helpers.lines("Cassette + digital<br>Out on 9 Oct")
    assert_equal %(<em>Waffle</em> by <span class="text-white">Tomas</span>), helpers.lines("<p><em>Waffle</em> by <u>Tomas</u></p>")
    assert_equal "Waffle by Tomas", helpers.heading_text("<p><em>Waffle</em> by</p><p>Tomas</p>")
    assert_equal 2, Masonry.lines("<p>One</p><p>Two</p>", width: 440)
  end

  test "on phones a heading's line breaks give way to spaces, so words never run together" do
    get "/events/me-13"
    heading = css_select("h1.page-heading").first
    assert_includes heading.inner_html, "Ambient Garden<br> Kodama"
    # What a phone shows with the breaks hidden
    assert_includes heading.text, "Ambient Garden Kodama"
  end

  test "headings, info and tile text written in the editor show as lines" do
    Product.find_by!(slug: "waffle").update!(heading: "<p><em>Waffle</em></p><p>by Tomas Jefanovas</p>",
      info: "<p>A3 riso print</p><p><u>Signed</u></p>")
    get "/prints/waffle"
    assert_select "h1.page-heading", html: %r{\A<em>Waffle</em><br> by Tomas Jefanovas\z}
    assert_select ".detail__info p", 0
    assert_select ".detail__info", html: %r{A3 riso print<br> <span class="text-white">Signed</span>}
    get "/"
    # The tile's text is written from the heading and info, White kept
    assert_select ".tile--print .tile__caption em", text: "Waffle"
    assert_select ".tile--print .tile__caption span.text-white", text: "Signed"
  end

  test "the lightbox gets a sharper file only when the original has the pixels, and knows the original's width" do
    helpers = ApplicationController.helpers
    blob = ->(width) { ActiveStorage::Blob.new(key: "k#{width}", filename: "p.jpg", metadata: { "width" => width, "height" => width }) }
    small = helpers.lightbox_image(Picture.new(blob: blob.(1333), width: 440, height: 440, alt: "a", caption: nil))
    assert_equal 1333, small[:width]
    assert_equal 1, small[:srcset].split(", ").size
    assert_match(/width=1760,.* 1333w\z/, small[:srcset])
    big = helpers.lightbox_image(Picture.new(blob: blob.(4240), width: 440, height: 440, alt: "a", caption: nil))
    assert_equal [ "1760w", "3520w" ], big[:srcset].split(", ").map { |s| s.split.last }
    get "/events/me-12"
    assert_select "button.media-button[data-dialog-srcset-param][data-dialog-width-param]"
  end

  test "copy shows only italic, White and links: a typed list becomes lines, bold and strikethrough plain text" do
    html = ApplicationController.helpers.copy("<p>Intro</p><ul><li><p>One</p></li><li><p>Two <em>x</em></p></li></ul><p><strong>b</strong> <s>s</s></p>")
    assert_equal "<p>Intro</p><p>One<br>Two <em>x</em></p><p>b s</p>", html
  end

  test "links to other sites open in a new tab; the site's own links don't" do
    html = ApplicationController.helpers.copy(%(<p><a href="https://margate-electronics.bandcamp.com/album/x">Bandcamp</a> <a href="https://margate-electronics.org/about/">About</a> <a href="/events/">Events</a></p>))
    assert_includes html, %(<a href="https://margate-electronics.bandcamp.com/album/x" target="_blank" rel="noopener">Bandcamp</a>)
    assert_includes html, %(<a href="https://margate-electronics.org/about/">About</a>)
    assert_includes html, %(<a href="/events/">Events</a>)

    travel_to Date.new(2026, 9, 28) do
      get "/events/me-13"
      assert_select "a.button[href^='https://www.outsavvy.com/'][target=_blank][rel=noopener]", text: "Book Tickets"
      assert_select ".prose a[href^='http'][target=_blank]", minimum: 1 # the lineup's artist links
      get "/releases/me004"
      assert_select ".price-row a.button[target=_blank]", text: "Pre-order on Bandcamp"
    end
    assert_select ".menu-drop a[href='#{Links::INSTAGRAM}'][target=_blank]"
    assert_select ".menu-drop a[href='#{Links::BANDCAMP}'][target=_blank]"
    assert_select "a.back-link:not([target])"
  end

  test "tab titles: an & shows as &, filter pages have their own" do
    Release.find_by!(slug: "me003").update!(artist: "YKLU & Danny", heading: nil)
    get "/releases/me003"
    assert_select "title", text: "YKLU & Danny – (Ne)Žmogus · Margate Electronics"
    get "/events/"
    assert_select "title", text: "Events · Margate Electronics"
    get "/"
    assert_select "title", text: "Margate Electronics"
  end

  test "house punctuation, however it was typed: curly quotes, en dashes, never in link addresses" do
    helpers = ApplicationController.helpers
    html = helpers.copy(%(<p><a href="https://x.com/it's">A'Bear</a> - "one", 2010s—tools</p>))
    assert_equal %(<p><a href="https://x.com/it's" target="_blank" rel="noopener">A’Bear</a> – “one”, 2010s – tools</p>), html
    assert_equal "(Ne)Žmogus – Side A", helpers.words("(Ne)Žmogus - Side A").to_s.gsub(%r{</?span[^>]*>}, "")
    assert_equal helpers.typography("it’s “x” – y"), helpers.typography(helpers.typography(%(it's "x" - y))), "the same again changes nothing"
  end

  test "a line can break after a slash between words, never inside a link's address" do
    helpers = ApplicationController.helpers
    html = helpers.copy(%(<p><a href="https://x.com/a/b">a/b</a> live-dubbing/rearranging/mix-and-matching</p>))
    assert_includes html, %(href="https://x.com/a/b")
    assert_includes html, "a/<wbr>b"
    assert_includes html, %(<span class="nowrap">live-dubbing</span>/<wbr>rearranging/<wbr><span class="nowrap">mix-and-matching</span>)
    assert_includes helpers.words("Seek/Rope"), "Seek/<wbr>Rope"
  end

  test "a release says how many tapes Bandcamp has left" do
    Release.find_by!(slug: "me003").update!(tape_stock: 9)
    get "/releases/me003"
    assert_select ".price-row + .stock-notes .stock-note", text: "9 of 25 tapes remaining"
    Release.find_by!(slug: "me003").update!(tape_stock: nil)
    get "/releases/me003"
    assert_select ".stock-note:not(.stockist-line)", 0, "no count from Bandcamp, no note"
    release = Release.new(tape_stock: 1)
    assert_equal "1 tape remaining", release.tape_note
  end

  test "a release whose tapes are gone: Tape Sold Out, no tape price, the digital album" do
    Release.find_by!(slug: "me003").update!(tape_stock: 0)
    get "/releases/me003"
    assert_select ".price-row .tag.tag--sold-out", text: "Tape Sold Out"
    assert_select ".price-row a.button[target=_blank]", text: "Buy Digital on Bandcamp"
    assert_select ".price-row__price", 0
    assert_select ".stock-note:not(.stockist-line)", 0, "no tapes-remaining note"
    get "/releases/"
    assert_select ".tile .tag--sold-out", text: "Tape Sold Out"
  end

  test "the white text style survives in any copy" do
    html = ApplicationController.helpers.copy(%(<p>Blue <span class="text-white">white</span></p><p class="text-white">All white</p>))
    assert_includes html, %(<span class="text-white">white</span>)
    assert_includes html, %(<p class="text-white">All white</p>)
  end

  test "the header has the name and Menu, the footer the logo: every link is in the menu" do
    get "/"
    assert_select ".site-header__actions", 0
    assert_select ".site-header button.menu-button[aria-controls=site-menu][aria-expanded=false]", text: "Menu"
    assert_select ".sticky-name button.menu-button[aria-controls=site-menu]", text: "Menu"
    assert_select ".site-footer .link-list, .site-footer__email", 0
    assert_select ".site-footer > a", 1 # just the logo
  end

  test "the menu holds every link, the page you're on marked" do
    get "/about/"
    assert_select "#site-menu[hidden]", 1
    types = Feed.new.counts.count { |_, count| count.positive? }
    assert_select "#site-menu .menu-drop__links li", 7 + types
    assert_select "#site-menu a[href='/archive/']", text: "Index"
    assert_select "#site-menu a[href='/about/'][aria-current=page]", text: "About"
    assert_select "#site-menu a[href='/stockists/']:not([aria-current])", text: "Stockists"
    assert_select "#site-menu a[href='/newsletter/']", text: "Newsletter"
    assert_select "#site-menu a[href^='mailto:']", text: "E-mail"
    assert_select "#site-menu a[href='#{Links::BANDCAMP}']", text: "↑ Bandcamp"
    assert_select "#site-menu a[href='#{Links::INSTAGRAM}']", text: "↑ Instagram"
    assert_select "#site-menu button.menu-drop__close", text: "Close"
  end

  test "About and Stockists have an optional large heading from the admin" do
    get "/about/"
    assert_select "h1.page-heading", text: "Margate Electronics"
    AboutPage.current.update!(heading: "")
    get "/about/"
    assert_select "h1.page-heading", 0
    assert_select "h1.visually-hidden", text: "About"
    get "/stockists/"
    assert_select "h1.page-heading", 0
    StockistsPage.current.update!(heading: "<p>Where to buy</p>")
    get "/stockists/"
    assert_select "h1.page-heading", text: "Where to buy"
  end

  test "pages without an automatic top line can have one typed in the admin" do
    AboutPage.current.update!(top_line: "<p>Since 2023</p>")
    StockistsPage.current.update!(top_line: "<p>Updated October</p>")
    Product.find_by!(slug: "t-shirt").update!(top_line: "<p>Printed in Margate</p>")
    IndexPage.current.update!(top_line: "<p>Everything so far</p>", heading: "<p>Index</p>")
    NewsletterPage.current.update!(top_line: "<p>Monthly</p>")
    { "/about/" => "Since 2023", "/stockists/" => "Updated October", "/apparel/t-shirt/" => "Printed in Margate",
      "/archive/" => "Everything so far", "/newsletter/" => "Monthly" }.each do |path, line|
      get path
      assert_select ".site-header__status", { text: line }, path
    end
    get "/archive/"
    assert_select "h1.page-heading", text: "Index"
    # Empty: the page's name
    AboutPage.current.update!(top_line: "")
    get "/about/"
    assert_select ".site-header__status", text: "About"
  end

  test "About, Stockists, the Index and Newsletter: no section chip, the top line names them unless typed" do
    { "/about/" => "About", "/stockists/" => "Stockists", "/archive/" => "Index", "/newsletter/" => "Newsletter" }.each do |path, name|
      get path
      assert_select ".breadcrumb__chip", { count: 0 }, path
      assert_select ".site-header__status", { text: name }, path
    end
    get "/events/me-12/"
    assert_select ".breadcrumb__chip", text: "Events" # categories keep theirs
  end

  test "the Newsletter page's title: the page's name (shown above the field on phones), or one from the admin" do
    get "/newsletter/"
    assert_select "h1", 1
    assert_select "h1.newsletter__title.newsletter__title--name", text: "Newsletter"
    NewsletterPage.current.update!(heading: "<p>Stay in touch</p>")
    get "/newsletter/"
    assert_select "h1.newsletter__title:not(.newsletter__title--name)", text: "Stay in touch"
  end

  test "no Newsletter Sign Up in the footer: the newsletter is in the menu" do
    %w[/ /archive/ /events/me-12/ /about/ /newsletter/].each do |path|
      get path
      assert_select ".site-footer a[href='/newsletter/']", { count: 0 }, path
    end
  end

  test "the Japanese font is asked for in the weights the site uses, without holding up the page" do
    get "/"
    assert_select "link[rel=stylesheet][href*='Noto+Sans+JP:wght@400;500'][media=print]"
    assert_select "noscript link[href*='Noto+Sans+JP']"
  end

  test "the Index's tables keep table roles for when their rows stack on phones" do
    get "/archive/"
    assert_select "table.ledger[role=table]", 2
    assert_select "table.ledger tbody tr[role=row] td[role=cell]", minimum: 1
    assert_select "table.ledger th[role=columnheader]", minimum: 1
  end

  test "the menu's first group is the home page's types, each only when it has entries" do
    get "/events/"
    assert_select "#site-menu .menu-drop__links:first-of-type a" do |links|
      assert_equal %w[Events Releases Apparel Prints], links.map(&:text)
    end
    assert_select "#site-menu a[href='/events/'][aria-current=page]", text: "Events"
    assert_select "#site-menu a[href='/releases/']:not([aria-current])", text: "Releases"
    Product.where(kind: "print").update_all(published: false)
    get "/"
    assert_select "#site-menu a", text: "Prints", count: 0
  end

  test "the scrolled grey bar shows just the name, without the category chip" do
    %w[/events/me-12 /releases/me004 /apparel/t-shirt /prints/waffle /about /].each do |path|
      get path
      assert_select ".sticky-name__lead a", 1
      assert_select ".sticky-name__lead", text: "Margate Electronics"
      assert_select ".sticky-name .breadcrumb__chip", 0
    end
  end

  test "Back sits in the footer on inner pages" do
    get "/releases/me004"
    assert_select ".site-footer a.back-link", text: "← Back"
  end

  test "the About page starts with the home page line and lists the artists" do
    get "/about"
    assert_select ".prose p:first-child", text: /\AMargate Electronics is an experimental electronic music event series & label, based in Margate, UK\.\z/
    assert_select ".artist-list li", AboutPage.current.artist_names.size
    assert_select "a.back-link", 0, "not a section page: no Back (Tomas, 1 Oct)"
  end

  test "the About page comes from the admin: artists one per line, shown A to Z, each once" do
    AboutPage.current.update!(body: "<p>New text</p>", artists: "<p>Zoe A.</p><p>a'bear</p><p>Ben Sun<br>Zoe A.</p><p></p>")
    assert_equal [ "a'bear", "Ben Sun", "Zoe A." ], AboutPage.current.artist_names
    get "/about"
    assert_select ".prose p", text: "New text"
    assert_select ".artist-list li", 3
    assert_select ".artist-list li:first-child", text: "a’bear"
    assert_not AboutPage.new(body: "<p>Another</p>").valid?, "there is one About page"
  end

  test "the About page's credit line shows under the artists, only when there is one" do
    get "/about"
    assert_select ".artist-list ~ *, section + .prose", 0
    AboutPage.current.update!(credit: %(<p>Website design and build: <a href="https://example.com">Someone</a></p>))
    get "/about"
    assert_select "section.detail__section + .prose.detail__section a[href='https://example.com']", text: "Someone"
  end

  test "the T-shirt Buy button goes to the chosen colour's Bandcamp listing" do
    get "/apparel/t-shirt"
    assert_select "a.button[href='https://margate-electronics.bandcamp.com/merch/m-e-t-shirt']", text: "Buy"
    assert_select ".stock-note:not([hidden])", 2
  end

  test "tile actions are labels, not links" do
    get "/"
    assert_select ".tile__head span.tag", text: "On Sale"
    assert_select ".tile__head a", text: "On Sale", count: 0
  end

  test "the T-shirt has size and colour chips with sold-out sizes disabled" do
    get "/apparel/t-shirt"
    assert_select "fieldset.chips input[name=size]", 4
    assert_select "input[name=size][value=XL][checked]"
    assert_select "input[name=size][disabled]", 3
    assert_select ".chip--sold-out", text: /S\s*, sold out/
    assert_select "input[name=colour][value=Black]"
    assert_select ".stock-note:not([hidden])", text: "1 remaining in XL Natural"
    assert_select ".stock-note:not([hidden])", text: "Sold out: L, M, S"
    assert_select "[data-colour=Natural]:not([hidden]) .main-media"
    assert_select "[data-colour=Black][hidden] .main-media"
  end

  test "sold out: a Sold Out chip in place of Buy or Book Tickets" do
    travel_to Date.new(2026, 9, 28) do
      Event.find_by!(slug: "me-13").update!(sold_out: true)
      Release.find_by!(slug: "me003").update!(sold_out: true)
      Product.find_by!(slug: "waffle").update!(sold_out: true)
      %w[/events/me-13 /releases/me003 /prints/waffle].each do |path|
        get path
        assert_select "main span.tag", { text: "Sold Out", count: 1 }, path
        # Add to Calendar stays: people with tickets still want it
        assert_select "main a.button:not([href$='.ics'])", 0
      end
      get "/events/me-13"
      assert_select "main a.button", text: "Add to Calendar"
    end
  end

  test "sold-out apparel shows one Sold Out chip instead of sizes, colours and Buy" do
    Product.find_by!(slug: "t-shirt").variants.update_all(stock: 0)
    get "/apparel/t-shirt"
    assert_select ".price-row span.tag", text: "Sold Out"
    assert_select ".chips", 0
    assert_select ".stock-note", 0
    assert_select "a.button", 0
    assert_select "[data-controller~=variant]", 0
  end

  test "an unknown filter shows everything" do
    get "/", params: { type: "nonsense" }
    assert_select ".tile", Feed.new.items.size
  end

  test "the 404 page, in the site's design and kept out of search" do
    get "/404.html"
    assert_response :success # the static build stops on a 404; Cloudflare serves it with 404
    assert_select "h1.page-heading", text: "Page not found"
    assert_select "a[href='/']", text: "Go to the home page"
    assert_select "meta[name=robots][content=noindex]"
    assert_select ".site-footer__logo"
  end

  test "the sitemap lists every public page at the site's address" do
    get "/sitemap.xml"
    assert_response :success
    assert_equal "application/xml", response.media_type
    locs = Nokogiri::XML(response.body).remove_namespaces!.xpath("//loc").map(&:text)
    assert_includes locs, "http://www.example.com/"
    assert_includes locs, "http://www.example.com/events/me-13/"
    assert_includes locs, "http://www.example.com/prints/"
    assert_includes locs, "http://www.example.com/about/"
    assert_includes locs, "http://www.example.com/stockists/"
    assert_includes locs, "http://www.example.com/archive/"
    assert_equal Feed.new.items.size + 1 + 4 + 4, locs.size
  end

  test "the Atom feed lists every entry, newest first, and pages point to it" do
    get "/feed.xml"
    assert_response :success
    assert_equal "application/atom+xml", response.media_type
    xml = Nokogiri::XML(response.body) { |config| config.strict }
    xml.remove_namespaces!
    entries = xml.xpath("//entry")
    assert_equal Feed.new.items.size, entries.size
    published = entries.map { |entry| entry.at("published")&.text }.compact
    assert_equal published.sort.reverse, published
    me13 = entries.find { |entry| entry.at("id").text == "http://www.example.com/events/me-13/" }
    assert_match(/\AMargate Electronics #13: Ambient Garden – Kodama こだま/, me13.at("title").text)
    assert_includes me13.at("content").text, "<img src="
    get "/"
    assert_select "head link[rel=alternate][type='application/atom+xml'][href='/feed.xml']"
  end

  test "robots: only the live site may be indexed" do
    get "/robots.txt"
    assert_includes response.body, "Disallow: /"
    host! "margate-electronics.org"
    get "/robots.txt"
    assert_includes response.body, "Allow: /"
    assert_includes response.body, "Sitemap: https://margate-electronics.org/sitemap.xml"
    assert_not_includes response.body, "Disallow"
  end

  test "every page has one main heading, hidden where the design shows none" do
    { "/" => "Margate Electronics", "/events/" => "Margate Electronics: Events", "/stockists" => "Stockists" }.each do |path, text|
      get path
      assert_select "h1", { count: 1 }, path
      assert_select "h1.visually-hidden", text: text
    end
    # A release without a typed heading gets "Artist – Title"
    Release.find_by!(slug: "me003").update!(heading: nil)
    get "/releases/me003"
    assert_select "h1.page-heading", text: "Tomas Jefanovas – (Ne)Žmogus"
    get "/releases/me004"
    assert_select "h1.page-heading", 1
  end

  test "an upcoming event: Book Tickets, then title and lineup, then the details with the prices, then the description" do
    travel_to Date.new(2026, 9, 28) do
      get "/events/me-13"
      assert_select ".price-row__price", 0
      assert_select ".price-row a.button[href^='https://www.outsavvy.com/']", text: "Book Tickets"
      paragraphs = css_select(".detail__info > p")
      block = Nokogiri::HTML5.fragment(paragraphs[0].inner_html.gsub(%r{<br>\s*}, " / ")).text.squish
      assert_match %r{\AMargate Electronics #13: Ambient Garden / Live: Kodama こだま.*Pedro Figueiredo\)\z}, block
      assert_select paragraphs[0], "a", minimum: 1 # artist links kept on the page
      details = paragraphs[1].inner_html.gsub(%r{<br>\s*}, " / ")
      assert_equal "<em>Venue: Margate Arts Club, Margate, UK / Date: Fri 9 Oct 2026 / Time: Doors 7PM / Music 8PM / " \
                   "Tickets: £8, £10 adv / £13 otd / £20 ticket+tape</em>", details,
                   "the details in their own paragraph, a blank line after the lineup"
      assert_match(/\AAn evening of experimental live music/, paragraphs[2].text)
    end
  end

  test "an archived event: no tickets, no date or time in the details" do
    get "/events/me-12"
    assert_select ".price-row", 0
    assert_select ".detail__info > p:first-child", text: /Screening: Eva Papamargariti/
    assert_select ".detail__info > p:nth-child(2) em", text: "Venue: Margate Arts Club, Margate, UK"
  end

  test "an unknown slug is a 404" do
    get "/events/me-99"
    assert_response :not_found
  end
end

class MasonryTest < ActiveSupport::TestCase
  test "places each item in the shortest column, reproducing the Figma home layout" do
    heights = { a: 689, b: 416, c: 417, d: 417, e: 709, f: 564, g: 468 }
    left, right = Masonry.split(heights.keys) { |k| heights[k] }
    assert_equal %i[a d f], left
    assert_equal %i[b c e g], right
  end
end

class ScatterTest < ActiveSupport::TestCase
  test "same seed, same places; in range; never the same as the photo above" do
    columns = [ %w[a b c d], %w[e f g] ]
    places = Scatter.places(columns, seed: "me-12") { 150 }
    assert_equal places, Scatter.places(columns, seed: "me-12") { 150 }
    shifts = places.transform_values(&:shift)
    assert columns[0].all? { |p| Scatter::LEFT.include?(shifts[p]) }
    assert columns[1].all? { |p| Scatter::RIGHT.include?(shifts[p] + Scatter::RIGHT_START) }
    columns.each { |column| column.each_cons(2) { |a, b| refute_equal shifts[a], shifts[b] } }
  end

  test "Reshuffle gives an item's scattered photos a new arrangement; 0 keeps the original" do
    event = Event.new(slug: "me9")
    assert_equal "me9", event.scatter_seed
    event.reshuffle = 2
    assert_equal "me9-2", event.scatter_seed
    columns = [ %w[a b c], %w[d e f] ]
    layouts = (0..4).map { |n| Scatter.places(columns, seed: n.zero? ? "me9" : "me9-#{n}") { 300 } }
    assert_operator layouts.uniq.size, :>, 1, "different numbers, different arrangements"
  end

  test "photos of one size don't line up in rows: seeded drops, the right column starting lower" do
    columns = [ %w[a b c], %w[d e f] ]
    100.times do |seed|
      drops = Scatter.places(columns, seed: seed) { 300 }.transform_values(&:drop)
      assert_equal 0, drops["a"], "the section starts with the first photo on the left"
      assert_includes Scatter::RIGHT_START_DROP, drops["d"]
      assert (drops.values_at("b", "c", "e", "f")).all? { |d| Scatter::DROPS.include?(d) }
    end
  end

  test "photos can sit in the middle, never touching a photo level with them" do
    middle = 0
    200.times do |seed|
      left = %w[a b c d e]
      right = %w[f g h i]
      heights = (left + right).to_h { |p| [ p, 100 + (p.ord * seed) % 200 ] }
      places = Scatter.places([ left, right ], seed: seed) { |p| heights[p] }
      shifts = places.transform_values(&:shift)
      drops = places.transform_values(&:drop)
      rows = ->(column) { Scatter.extents(column, heights.method(:fetch), drops).to_h }
      left_rows, right_rows = rows.(left), rows.(right)
      right.each do |r|
        position = shifts[r] + Scatter::RIGHT_START
        left.each do |l|
          level = right_rows[r].begin < left_rows[l].end + Scatter::MARGIN && left_rows[l].begin < right_rows[r].end + Scatter::MARGIN
          assert (position - shifts[l]).abs >= Scatter::APART, "seed #{seed}: #{l} and #{r} touch" if level
        end
      end
      middle += 1 if shifts[left.first] == 3 || shifts.values_at(*right).include?(-1)
    end
    assert_operator middle, :>, 20, "the middle is used"
  end
end

class InventoryTest < ActiveSupport::TestCase
  def inventory(stock)
    Inventory.new(sizes: %w[XL L M S], colours: %w[Natural Black], stock: stock)
  end

  test "counts, sold-out sizes and the default choice" do
    inv = inventory({ [ "XL", "Natural" ] => 1, [ "L", "Black" ] => 7 })
    assert_equal 1, inv.count("XL", "Natural")
    assert_equal 0, inv.count("S", "Black")
    assert_equal %w[L M S], inv.sold_out_sizes("Natural")
    assert_equal [ "XL", "Natural" ], inv.default_choice
  end

  test "remaining note only when stock is low" do
    inv = inventory({ [ "XL", "Natural" ] => 1, [ "L", "Natural" ] => Inventory::LOW_STOCK + 1 })
    assert_equal "1 remaining in XL Natural", inv.remaining_note("XL", "Natural")
    assert_nil inv.remaining_note("L", "Natural")
    assert_nil inv.remaining_note("S", "Natural")
  end

  test "a colour with nothing left" do
    inv = inventory({ [ "XL", "Natural" ] => 2 })
    refute inv.colour_available?("Black")
    assert_equal "Black: sold out", inv.sold_out_note("Black")
    assert_equal "Sold out: L, M, S", inv.sold_out_note("Natural")
  end
end
