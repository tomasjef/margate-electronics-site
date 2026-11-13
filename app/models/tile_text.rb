# The text under a home tile's photo, written from the item's own fields (it
# used to be typed separately). Nil when the item's "Text on the home tile"
# switch is off. HTML, one line per item; lines in <em> are italic. The tile
# is a link, so links in the lineup are left out (their names stay).
module TileText
  module_function

  def for(record, today = Date.current)
    return unless record.show_tile_text?
    lines = case record
    when Event then event(record)
    when Release then release(record, today)
    when Product then product(record)
    end
    lines.compact_blank.join("<br>").presence
  end

  # Heading (or title) and lineup, the same before and after the night (the
  # date, venue and time are on the event's page)
  def event(event)
    headline(event) + event.lineup.map { |label, value| "#{label}: #{flat(value, links: false)}" }
  end

  # Its info lines; while it's a pre-order, when it's out
  def release(release, today)
    lines = split(release.info_html)
    lines << "Out on #{release.release_date.to_fs(:site)}" if release.status(today) == "pre_order"
    lines
  end

  # Heading (or title), then the info lines, without repeating the first
  def product(product)
    head = headline(product)
    info = split(product.info)
    info.shift if info.first && plain(info.first).casecmp?(plain(head.first.to_s))
    head + info
  end

  def headline(record) = record.heading.present? ? split(record.heading) : [ escape(record.title) ]

  # Editor text as lines
  def split(html) = flat(html).split("<br> ").map(&:strip).compact_blank

  def flat(html, links: true)
    text = html.to_s.strip.delete_prefix("<p>").delete_suffix("</p>").gsub(ApplicationHelper::LINE_BREAK, "<br> ")
    links ? text : text.gsub(%r{</?a\b[^>]*>}, "")
  end

  def plain(html) = Nokogiri::HTML5.fragment(html).text.squish

  def escape(text) = ERB::Util.html_escape(text.to_s)
end
