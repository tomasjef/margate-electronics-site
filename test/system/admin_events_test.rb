require "application_system_test_case"

# The event form: lineup lines are added as needed
class AdminEventsTest < ApplicationSystemTestCase
  include AdminSystemHelpers

  setup { sign_in_to_admin }

  test "only the lineup lines in use show; + DJ adds that line, and it saves" do
    visit "/admin/resources/events/me-12/edit" # Live and Screening in use
    settle
    assert_selector ".field-wrapper[data-field-id=live]", visible: true
    assert_selector ".field-wrapper[data-field-id=screening]", visible: true
    assert_no_selector ".field-wrapper[data-field-id=dj]", visible: true
    assert_no_selector ".field-wrapper[data-field-id=workshop]", visible: true
    within(".lineup-add") do
      assert_button "+ DJ"
      assert_button "+ Workshop"
      assert_no_button "+ Live"
    end

    click_until(-> { find_button("+ DJ") }, ->(wait) { has_selector?(".field-wrapper[data-field-id=dj]", visible: true, wait: wait) })
    assert_no_button "+ DJ"
    find(".field-wrapper[data-field-id=dj] .ProseMirror").send_keys "Chupacabras"
    save_form
    assert_equal "Chupacabras", ActionController::Base.helpers.strip_tags(Event.find_by!(slug: "me-12").dj)
  end

  test "a new event starts with all four lineup lines to add; × removes a line and it saves empty" do
    visit "/admin/resources/events/new"
    settle
    within(".lineup-add") { %w[Live DJ Screening Workshop].each { |label| assert_button "+ #{label}" } }
    %w[live dj screening workshop].each { |id| assert_no_selector ".field-wrapper[data-field-id=#{id}]", visible: true }

    visit "/admin/resources/events/me-12/edit" # Screening in use
    settle
    click_until(-> { find_button("Remove the Screening line") }, ->(wait) { has_no_selector?(".field-wrapper[data-field-id=screening]", visible: true, wait: wait) })
    assert_button "+ Screening"
    save_form
    assert_nil Event.find_by!(slug: "me-12").screening
  end
end
