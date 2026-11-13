# Splits items into columns the way the Figma layouts do: each item goes to
# whichever column is currently shortest. Heights are estimates in px from
# the item's image box and caption length, which is enough to pick a column.
class Masonry
  CHAR_WIDTH = 8.4   # IBM Plex Mono at 14px is 0.6em wide
  LINE_HEIGHT = 18.2 # 14px at line-height 1.3

  def self.split(items, columns: 2, &height)
    stacks = Array.new(columns) { { items: [], height: 0.0 } }
    items.each do |item|
      stack = stacks.min_by { |s| s[:height] }
      stack[:items] << item
      stack[:height] += height.call(item)
    end
    stacks.map { |s| s[:items] }
  end

  # Lines a caption wraps to in a column of the given width.
  def self.lines(html, width:)
    per_line = (width / CHAR_WIDTH).floor
    html.split(%r{<br\s*/?>|</p>}).reject { |line| strip_tags(line).strip.empty? }.sum { |line| [ (strip_tags(line).length.to_f / per_line).ceil, 1 ].max }
  end

  def self.strip_tags(html) = html.gsub(/<[^>]+>/, "")
end
