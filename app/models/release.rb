class Release < ApplicationRecord
  include Illustrated
  include Priced
  include Slugged
  include EditorText

  editor_text :heading, :info, :description, :credits


  has_many :tracks, -> { order(:position, :id) }, as: :trackable, dependent: :destroy

  validates :artist, :title, :slug, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :tile_ratio, inclusion: { in: Image::RATIOS.keys }, allow_blank: true

  scope :published, -> { where(published: true) }

  # Before the release date it's a pre-order; worked out when the site is built.
  def status(today = Date.current)
    return "sold_out" if sold_out?
    release_date && release_date > today ? "pre_order" : "available"
  end

  # Always automatic: the catalogue number, and while it's a pre-order
  # "ME004 – Pre-order, out on 9 Oct 2026" (the daily rebuild switches it)
  def status_text(today = Date.current)
    pre_order = ("Pre-order, out on #{release_date.to_fs(:site)}" if status(today) == "pre_order")
    [ catalogue_number.presence, pre_order ].compact.join(" – ").presence
  end

  # The Buy button's words, from the link: "Pre-order on Bandcamp" until the
  # release date, then "Buy on Bandcamp" (the daily rebuild switches them);
  # for a link elsewhere just "Pre-order" / "Buy". With the tapes gone, the
  # digital album: "Buy Digital on Bandcamp".
  def button_label(today = Date.current)
    verb = status(today) == "pre_order" ? "Pre-order" : "Buy"
    shop_words(tape_sold_out? ? "#{verb} Digital" : verb)
  end

  # Bandcamp has no cassettes left (tape_stock, from Bandcamp); the digital
  # album is still for sale there. Not the same as sold_out (nothing at all).
  def tape_sold_out? = tape_stock == 0

  # How many tapes Bandcamp has left: "9 of 25 tapes remaining" (or "1 tape
  # remaining" without an edition size). Nothing at 0 or without a count.
  def tape_note
    return unless tape_stock&.positive? && !sold_out?
    return "#{tape_stock} of #{edition_size} tapes remaining" if edition_size
    "#{tape_stock} #{tape_stock == 1 ? "tape" : "tapes"} remaining"
  end

  SHOPS = { "bandcamp.com" => "Bandcamp" }.freeze

  def shop_words(verb)
    host = URI.parse(external_buy_url.to_s).host.to_s
    shop = SHOPS.find { |domain, _| host == domain || host.end_with?(".#{domain}") }&.last
    shop ? "#{verb} on #{shop}" : verb
  rescue URI::InvalidURIError
    verb
  end

  # The page's large heading: as typed, otherwise "Artist – Title" (HTML)
  def headline = heading.presence || ERB::Util.html_escape(plain_headline)

  def plain_headline = "#{artist} – #{title}"

  # The lines under the cover: "Artist – Title (ME004)" and "Cassette +
  # digital, edition of 25", written from the fields, then any lines typed
  # in Info. HTML, one paragraph with a <br> between lines.
  def info_html
    lines = automatic_info.map { |line| ERB::Util.html_escape(line) }
    typed = info.to_s.strip.delete_prefix("<p>").delete_suffix("</p>").gsub(ApplicationHelper::LINE_BREAK, "<br>")
    "<p>#{(lines + [ typed ]).compact_blank.join("<br>")}</p>"
  end

  def automatic_info
    number = " (#{catalogue_number})" if catalogue_number.present?
    edition = [ format.presence, ("edition of #{edition_size}" if edition_size) ].compact.join(", ").upcase_first
    [ "#{plain_headline}#{number}", edition ].compact_blank
  end

  # The credits as typed, ending with "© 2026 Margate Electronics" (the
  # release year), in the last paragraph's style
  def credits_html
    return credits.to_s unless release_date
    line = copyright
    return "<p><em>#{line}</em></p>" if credits.blank?
    typed = credits.strip
    typed.match?(%r{</p>\z}) ? typed.sub(%r{((?:</em>)?</p>)\z}) { "<br>#{line}#{$1}" } : "#{typed}<br>#{line}"
  end

  def copyright = "© #{release_date.year} Margate Electronics"

  # Where previews of its tracks are kept: previews/<this>/
  def folder = catalogue_number.presence || slug
end
