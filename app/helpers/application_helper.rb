module ApplicationHelper
  TAG_CLASSES = {
    "Next Event" => "tag--event", "Event" => "tag--event",
    "New Release" => "tag--release", "Release" => "tag--release",
    "Apparel" => "tag--apparel", "Print" => "tag--print", "Audio" => "tag--audio",
    Feed::SOLD_OUT => "tag--sold-out", Feed::TAPE_SOLD_OUT => "tag--sold-out"
  }.freeze

  # Tile kind to its home filter key.
  FILTER_FOR = { event: "events", release: "releases", apparel: "apparel", print: "prints" }.freeze

  # Trusted, static copy from the catalogue: allow only inline markup. Any
  # paragraph or <span> can carry class="text-white" (the white text style).
  # In the admin's text editor the White button is the editor's underline
  # (<u>), so <u> becomes the white style here.
  # A list typed in the editor ("- " at the start of a line) comes out as a
  # paragraph of lines, rather than running together.
  def copy(html)
    html = html.to_s.gsub(%r{<[ou]l[^>]*>(.*?)</[ou]l>}m) do
      items = Regexp.last_match(1).scan(%r{<li[^>]*>(.*?)</li>}m).map { |(item)| item.gsub(%r{</?p[^>]*>}, "").strip }
      "<p>#{items.join("<br>")}</p>"
    end
    clean = sanitize(html, tags: %w[p br em a span u], attributes: %w[href class])
    clean = clean.gsub(/(?<=\A|>)[^<]+/) { |text| typography(text).gsub(SLASH, "/<wbr>") } # the text between tags
    clean = clean.gsub(%r{<a href="(https?://[^"]+)"}) { external?(Regexp.last_match(1)) ? %(<a href="#{Regexp.last_match(1)}" #{EXTERNAL_ATTRIBUTES}) : Regexp.last_match(0) }
    keep_brackets_together(clean.gsub(%r{<u(?:\s[^>]*)?>}, %(<span class="text-white">)).gsub("</u>", "</span>"))
  end

  # Links to other sites open in a new tab (Tomas, 29 Sep)
  EXTERNAL = { target: "_blank", rel: "noopener" }.freeze
  EXTERNAL_ATTRIBUTES = %(target="_blank" rel="noopener")

  def external?(url)
    host = URI.parse(url).host.to_s
    host.present? && host != "margate-electronics.org" && !host.end_with?(".margate-electronics.org")
  rescue URI::InvalidURIError
    false
  end

  # link_to for another site: the same, opening in a new tab
  def external_link_to(*args, **options, &block) = link_to(*args, **options, **EXTERNAL, &block)

  # Plain text (titles, captions) with the same line-breaking fix as copy.
  def words(text)
    keep_brackets_together(ERB::Util.html_escape(typography(text)).gsub(SLASH, "/<wbr>").html_safe)
  end

  # A slash between words may end a line, as a space can: browsers never
  # break at one, so "live-dubbing/rearranging/mix-and-matching" (its
  # hyphenated words kept whole) ran off a phone's screen
  SLASH = %r{(?<=[[:alnum:]])/(?=[[:alnum:]])}

  # House punctuation, whatever was typed: curly apostrophes and quotes, and
  # a spaced en dash for a spaced hyphen or an em dash (no em dashes on the
  # site). Plain text in, plain text out; the same again changes nothing.
  def typography(text)
    text.to_s.gsub(/&#39;|&apos;/, "'").gsub("&quot;", '"')
      .gsub(/\s*—\s*|\s+-\s+/, " – ")
      .gsub(/(\A|[\s(\[])"/, "\\1“").tr('"', "”")
      .gsub(/(\A|[\s(\[“])'/, "\\1‘").tr("'", "’")
  end

  # A word with a bracket in it, or letters and digits joined by hyphens
  # ("T-shirt"; not a whole web address, which must still be able to wrap)
  BRACKETED_WORD = /[^\s<>]*[(\[「『][^\s<>]*|[\p{L}\p{N}]+(?:-[\p{L}\p{N}]+)+/

  # Safari (and so every browser on iPhone) breaks lines just after an opening
  # bracket when Japanese precedes it: "こけのね (" / "ME004)"; Chrome breaks
  # after a hyphen: "T-" / "shirt". Wrapping each such word in a no-wrap span
  # keeps it whole, so the line breaks at the space instead, in every browser.
  def keep_brackets_together(html)
    fragment = Nokogiri::HTML5.fragment(html.to_s)
    fragment.traverse do |node|
      next unless node.text? && node.content.match?(BRACKETED_WORD)
      escaped = ERB::Util.html_escape(node.content)
      node.replace(Nokogiri::HTML5.fragment(escaped.gsub(BRACKETED_WORD) { |word| %(<span class="nowrap">#{word}</span>) }))
    end
    fragment.to_html.html_safe # rubocop:disable Rails/OutputSafety -- built from sanitized/escaped input
  end

  def tag_class(label)
    [ "tag", TAG_CLASSES[label] ].compact.join(" ")
  end

  # A Picture (see Illustrated). The file comes straight from R2, resized by
  # Cloudflare to the box's width (and twice that for sharp screens).
  # lightbox: true wraps it in a button that opens it full size.
  def media_image(picture, lightbox: false, data: {})
    if picture.placeholder?
      return tag.div("Image to come: #{picture.alt}", class: "media media--placeholder",
        style: "aspect-ratio: #{picture.ratio}", role: "img", aria: { label: picture.alt })
    end

    # With its dithered stand-in (Dither) as --dither, drawn while it loads (lib/dither)
    style = [ "aspect-ratio: #{picture.ratio}", ("--dither: url(#{picture.dither})" if picture.dither) ].compact.join("; ")
    img = image_tag(MediaUrls.image_url(picture.blob, width: picture.width),
      srcset: MediaUrls.image_srcset(picture.blob, width: picture.width), alt: picture.alt,
      class: [ "media", ("media--dithered" if picture.dither) ],
      width: picture.width, height: picture.height, style: style, loading: "lazy", data: data)
    return img unless lightbox

    full = lightbox_image(picture)
    tag.button(img, type: "button", class: "media-button", aria: { label: "Enlarge: #{picture.alt}" },
      data: { action: "dialog#openImage", dialog_src_param: full[:src], dialog_srcset_param: full[:srcset],
              dialog_width_param: full[:width], dialog_height_param: full[:height], dialog_dither_param: picture.dither,
              dialog_alt_param: picture.alt, dialog_caption_param: typography(picture.caption) })
  end

  # The lightbox's image: its address, a sharper version for sharp screens
  # (only when the original is big enough to give one), and the original's
  # width in pixels, which the lightbox never shows it beyond, so a photo is
  # never enlarged into blur; its height, so its dithered stand-in can show
  # at the photo's size while it loads
  def lightbox_image(picture)
    original = picture.blob.metadata["width"].to_i
    height = picture.blob.metadata["height"].to_i
    base = MediaUrls::LIGHTBOX_WIDTH
    widths = original > base ? [ base, base * 2 ] : [ base ]
    srcset = widths.map { |w| "#{MediaUrls.image_url(picture.blob, width: w)} #{original.positive? ? [ w, original ].min : w}w" }
    { src: MediaUrls.image_url(picture.blob, width: base), srcset: srcset.join(", "),
      width: original.positive? ? original : nil, height: height.positive? ? height : nil }
  end

  # Counts for the filter menu
  def filter_counts = feed.counts

  # A new line in editor text: a line break, or one paragraph ending and the
  # next beginning
  LINE_BREAK = %r{\s*(?:<br\s*/?>|</p>\s*<p[^>]*>)\s*}

  # Fields where each Enter in the editor is a new line, not a new paragraph
  # (headings, info, tile text): its paragraphs become lines. Older text
  # written with <br> comes out the same. A space follows each break: phones
  # hide the heading's breaks (detail.css) and the words need it between
  # them; at the start of a line it doesn't show.
  def lines(html) = copy(html.to_s.strip.delete_prefix("<p>").delete_suffix("</p>").gsub(LINE_BREAK, "<br> "))

  # A page heading as plain text, for the browser tab
  # (entities decoded, so "&amp;" isn't escaped twice in the browser tab).
  # Its lines are joined with " – " after a line ending in a capitalised word
  # ("Ambient Garden – Kodama…"), otherwise a space: after punctuation
  # ("#12: What Does…") or mid-phrase ("Waffle by Tomas")
  def heading_text(html)
    lines = html.to_s.split(LINE_BREAK).map { |line| CGI.unescapeHTML(strip_tags(line)).squish }.compact_blank
    return if lines.empty?
    typography(lines.drop(1).reduce(lines.first) { |text, line| text + (text.match?(/(?<!\S)\p{Lu}[^\s]*[^\s:;,.!?–-]\z/) ? " – " : " ") + line })
  end

  # The text under an event's poster: the title and lineup ("Live: …",
  # "DJ: …"); after a blank line the details in italic (venue; before the
  # night the date, time and ticket prices); then the description after another.
  # Lineup values are editor text, flattened to one line each, links and
  # White kept.
  def event_text(event, today = Date.current)
    lines = [ ERB::Util.html_escape(event.title) ] +
            event.lineup.map { |label, value| "#{label}: #{value.strip.delete_prefix("<p>").delete_suffix("</p>").gsub(LINE_BREAK, "<br> ")}" }
    details = event.details(today).map { |label, value| "#{label}: #{ERB::Util.html_escape(value)}" }
    details = details.any? ? "<p><em>#{details.join("<br>")}</em></p>" : ""
    copy("<p>#{lines.join("<br>")}</p>" + details + event.description.to_s)
  end

  SECTION_TAGS = { "Events" => "tag--event", "Releases" => "tag--release",
                   "Apparel" => "tag--apparel", "Prints" => "tag--print" }.freeze

  # A typed top line (the short centred line at the top of the page, where an
  # event's date goes), on pages without an automatic one. fallback: shown
  # when nothing is typed (the page's name on About, Stockists, the Index
  # and Newsletter, which have no section chip); none without either
  def top_line(html, fallback: nil)
    text = html.presence || (fallback && ERB::Util.html_escape(fallback))
    content_for :header_status, lines(text) if text.present?
  end

  # "Margate Electronics" then the section as a chip in its category colour
  def breadcrumb(section, path)
    safe_join([ link_to("Margate Electronics", root_path), " ",
                link_to(section, path, class: [ "tag", SECTION_TAGS[section], "breadcrumb__chip" ]) ])
  end
end
