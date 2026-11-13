# An event as a calendar file (iCalendar, RFC 5545), for "Add to Calendar":
# phones and calendar apps open it and offer to add the night. Starts at the
# doors time in UK time; without a time it's an all-day event on the date.
# There is no end time in the admin, so it lasts LENGTH.
class EventCalendar
  include ActionView::Helpers::SanitizeHelper

  LENGTH = "PT4H" # four hours from the doors (Tomas can change it)
  TIME_ZONE = "Europe/London"
  # "7PM", "7:30pm", "7.30 PM", "19:00"
  TIME = /\A\s*(\d{1,2})(?:[:.](\d{2}))?\s*(am|pm)?\s*\z/i

  # UK time, spelled out for calendar apps that don't know it by name (Outlook)
  UK_TIME = [
    "BEGIN:VTIMEZONE", "TZID:#{TIME_ZONE}",
    "BEGIN:DAYLIGHT", "TZOFFSETFROM:+0000", "TZOFFSETTO:+0100", "TZNAME:BST",
    "DTSTART:19700329T010000", "RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU", "END:DAYLIGHT",
    "BEGIN:STANDARD", "TZOFFSETFROM:+0100", "TZOFFSETTO:+0000", "TZNAME:GMT",
    "DTSTART:19701025T020000", "RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU", "END:STANDARD",
    "END:VTIMEZONE"
  ].freeze

  def initialize(event, url:)
    @event = event
    @url = url
  end

  def to_ics
    lines = [
      "BEGIN:VCALENDAR",
      "VERSION:2.0",
      "PRODID:-//Margate Electronics//Events//EN",
      "CALSCALE:GREGORIAN",
      "METHOD:PUBLISH",
      *(UK_TIME if start_time),
      "BEGIN:VEVENT",
      "UID:#{@event.slug}@margate-electronics.org",
      "DTSTAMP:#{@event.updated_at.utc.strftime("%Y%m%dT%H%M%SZ")}",
      *start_lines,
      "SUMMARY:#{escape(@event.title)}",
      ("LOCATION:#{escape(@event.venue)}" if @event.venue.present?),
      "DESCRIPTION:#{escape(description)}",
      "URL:#{@url}",
      "END:VEVENT",
      "END:VCALENDAR"
    ]
    lines.compact.map { |line| fold(line) }.join("\r\n") + "\r\n"
  end

  # [hour, minute] in 24-hour time, or nil when the doors time can't be read
  def self.parse_time(text)
    match = TIME.match(text.to_s) or return
    hour, minute, meridiem = match[1].to_i, match[2].to_i, match[3]&.downcase
    hour = hour % 12 + (meridiem == "pm" ? 12 : 0) if meridiem
    [ hour, minute ] if hour < 24 && minute < 60
  end

  private

  def start_time = self.class.parse_time(@event.doors_at)

  def start_lines
    hour, minute = start_time
    if hour
      [ "DTSTART;TZID=#{TIME_ZONE}:#{@event.date.strftime("%Y%m%d")}T#{format("%02d%02d00", hour, minute)}", "DURATION:#{LENGTH}" ]
    else
      [ "DTSTART;VALUE=DATE:#{@event.date.strftime("%Y%m%d")}", "DTEND;VALUE=DATE:#{(@event.date + 1).strftime("%Y%m%d")}" ]
    end
  end

  # The lineup ("Live: …"), the time, then the page's address
  def description
    lineup = @event.lineup.map { |label, html| "#{label}: #{plain(html)}" }
    [ *lineup, @event.time_line, @url ].compact.join("\n")
  end

  def plain(html) = CGI.unescapeHTML(strip_tags(html.to_s.gsub(%r{</p>\s*<p>}, " "))).squish

  # Backslash, semicolon and comma are escaped, new lines written as \n
  def escape(text) = text.to_s.gsub(/[\\;,]/) { |char| "\\#{char}" }.gsub(/\r?\n/, "\\n")

  # Lines longer than 75 bytes continue on the next line after a space,
  # never splitting a character (Japanese names are 3 bytes a character)
  def fold(line)
    return line if line.bytesize <= 75
    parts = [ +"" ]
    line.each_char do |char|
      limit = parts.size == 1 ? 75 : 74
      parts << +"" if parts.last.bytesize + char.bytesize > limit
      parts.last << char
    end
    parts.join("\r\n ")
  end
end
