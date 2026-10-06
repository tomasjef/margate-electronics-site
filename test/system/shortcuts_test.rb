require "application_system_test_case"

# Keyboard shortcuts: Space plays and pauses, ← goes Back, → to the next
# entry; left alone while typing or with the lightbox open
class ShortcutsTest < ApplicationSystemTestCase
  def press(key) = find("body").send_keys(key)

  def paused? = evaluate_script("document.querySelector('#transport audio').paused")

  test "Space pauses and plays what's in the transport" do
    visit "/events/me-12/"
    find("button[aria-label='Play hellocatfood']").click
    assert_selector ".track .is-playing", wait: 15
    execute_script "document.activeElement.blur()"
    press :space
    assert_predicate self, :paused?
    press :space
    refute_predicate self, :paused?
  end

  test "→ goes to the next entry and ← back again" do
    next_path = Feed.new.next_path("/events/me-12/")
    visit "/events/me-12/"
    press :right
    assert_current_path next_path
    press :left
    assert_current_path "/events/me-12/"
  end

  test "not while typing, nor with the lightbox open" do
    visit "/newsletter/"
    find("input[type=email]").send_keys("a", :right)
    assert_current_path "/newsletter/"

    visit "/events/me-12/"
    find("button[aria-label='Enlarge: Rhizocorp']").click
    assert_selector "dialog#lightbox[open]"
    press :right
    assert_current_path "/events/me-12/"
  end
end
