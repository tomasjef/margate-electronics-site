# Helpers for browser tests of the admin (Avo)
module AdminSystemHelpers
  def sign_in_to_admin
    visit "/session/new"
    fill_in "Email", with: users(:one).email_address
    fill_in "Password", with: "password"
    click_on "Sign in"
    assert_no_selector "h1", text: "Sign in"
  end

  # Avo renders in stages: its scripts load deferred (with a warm cache the
  # page can be clickable before they've run, so a click does nothing), and
  # its panels load lazily and refresh. Wait until the page has loaded, Avo's
  # Stimulus is running, nothing is busy, and it's been still a moment.
  def settle
    evaluate_async_script(<<~JS)
      const done = arguments[0];
      let quiet = 0;
      const tick = () => {
        // Deferred scripts have run once the page is complete
        const ready = document.readyState === "complete" && window.Stimulus && window.Turbo && window.Stimulus.controllers.length > 0
        const busy = !ready || document.querySelector("[aria-busy=true], turbo-frame[busy]");
        quiet = busy ? 0 : quiet + 1;
        quiet >= 5 ? done() : setTimeout(tick, 60);
      };
      tick();
    JS
  end

  # In the headless test browser, when the whole file runs, a click in Avo
  # is now and then swallowed while Avo is still wiring up the page (a
  # person's click always works). So: find the element afresh, click, and
  # click again if the expected result doesn't appear, up to three times.
  # The retries click from script: headless Chrome sometimes stops passing
  # mouse input to Avo's edit pages at all (seen 29 Sep and 1 Oct; the same
  # buttons work for a person and from script), and these tests are about
  # what the buttons do, not the browser's input.
  def click_until(find_element, expected, tries: 3)
    tries.times do |attempt|
      settle
      break if expected.call(0) # it already happened (the last click was slow, not lost)
      element = find_element.call
      attempt.zero? ? element.click : element.execute_script("this.click()")
      return if expected.call(10) # a slow machine can take a while to navigate
    end
    assert expected.call(0), "clicked #{tries} times, nothing happened"
  end

  # Click the form's own Save. Proof it saved: Avo's "…successfully…"
  # message (which fades after a few seconds) or the form having gone.
  def save_form
    click_until(-> { find("form button[type=submit]", text: "Save") },
                ->(wait) { has_text?("successfully", wait: wait) || has_no_button?("Save", wait: 0) })
  end
end
