require "application_system_test_case"

# The player beyond the page: the phone's lock screen (Media Session), the
# keyboard, reduced motion; and how large the lightbox shows a photo.
# The test audio is 10 seconds of silence (test/fixtures/files/silence.wav).
class PlayerAndLightboxTest < ApplicationSystemTestCase
  teardown do
    # Settings sent straight to Chrome last for the whole browser session
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [ { name: "prefers-reduced-motion", value: "" } ])
  end

  def play_hellocatfood
    visit "/events/me-12"
    find("button[aria-label='Play hellocatfood']").click
    assert_selector ".track .is-playing", wait: 15
    # Duration known, so seeking works
    assert_selector "[data-player-target=time]", text: %r{/ 0:10}, wait: 15
  end

  def audio_time = evaluate_script("Math.round(document.querySelector('#transport audio').currentTime)")

  test "the lock screen can jump along the track and skip back and forward" do
    # Record what the page tells the phone, before the page's own scripts run
    page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: <<~JS)
      window.lockScreen = { handlers: {}, positions: [] };
      const session = navigator.mediaSession;
      const setHandler = session.setActionHandler.bind(session);
      session.setActionHandler = (action, handler) => { window.lockScreen.handlers[action] = handler; setHandler(action, handler) };
      const setPosition = session.setPositionState.bind(session);
      session.setPositionState = (state) => { window.lockScreen.positions.push(state); setPosition(state) };
    JS
    play_hellocatfood
    handlers = evaluate_script("Object.keys(window.lockScreen.handlers)")
    assert_equal %w[play pause stop seekto seekbackward seekforward].sort, handlers.sort

    execute_script "document.querySelector('#transport audio').pause()"
    execute_script "window.lockScreen.handlers.seekto({ action: 'seekto', seekTime: 7 })"
    assert_equal 7, audio_time
    execute_script "window.lockScreen.handlers.seekbackward({ action: 'seekbackward', seekOffset: 3 })"
    assert_equal 4, audio_time
    execute_script "window.lockScreen.handlers.seekforward({ action: 'seekforward', seekOffset: 2 })"
    assert_equal 6, audio_time
    # Past either end, it stops at the end or the start
    execute_script "window.lockScreen.handlers.seekbackward({ action: 'seekbackward' })"
    assert_equal 0, audio_time

    # The phone is told the length and where it is after each change
    last = evaluate_script("window.lockScreen.positions.at(-1)")
    assert_in_delta 10, last["duration"], 0.1
    assert_in_delta 0, last["position"], 0.5
  end

  test "the arrow keys skip 10 seconds on the focused player" do
    play_hellocatfood
    execute_script "document.querySelector('#transport audio').pause()"
    button = find("button[aria-label^='Pause hellocatfood'], button[aria-label^='Play hellocatfood']")
    button.send_keys :right
    assert_equal 10, audio_time # the end of the 10-second test file
    button.send_keys :left
    assert_equal 0, audio_time
  end

  test "reduced motion: the logo still turns with scroll, the bar's long title stays still" do
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [ { name: "prefers-reduced-motion", value: "reduce" } ])
    visit "/"
    assert evaluate_script("matchMedia('(prefers-reduced-motion: reduce)').matches")
    execute_script "window.scrollTo(0, 600)"
    assert_selector ".site-footer__logo img[style*='rotate']"

    page.driver.browser.manage.window.resize_to(390, 844)
    visit "/events/me-12"
    execute_script "document.querySelector('.track[data-player-src-value]').dataset.playerTitleValue = 'Tomas Jefanovas, Christopher Brett Bailey - Holes'"
    find("button[aria-label='Play hellocatfood']").click
    assert_selector ".track .is-playing", wait: 15
    click_on "Margate Electronics", match: :first
    assert_selector ".transport__bar", text: "[ STOP ]"
    assert_no_selector ".transport__title.is-scrolling"
    # Nor the page player's
    visit "/events/me-12"
    execute_script "document.querySelector('.pl-ledger__line > span').textContent = 'Tomas Jefanovas, Christopher Brett Bailey - Holes'"
    find("button[aria-label='Play hellocatfood']").click
    assert_selector ".track .is-playing", wait: 15
    assert_no_selector ".pl-ledger__title.is-scrolling"
  ensure
    page.driver.browser.manage.window.resize_to(1440, 900)
  end

  test "a page player's long title stays on one line and moves across while playing" do
    page.driver.browser.manage.window.resize_to(390, 844)
    visit "/events/me-12"
    execute_script "document.querySelector('.pl-ledger__line > span').textContent = 'Tomas Jefanovas, Christopher Brett Bailey - Holes, live at Margate Electronics'"
    row_height = "document.querySelector('.pl-ledger__row').getBoundingClientRect().height"
    line_height = "parseFloat(getComputedStyle(document.querySelector('.pl-ledger__row')).lineHeight)"
    assert_operator evaluate_script(row_height), :<, evaluate_script(line_height) * 1.5, "one line"
    assert_no_selector ".pl-ledger__title.is-scrolling"

    find("button[aria-label='Play hellocatfood']").click
    assert_selector ".pl-ledger__title.is-scrolling", wait: 15
    # Against the page's own width: Linux browsers draw a scrollbar inside the window
    assert_equal 0, evaluate_script("document.documentElement.scrollWidth - document.documentElement.clientWidth"), "no sideways scroll"
    find("button[aria-label^='Pause hellocatfood']").click
    assert_no_selector ".pl-ledger__title.is-scrolling"
  ensure
    page.driver.browser.manage.window.resize_to(1440, 900)
  end

  test "the lightbox never shows a photo larger than the original" do
    visit "/events/me-12"
    find("button[aria-label='Enlarge: Margate Electronics #12 poster']").click
    image = find("dialog#lightbox[open] img.dialog__image")
    # The seeded poster is 880 pixels wide: no sharper version to offer, and
    # never wider than 880 pixels of the screen
    figure = find("dialog#lightbox .dialog__figure")
    assert_equal "min(100%, 880px)", figure[:style][/max-width:\s*([^;]+)/, 1]
    assert_equal 1, image[:srcset].split(", ").size
    assert_match(/ 880w\z/, image[:srcset])
    shown = evaluate_script("document.querySelector('dialog#lightbox img.dialog__image').getBoundingClientRect().width")
    assert_operator shown, :<=, 880

    # Each photo has its own limit: Rhizocorp's original is 400 pixels wide
    send_keys :escape
    find("button[aria-label='Enlarge: Rhizocorp']").click
    assert_selector "dialog#lightbox[open] img[alt='Rhizocorp']"
    assert_includes find("dialog#lightbox .dialog__figure")[:style], "400px"

    # The caption starts at the photo's left edge, however long it is
    execute_script "document.querySelector('dialog#lightbox figcaption').textContent = 'A caption much longer than this narrow photo is wide, to check it wraps under the photo'"
    edges = evaluate_script("['img.dialog__image', 'figcaption'].map(s => Math.round(document.querySelector('dialog#lightbox ' + s).getBoundingClientRect().left))")
    assert_equal edges.first, edges.last
    widths = evaluate_script("['img.dialog__image', 'figcaption'].map(s => Math.round(document.querySelector('dialog#lightbox ' + s).getBoundingClientRect().width))")
    assert_equal widths.first, widths.last, "the caption wraps within the photo's width"
  end
end
