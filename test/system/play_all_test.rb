require "application_system_test_case"

# [ PLAY ALL ] on the Archive page: every recording, shuffled, one after
# another, with [ NEXT ]. The test audio is 10 seconds of silence.
class PlayAllTest < ApplicationSystemTestCase
  setup do
    Event.find_by!(slug: "me-12").tracks.create!(title: "Rhizocorp", audio_path: "ME12_Rhizocorp.mp3", duration: "0:10", position: 2)
    Event.find_by!(slug: "me-13").tracks.create!(title: "Pond", audio_path: "ME13_Pond.mp3", duration: "0:10", position: 1)
  end

  TITLES = [ "hellocatfood", "Rhizocorp", "Pond" ].freeze

  # What the Play All player says is on: "Pond · M.E.#13" gives "Pond"
  def now_playing = find(".play-all .pl-ledger__title").text.split(" · ").first

  def bar_next_hidden? = evaluate_script("document.querySelector('.transport__next').hidden")

  # A page change within the site, as a link makes (the transport carries on)
  def go_to(path) = execute_script("Turbo.visit('#{path}')")

  test "plays every recording once, moving on at the end of each and with Next" do
    visit "/archive/"
    # At rest: how many, and their total time (two typed 0:10, one unknown)
    assert_selector ".play-all .pl-ledger__title", text: "3 recordings, shuffled"
    assert_selector ".play-all .pl-ledger__time", text: "0:20"
    assert_no_selector ".play-all__next"
    find("button[aria-label='Play all recordings, shuffled']").click
    # Playing: the player of the recording that's on (its own time, 10
    # seconds of test audio), [ STOP ] and [ NEXT ]; the bottom bar stays
    # hidden on this page, like a page player's
    assert_selector ".play-all .pl-ledger__time", text: %r{\A\d+:\d\d / 0:10\z}
    assert_selector ".play-all .pl-ledger__title", text: / · M\.E\.#1[23]\z/
    assert_selector ".play-all .is-playing button[aria-label='Pause all recordings']"
    assert_selector ".play-all__next", text: "[ NEXT ]"
    assert_no_selector ".transport__bar"
    played = [ now_playing ]

    find(".play-all__next").click
    assert_no_selector ".play-all .pl-ledger__title", text: played.last
    played << now_playing

    # The end of a recording (the audio element's "ended", as at the real
    # end, without waiting on playback) starts the next; the last has no Next
    execute_script "document.querySelector('#transport audio').dispatchEvent(new Event('ended'))"
    assert_no_selector ".play-all .pl-ledger__title", text: played.last, wait: 15
    played << now_playing
    assert_no_selector ".play-all__next"

    assert_equal TITLES.sort, played.sort
  end

  test "a click on the Play All rule jumps along the recording that's on" do
    visit "/archive/"
    find("button[aria-label='Play all recordings, shuffled']").click
    assert_selector ".play-all .pl-ledger__time", text: %r{ / 0:10\z}
    rule = find(".play-all .pl-ledger__rule")
    rule.click(x: (rule.native.size.width * 0.25).round, y: 0) # from its centre: three quarters along
    assert_in_delta 7.5, evaluate_script("document.querySelector('#transport audio').currentTime"), 1.5
  end

  test "phones: what's on and its time go under the controls, the title moving across when it doesn't fit" do
    page.driver.browser.manage.window.resize_to(390, 844)
    Track.find_by!(title: "Pond").update!(title: "Pond (Rosie Carr & Pedro Figueiredo), live at Margate Arts Club")
    visit "/archive/"
    find("button[aria-label='Play all recordings, shuffled']").click
    3.times do
      break if find(".play-all .pl-ledger__title").text.start_with?("Pond")
      find(".play-all__next").click
    end
    title = find(".play-all .pl-ledger__title.is-scrolling")
    time = find(".play-all .pl-ledger__time")
    assert_operator title.native.rect.y, :>, find(".play-all .pl-ledger__play", match: :first).native.rect.y
    assert_in_delta time.native.rect.y + time.native.rect.height, title.native.rect.y + title.native.rect.height, 6 # one line
    assert_operator title.native.rect.x + title.native.rect.width, :<=, time.native.rect.x
    assert evaluate_script("document.querySelector('.play-all .pl-ledger__line').getAnimations()[0].playState === 'running'")
  ensure
    page.driver.browser.manage.window.resize_to(1440, 900)
  end

  test "the lock screen's next and previous step through the set; previous restarts after a few seconds" do
    # Record what the page tells the phone (removed again at the end: the
    # browser keeps such scripts for the rest of the run)
    recorder = page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: <<~JS)
      window.lockScreen = { handlers: {} };
      const session = navigator.mediaSession;
      const setHandler = session.setActionHandler.bind(session);
      session.setActionHandler = (action, handler) => { window.lockScreen.handlers[action] = handler; setHandler(action, handler) };
    JS
    visit "/archive/"
    find("button[aria-label='Play all recordings, shuffled']").click
    assert_selector ".play-all__next"
    assert evaluate_script("typeof window.lockScreen.handlers.nexttrack === 'function' && typeof window.lockScreen.handlers.previoustrack === 'function'")
    first = now_playing

    execute_script "window.lockScreen.handlers.nexttrack({ action: 'nexttrack' })"
    assert_no_selector ".play-all .pl-ledger__title", text: first
    second = now_playing

    # In its first seconds, previous goes back to the one before
    execute_script "window.lockScreen.handlers.previoustrack({ action: 'previoustrack' })"
    assert_selector ".play-all .pl-ledger__title", text: first

    # Later on, previous goes back to its start
    sleep 0.2 until evaluate_script("Number.isFinite(document.querySelector('#transport audio').duration)")
    execute_script "document.querySelector('#transport audio').currentTime = 6"
    execute_script "window.lockScreen.handlers.previoustrack({ action: 'previoustrack' })"
    assert_operator evaluate_script("document.querySelector('#transport audio').currentTime"), :<, 2
    assert_selector ".play-all .pl-ledger__title", text: first
    refute_equal first, second
  ensure
    page.driver.browser.execute_cdp("Page.removeScriptToEvaluateOnNewDocument", identifier: recorder["identifier"]) if recorder
  end

  test "[ PREV ] goes back to the one before in its first seconds, else to the start" do
    visit "/archive/"
    assert_no_selector ".play-all__previous"
    find("button[aria-label='Play all recordings, shuffled']").click
    # The first recording has none before it, so no [ PREV ] yet
    assert_selector ".play-all__next"
    assert_no_selector ".play-all__previous"
    first = now_playing
    find(".play-all__next").click
    assert_selector ".play-all__previous", text: "[ PREV ]"
    assert_no_selector ".play-all .pl-ledger__title", text: first
    find(".play-all__previous").click
    assert_selector ".play-all .pl-ledger__title", text: first
    assert_no_selector ".play-all__previous" # back on the first

    # Later on in a recording, [ PREV ] goes back to its start
    find(".play-all__next").click
    assert_no_selector ".play-all .pl-ledger__title", text: first
    second = now_playing
    sleep 0.2 until evaluate_script("Number.isFinite(document.querySelector('#transport audio').duration)")
    execute_script "document.querySelector('#transport audio').currentTime = 6"
    find(".play-all__previous").click
    assert_operator evaluate_script("document.querySelector('#transport audio').currentTime"), :<, 2
    assert_selector ".play-all .pl-ledger__title", text: second
  end

  test "the Play All player pauses and resumes the set: [ PLAY ALL ], then [ STOP ] / [ PLAY ]" do
    visit "/archive/"
    assert_selector ".play-all .pl-ledger__play", text: "[ PLAY ALL ]"
    find("button[aria-label='Play all recordings, shuffled']").click
    assert_selector ".play-all .pl-ledger__play", text: "[ STOP ]"
    find("button[aria-label='Pause all recordings']").click
    assert_selector ".play-all button[aria-label='Play all recordings']", text: "[ PLAY ]"
    assert evaluate_script("document.querySelector('#transport audio').paused")
    find(".play-all button[aria-label='Play all recordings']").click
    assert_selector ".play-all button[aria-label='Pause all recordings']"
    assert_selector ".play-all__next"
  end

  test "leaving the Archive, the set plays on in the bottom bar, with Next" do
    visit "/archive/"
    find("button[aria-label='Play all recordings, shuffled']").click
    assert_selector ".play-all__next"
    go_to "/about/"
    assert_selector ".transport__bar", visible: true
    assert_selector ".transport__next", visible: true, text: "[ NEXT ]"
    go_to "/archive/"
    assert_selector ".play-all__next"
    assert_no_selector ".transport__bar"
  end

  test "playing one recording from its page ends the set" do
    visit "/archive/"
    find("button[aria-label='Play all recordings, shuffled']").click
    assert_selector ".play-all__next"
    go_to "/events/me-12/"
    # Whichever of its two recordings the set isn't playing
    find("main .track button[aria-label^='Play ']", match: :first).click
    assert_selector ".track .is-playing", wait: 15
    assert bar_next_hidden?
  end
end
