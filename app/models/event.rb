class Event < ApplicationRecord
  include Illustrated
  include Slugged
  include EditorText

  editor_text :heading, :description, :live, :dj, :screening, :workshop

  # The lineup lines under the poster, in this order, each only when filled in
  LINEUP = { live: "Live", dj: "DJ", screening: "Screening", workshop: "Workshop" }.freeze

  has_many :tracks, -> { order(:position, :id) }, as: :trackable, dependent: :destroy

  validates :title, :slug, :date, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :tile_ratio, inclusion: { in: Image::RATIOS.keys }, allow_blank: true

  scope :published, -> { where(published: true) }

  # Worked out when the site is built; the daily rebuild keeps it current.
  def upcoming?(today = Date.current) = date >= today

  def status = upcoming? ? "upcoming" : "archived"

  # The number in its title ("Margate Electronics #12: …" is "12")
  def number = title[/#(\d+)/, 1]

  # "M.E.#10", as on the posters (the player bar)
  def short_number = number && "M.E.##{number}"

  # "Margate Electronics #10", without the theme (the Archive); the whole
  # title when it has no number
  def series_title = number ? "Margate Electronics ##{number}" : title

  # Always automatic: "Upcoming – 9 Oct 2026" until the day, then "Archived –
  # 9 Oct 2026" (the daily rebuild switches it)
  def status_text(today = Date.current) = "#{upcoming?(today) ? "Upcoming" : "Archived"} – #{date.to_fs(:site)}"

  # [label, value] for each lineup line that's filled in (values are editor HTML)
  def lineup = LINEUP.filter_map { |field, label| [ label, public_send(field) ] if public_send(field).present? }

  # The practical details: the venue; before the night also the date, time
  # and ticket prices
  def details(today = Date.current)
    lines = [ [ "Venue", venue.presence ] ]
    lines += [ [ "Date", date_line ], [ "Time", time_line ], [ "Tickets", tickets.presence ] ] if upcoming?(today)
    lines.select(&:last)
  end

  # "Fri 9 Oct 2026"
  def date_line = "#{date.strftime("%a")} #{date.to_fs(:site)}"

  # "Doors 7PM / Music 8PM", or either alone
  def time_line = [ doors_at.presence && "Doors #{doors_at}", music_at.presence && "Music #{music_at}" ].compact.join(" / ").presence

  # Tickets can be bought: upcoming, with a ticket link, and not sold out
  def book_tickets?(today = Date.current) = upcoming?(today) && external_ticket_url.present? && !sold_out?
end
