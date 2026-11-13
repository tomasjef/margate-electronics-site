require "application_system_test_case"

class DesignInteractionsTest < ApplicationSystemTestCase
  test "filtering the home page, clearing it, and a tile's tag as a filter" do
    visit "/"
    all_tiles = all(".tile").size
    find(".filter-key a", text: "Events").click
    assert_current_path "/events/"
    assert_selector ".filter-key a[aria-current=page]", text: "Events"
    assert_selector ".tile", count: 2
    assert_no_selector ".tile:not(.tile--event)"

    find(".filter-key__clear").click
    assert_current_path "/"
    assert_no_selector ".filter-key__clear"
    assert_selector ".tile", count: all_tiles

    find(".tile__head a.tag", exact_text: "Release").click
    assert_current_path "/releases/"
    assert_no_selector ".tile:not(.tile--release)"
  end

  test "Newsletter (in the menu) opens the sign-up page, at its own address" do
    visit "/"
    find(".site-header__menu").click
    within("#site-menu") { click_on "Newsletter" }
    assert_current_path "/newsletter/"
    assert_selector ".site-header__status", text: "Newsletter"
    assert_selector "input#newsletter-email[placeholder='E-mail address']"
  end

  # MailerLite's reply is faked, so the tests never add anyone to the real list
  def fake_mailerlite(reply)
    execute_script(<<~JS)
      window.fetch = async (url, options) => {
        window.lastSignup = { url: String(url), email: options.body.get("fields[email]") }
        return new Response(JSON.stringify(#{reply.to_json}), { headers: { "Content-Type": "application/json" } })
      }
    JS
  end

  test "subscribing on the newsletter page" do
    visit "/newsletter"
    fake_mailerlite(success: true)
    within "#newsletter" do
      fill_in "E-mail address", with: "listener@example.com"
      click_on "Subscribe"
      assert_selector "[role=status]", text: "you're on the list"
      assert_no_selector "form.newsletter__form"
    end
    signup = evaluate_script("window.lastSignup")
    assert_equal Rails.configuration.x.newsletter_form_action, signup["url"]
    assert_equal "listener@example.com", signup["email"]
  end

  test "a sign-up MailerLite refuses shows its reason in place" do
    visit "/newsletter"
    fake_mailerlite(success: false, errors: { fields: { email: [ "The email must be a valid email address." ] } })
    fill_in "E-mail address", with: "listener@example.com"
    click_on "Subscribe"
    assert_selector "[role=alert]", text: "The email must be a valid email address."
    assert_selector "input[aria-invalid=true]"
  end

  test "an event photo opens in the lightbox and Esc closes it" do
    visit "/events/me-12"
    find("button[aria-label='Enlarge: Rhizocorp']").click
    assert_selector "dialog#lightbox[open] img[alt='Rhizocorp']"
    assert_selector "dialog#lightbox figcaption", text: "Rhizocorp"
    assert_selector "dialog#lightbox a.dialog__brand", text: "Margate Electronics"
    assert_no_selector "dialog#lightbox img[alt='Margate Electronics home']"
    send_keys :escape
    assert_no_selector "dialog#lightbox[open]"
  end

  test "a thumbnail replaces the main image" do
    # ME004 has one photo so far; a second one gives the gallery thumbnails
    release = Release.find_by!(slug: "me004")
    blob = ActiveStorage::Blob.create_and_upload!(io: file_fixture("../../../app/assets/images/prototype/me003-tile-orange.jpg").open,
      filename: "second.jpg", content_type: "image/jpeg", metadata: { "width" => 880, "height" => 659, "analyzed" => true })
    release.images.create!(file: blob, alt: "Second photo", position: 2)

    visit "/releases/me004"
    assert_selector ".thumbs .thumb-button", count: 2
    shape = ->(selector) { evaluate_script("(r => Math.round(r.width / r.height * 100) / 100)(document.querySelector(\"#{selector}\").getBoundingClientRect())") }
    # Each thumbnail in its photo's own shape: the second is 880 × 659
    assert_in_delta 880.0 / 659, shape.(".thumbs li:nth-child(2) img"), 0.03
    first_shape = shape.(".main-media > .media-button img")
    find("button[aria-label='Show: Second photo']").click
    assert_selector ".main-media img.media[alt='Second photo']"
    assert_selector ".main-media img.media[srcset*='#{blob.key}']"
    # The main photo takes the second photo's shape, and back again
    assert_in_delta 880.0 / 659, shape.(".main-media > .media-button img"), 0.03
    find(".thumbs li:first-child button").click
    assert_in_delta first_shape, shape.(".main-media > .media-button img"), 0.03
  end

  test "the site name stays and shortens on scroll; the logo is back upright at the bottom" do
    visit "/"
    assert_selector ".lead-rest", visible: true
    execute_script "window.scrollTo(0, document.documentElement.scrollHeight)"
    assert_selector "body.is-scrolled"
    assert_selector ".lead-rest", visible: false
    assert_selector ".site-header__lead a", text: "Margate Electronics", visible: true
    angle = evaluate_script("parseFloat(document.querySelector('.site-footer__logo img').style.transform.match(/rotate\\(([-\\d.]+)deg/)[1])")
    assert_in_delta 0, angle % 360, 0.5
  end

  test "the logo turns only with scroll: music doesn't move it, and it is upright at the top and bottom" do
    visit "/events/me-12"
    angle = -> { evaluate_script("parseFloat((document.querySelector('.site-footer__logo img').style.transform.match(/rotate\\(([-\\d.]+)deg/) || [0, 0])[1])") }
    find("button[aria-label='Play hellocatfood']").click
    assert_selector ".track .is-playing", wait: 15
    still = angle.call # after the click, which scrolls the button into view
    sleep 1
    assert_in_delta still, angle.call, 0.1
    find("button[aria-label^='Pause hellocatfood']").click
    # Instant, as the page scrolls smoothly
    execute_script "window.scrollTo({ top: 0, behavior: 'instant' })"
    sleep 0.2
    assert_in_delta 0, angle.call % 360, 0.5
    execute_script "window.scrollTo({ top: document.documentElement.scrollHeight, behavior: 'instant' })"
    sleep 0.2
    assert_in_delta 0, angle.call % 360, 0.5
  end

  test "selected text takes the page's category colour" do
    visit "/events/me-12"
    assert_equal "rgb(255, 229, 0)", evaluate_script("getComputedStyle(document.querySelector('.detail__info'), '::selection').backgroundColor")
  end

  test "the lightbox shows a photo's dither at its size while it loads, then the photo" do
    Image.update_all(dither: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNgAAAAAgABSK+kcQAAAABJRU5ErkJggg==")
    visit "/events/me-12"
    # The lightbox's photo "still loading" until released: it reads as not
    # complete, and its decode waits
    execute_script <<~JS
      const image = document.querySelector(".dialog__image")
      let release
      const loaded = new Promise(resolve => { release = resolve })
      Object.defineProperty(image, "complete", { get: () => false, configurable: true })
      image.decode = () => loaded
      window.releasePhoto = () => { delete image.complete; release() }
    JS
    find("button[aria-label='Enlarge: Rhizocorp']").click
    image = find("dialog#lightbox[open] img.dialog__image.is-dithering")
    assert_match(/width: \d+px/, image[:style])
    assert_includes image[:style], "--dither: url(data:image/png"
    assert_selector "dialog#lightbox .dialog__caption", visible: true
    execute_script "window.releasePhoto()"
    assert_no_selector "dialog#lightbox img.is-dithering"
    refute_match(/width:/, find("dialog#lightbox img.dialog__image")[:style].to_s)
  end

  test "stepping on before a photo has loaded leaves no size behind for the next" do
    Image.update_all(dither: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNgAAAAAgABSK+kcQAAAABJRU5ErkJggg==")
    visit "/events/me-12"
    # The photo it opens on never finishes loading (so its own clean-up never runs)
    execute_script <<~JS
      const image = document.querySelector(".dialog__image")
      Object.defineProperty(image, "complete", { get: () => false, configurable: true })
      image.decode = () => new Promise(() => {})
      window.letPhotosLoad = () => { delete image.complete; delete image.decode }
    JS
    find("button[aria-label='Enlarge: Rhizocorp']").click
    assert_selector "dialog#lightbox[open] img.dialog__image.is-dithering"
    execute_script "window.letPhotosLoad()"
    find("dialog#lightbox .dialog__next").click
    assert_no_selector "dialog#lightbox img.is-dithering"
    refute_match(/width:/, find("dialog#lightbox img.dialog__image")[:style].to_s)
  end

  test "the lightbox steps through the page's images and wraps round" do
    visit "/events/me-12"
    find("button[aria-label='Enlarge: Rhizocorp']").click
    within "dialog#lightbox" do
      assert_selector "img[alt='Rhizocorp']"
      click_on "Next →"
      assert_selector "img[alt='Margate Electronics #12 poster']"
      click_on "← Prev"
      assert_selector "img[alt='Rhizocorp']"
    end
    send_keys :arrow_left
    assert_selector "dialog#lightbox img[alt='Eva Papamargariti']"
    assert_selector "dialog#lightbox figcaption", text: "Eva Papamargariti"
  end

  test "the hellocatfood recording plays and shows its time" do
    visit "/events/me-12"
    find("button[aria-label='Play hellocatfood']", match: :first).click
    assert_selector ".track .is-playing", wait: 15
    assert_selector "[data-player-target=time]", text: %r{\A\d+:\d{2} / \d+:\d{2}}, wait: 15
    find("button[aria-label='Pause hellocatfood']").click
    assert_no_selector ".track .is-playing"
  end

  test "a recording keeps playing across pages; the bar stops it" do
    visit "/events/me-12"
    find("button[aria-label='Play hellocatfood']").click
    assert_selector ".track .is-playing", wait: 15
    # On its own page the track's player shows it: no bar, no doubling
    assert_no_selector ".transport__bar"
    # Mark the audio element: after the page change it must be the same one
    execute_script "document.querySelector('#transport audio').dataset.mark = 'kept'"

    click_on "Margate Electronics", match: :first
    find(".tile--release .tile__link", match: :first).click
    assert_current_path %r{/releases/}
    assert_equal "kept", evaluate_script("document.querySelector('#transport audio').dataset.mark")
    assert evaluate_script("!document.querySelector('#transport audio').paused"), "still playing"
    assert_selector ".transport__bar", text: "hellocatfood · M.E.#12"
    assert_selector ".transport__bar", text: "[ STOP ]"

    # The bar's title goes back to the recording's page, which shows it playing
    find(".transport__title").click
    assert_current_path "/events/me-12/"
    assert_selector ".track .is-playing"
    assert_selector ".pl-ledger__rule", text: "|"
    assert_no_selector ".transport__bar"

    # Away again: [ STOP ] pauses and the bar stays; [ PLAY ] resumes
    click_on "Margate Electronics", match: :first
    find(".transport__button").click
    assert_selector ".transport__bar", text: "[ PLAY ]"
    assert evaluate_script("document.querySelector('#transport audio').paused")
    find(".transport__button").click
    assert_selector ".transport__bar", text: "[ STOP ]"
    assert evaluate_script("!document.querySelector('#transport audio').paused")

    # [ CLOSE ] stops it and removes the bar
    find(".transport__close").click
    assert_no_selector ".transport__bar"
    assert evaluate_script("document.querySelector('#transport audio').paused")
  end

  test "phones: a long title scrolls across the bar while playing and rests when paused" do
    page.driver.browser.manage.window.resize_to(390, 844)
    visit "/events/me-12"
    execute_script "document.querySelector('.track[data-player-src-value]').dataset.playerTitleValue = 'Tomas Jefanovas, Christopher Brett Bailey - Holes'"
    find("button[aria-label='Play hellocatfood']").click
    assert_selector ".track .is-playing", wait: 15
    click_on "Margate Electronics", match: :first
    assert_selector ".transport__title.is-scrolling"
    find(".transport__button").click
    assert_selector ".transport__bar", text: "[ CLOSE ]"
    assert_no_selector ".transport__title.is-scrolling"
  ensure
    page.driver.browser.manage.window.resize_to(1440, 900)
  end

  test "a release preview plays and carries on in the bar as title · ME004" do
    Release.find_by!(slug: "me004").tracks.create!(title: "Track one", position: 1, audio_path: "previews/ME004/01-track-one.mp3")
    visit "/releases/me004"
    find("button[aria-label='Play Track one']").click
    assert_selector ".track .is-playing", wait: 15
    click_on "Margate Electronics", match: :first
    assert_selector ".transport__bar", text: "Track one · ME004"
  end

  test "Back goes one step back after moving within the site, not to the section" do
    visit "/"
    find(".tile--event .tile__link", match: :first).click
    assert_current_path %r{/events/me-}
    click_on "← Back"
    assert_current_path "/"
  end

  test "Back returns to the page you came from" do
    visit "/releases/"
    find(".tile__link", match: :first).click
    assert_current_path %r{/releases/}
    click_on "← Back"
    assert_current_path "/releases/"
  end

  test "switching colour updates the stock notes" do
    visit "/apparel/t-shirt"
    assert_text "1 remaining in XL Natural"
    assert_selector "img[alt='Margate Electronics T-shirt, natural']"
    find("label.chip", text: "Black").click
    assert_text "1 remaining in XL Black"
    # No black photos yet: the Black set falls back to the product's first photo
    assert_selector "[data-colour=Black] .main-media img"
    assert_selector "[data-colour=Natural]", visible: :hidden
    assert_text "Sold out: L, M, S"
    assert_selector "a.button[href$='/merch/m-e-t-shirt-2']", text: "Buy"
    assert_text "Fabric: black"
  end

  test "clicking the lightbox image goes to the next one and wraps round" do
    visit "/events/me-12"
    find("button[aria-label='Enlarge: Rhizocorp']").click
    image = find("dialog#lightbox img.dialog__image")
    image.click
    assert_selector "dialog#lightbox img[alt='Margate Electronics #12 poster']"
    3.times { find("dialog#lightbox img.dialog__image").click }
    assert_selector "dialog#lightbox[open] img[alt='Rhizocorp']"
  end

  test "Menu drops the block of links over the page; Close, Esc or the page close it" do
    visit "/"
    assert_no_selector "#site-menu", visible: true
    find(".site-header__menu").click
    within("#site-menu") do
      assert_selector "a", text: "About"
      assert_selector "a", text: "↑ Bandcamp"
    end
    # Focus moves into it; the page behind doesn't scroll
    assert_equal "Events", evaluate_script("document.activeElement.textContent")
    assert evaluate_script("document.documentElement.classList.contains('has-menu')")
    find(".site-header__menu[aria-expanded=true]", visible: :all)
    # The page behind is out of reach: Tab stays in the menu
    assert evaluate_script("document.getElementById('main').closest('[inert]') !== null")
    refute evaluate_script("document.getElementById('site-menu').closest('[inert]') !== null")
    click_on "Close"
    refute evaluate_script("document.querySelector('[inert]') !== null")
    assert_no_selector "#site-menu", visible: true
    refute evaluate_script("document.documentElement.classList.contains('has-menu')")

    find(".site-header__menu").click
    find("body").send_keys(:escape)
    assert_no_selector "#site-menu", visible: true

    find(".site-header__menu").click
    find(".menu-drop__backdrop").click(x: 0, y: 200)
    assert_no_selector "#site-menu", visible: true

    # A link in it goes there, and the page scrolls again
    find(".site-header__menu").click
    within("#site-menu") { click_on "About" }
    assert_current_path "/about/"
    assert_no_selector "#site-menu", visible: true
    refute evaluate_script("document.documentElement.classList.contains('has-menu')")
  end

  test "a page left through the menu comes back without it: no flash of the menu" do
    page.driver.browser.manage.window.resize_to(390, 844)
    visit "/"
    find(".site-header__menu").click
    within("#site-menu") { click_on "About" }
    assert_current_path "/about/"
    # Turbo shows its copy of home first (a preview), then the page
    execute_script <<~JS
      window.menuOnRender = []
      document.addEventListener("turbo:render", () => window.menuOnRender.push(!document.getElementById("site-menu").hidden))
    JS
    find(".site-header__lead a", text: "Margate Electronics").click
    assert_current_path "/"
    assert_selector ".tile"
    assert_equal [ false ], evaluate_script("window.menuOnRender").uniq
  ensure
    page.driver.browser.manage.window.resize_to(1440, 900)
  end

  test "phones: Menu in the header and, mid-page, in the grey bar opens the same block; filters are gone" do
    page.driver.browser.manage.window.resize_to(390, 844)
    visit "/"
    assert_no_selector ".filter-key", visible: true
    # At the top it sits in the page, in the header's place, pushing it down
    main_top = evaluate_script("document.getElementById('main').getBoundingClientRect().top")
    find(".site-header__menu").click
    assert_selector "#site-menu a", text: "Newsletter"
    assert evaluate_script("document.documentElement.classList.contains('menu-flow')")
    refute evaluate_script("document.querySelector('[inert]') !== null") # in the page, not over it
    assert_operator evaluate_script("document.getElementById('main').getBoundingClientRect().top"), :>, main_top
    assert_no_selector ".site-header", visible: true
    # Even spacing: name, the groups, the line under them and what
    # follows, 40 apart (trimmed boxes: cap height to baseline)
    gaps = evaluate_script(<<~JS)
      (() => {
        const box = (el) => el.getBoundingClientRect()
        const lists = [...document.querySelectorAll(".menu-drop__links")].map(ul => [...ul.querySelectorAll("li")])
        const next = [...document.querySelectorAll("main .tile")][0]
        const panel = box(document.querySelector(".menu-drop__panel"))
        return [
          box(lists[0][0]).top - box(document.querySelector(".menu-drop__name")).bottom,
          ...lists.slice(1).map((list, i) => box(list[0]).top - box(lists[i].at(-1)).bottom),
          panel.bottom - 1 - box(lists.at(-1).at(-1)).bottom,
          box(next).top - panel.bottom
        ].map(Math.round)
      })()
    JS
    gaps.each { |gap| assert_in_delta 40, gap, 1, "menu gaps #{gaps.inspect}" }
    click_on "Close"
    assert_selector ".site-header", visible: true
    execute_script "window.scrollTo(0, 900)"
    find(".sticky-name__menu").click
    assert_selector "#site-menu", visible: true
    assert_equal 900, evaluate_script("Math.round(window.scrollY)")
  ensure
    page.driver.browser.manage.window.resize_to(1440, 900)
  end
end
