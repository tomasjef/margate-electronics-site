require "test_helper"

# "Add to Calendar": the event as an iCalendar file (RFC 5545)
class EventCalendarTest < ActiveSupport::TestCase
  def ics(event)
    EventCalendar.new(event, url: "https://margate-electronics.org/events/#{event.slug}/").to_ics
  end

  test "doors times are read in their usual forms" do
    assert_equal [ 19, 0 ], EventCalendar.parse_time("7PM")
    assert_equal [ 19, 30 ], EventCalendar.parse_time("7:30pm")
    assert_equal [ 19, 30 ], EventCalendar.parse_time("7.30 PM")
    assert_equal [ 0, 0 ], EventCalendar.parse_time("12am")
    assert_equal [ 12, 0 ], EventCalendar.parse_time("12PM")
    assert_equal [ 19, 0 ], EventCalendar.parse_time("19:00")
    assert_nil EventCalendar.parse_time("late")
    assert_nil EventCalendar.parse_time("")
  end

  test "an event with a doors time starts then, in UK time, for four hours" do
    file = ics(Event.find_by!(slug: "me-13"))
    assert file.start_with?("BEGIN:VCALENDAR\r\n")
    assert file.end_with?("END:VCALENDAR\r\n")
    assert_includes file, "UID:me-13@margate-electronics.org\r\n"
    assert_includes file, "DTSTART;TZID=Europe/London:20261009T190000\r\n"
    assert_includes file, "DURATION:PT4H\r\n"
    assert_includes file, "SUMMARY:Margate Electronics #13: Ambient Garden\r\n"
    assert_includes file, "BEGIN:VTIMEZONE\r\nTZID:Europe/London\r\n"
    assert_includes file, "LOCATION:Margate Arts Club\\, Margate\\, UK\r\n"
    assert_includes file, "URL:https://margate-electronics.org/events/me-13/\r\n"
  end

  test "without a time it is an all-day event" do
    event = Event.find_by!(slug: "me-13")
    event.doors_at = nil
    file = ics(event)
    assert_includes file, "DTSTART;VALUE=DATE:20261009\r\n"
    assert_includes file, "DTEND;VALUE=DATE:20261010\r\n"
    refute_includes file, "DURATION"
    refute_includes file, "VTIMEZONE"
  end

  test "the description has the lineup as plain text and the page's address" do
    file = ics(Event.find_by!(slug: "me-13")).gsub("\r\n ", "")
    description = file[/^DESCRIPTION:(.*)$/, 1]
    assert_match(/\ALive: Kodama こだま/, description)
    refute_match(/<|&amp;/, description)
    assert_includes description, "\\nhttps://margate-electronics.org/events/me-13/"
  end

  test "long lines are folded at 75 bytes without splitting a character" do
    event = Event.find_by!(slug: "me-13")
    event.title = "こけのね " * 30
    file = ics(event)
    file.split("\r\n").each { |line| assert_operator line.bytesize, :<=, 75 }
    assert file.valid_encoding?
    assert_includes file.gsub("\r\n ", ""), "SUMMARY:#{"こけのね " * 30}\r\n"
  end
end
