require "zlib"

# Horizontal scatter for event photos on wide screens. The photos keep their
# two stacked columns (same vertical rhythm as smaller screens); each one is
# moved to a grid position across the 8-column width. A photo (200 wide) spans
# a little under two grid columns, so it can start at positions 0 to 6: the
# left column's photos take 0 to 3, the right column's 3 to 6, and 3 is the
# middle, across the centre. Varied but stable: the same seed (the event slug)
# gives the same layout, a photo never sits in the same position as the one
# just above it on the page (in either column) or in its own column, and
# photos level with each other stay two positions apart, so they never touch.
#
# Returns each photo's place: its shift within its own column (the CSS's
# --shift: the left column counts from the left edge, the right from the
# centre, so the right column's middle position is -1), and its drop, extra
# space above it in section gaps (--drop). The drops keep photos of the same
# size from lining up in rows: each gets 0 to 3, except the first on the
# left (0), and the right column starts 3 to 5 lower than the left.
class Scatter
  LEFT = [ 0, 1, 2, 3 ].freeze
  RIGHT = [ 3, 4, 5, 6 ].freeze
  RIGHT_START = 4 # the right column's first position, from the left edge
  APART = 2       # positions between photos level with each other

  # Heights on the page are estimated, to know which photos are level
  CAPTION_GAP = 10    # --gap-group
  ROW_GAP = 40        # --gap-section
  CAPTION_CHARS = 30  # 11px Plex Mono (6.6 wide) in 200
  CAPTION_LINE = 14.3 # 11px at line-height 1.3
  MARGIN = 40         # estimates drift down a long column: near misses count as level

  DROPS = (0..3).freeze       # extra section gaps above a photo
  RIGHT_START_DROP = (3..5).freeze

  Place = Data.define(:shift, :drop)

  # height: a photo's estimated height on the page (pictures by default)
  def self.places(columns, seed:, &height)
    height ||= method(:height)
    drops = drops(columns, seed)
    shifts = shifts(columns.map { |column| extents(column, height, drops) }, seed)
    shifts.to_h { |photo, shift| [ photo, Place.new(shift: shift, drop: drops[photo]) ] }
  end

  # Their own random numbers, so the drops don't change the across positions
  def self.drops(columns, seed)
    random = Random.new(Zlib.crc32("#{seed} drops"))
    columns.each_with_index.each_with_object({}) do |(column, side), drops|
      column.each_with_index do |photo, i|
        range = if i.positive? then DROPS
        elsif side == 1 then RIGHT_START_DROP
        else 0..0 # the first photo on the left starts the section
        end
        drops[photo] = range.to_a.sample(random: random)
      end
    end
  end

  def self.shifts((left, right), seed)
    random = Random.new(Zlib.crc32(seed.to_s))
    # Top to bottom down the page, both columns together
    photos = left.map { |photo, rows| [ photo, rows, LEFT, 0 ] } + right.map { |photo, rows| [ photo, rows, RIGHT, RIGHT_START ] }
    placed = []       # [position, rows], down the page
    column_above = {} # the last position in each column
    shifts = {}
    photos.sort_by.with_index { |(_, rows), i| [ rows.begin, i ] }.each do |photo, rows, positions, start|
      level = placed.select { |_, other| rows.begin < other.end + MARGIN && other.begin < rows.end + MARGIN }.map(&:first)
      # Not where the photo just above it on the page sits, nor the one above
      # it in its column, and never touching a photo level with it. There's
      # always a choice: the other column never reaches a column's far two
      # positions, and the photos above can take only one of them.
      choices = positions.reject { |p| p == placed.last&.first || p == column_above[start] || level.any? { |other| (other - p).abs < APART } }
      choice = choices.sample(random: random)
      shifts[photo] = choice - start
      placed << [ choice, rows ]
      column_above[start] = choice
    end
    shifts
  end

  # Each photo with the rows it covers, top to bottom
  def self.extents(column, height, drops = {})
    top = 0.0
    column.map do |photo|
      top += ROW_GAP * drops.fetch(photo, 0)
      bottom = top + height.call(photo)
      [ photo, (top...bottom) ].tap { top = bottom + ROW_GAP }
    end
  end

  def self.height(picture)
    caption = picture.caption.to_s.gsub(/<[^>]+>/, "")
    lines = caption.split("\n").sum { |line| (line.length.to_f / CAPTION_CHARS).ceil }
    picture.height + (lines.zero? ? 0 : CAPTION_GAP + lines * CAPTION_LINE)
  end
end
