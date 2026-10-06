# Stock for a product with size and colour variants: what is in stock, what
# is sold out, and when to say how many are left. Phase 1 only reads it (Buy
# links out); phase 2's checkout will take stock off here.
class Inventory
  LOW_STOCK = 3 # show "N remaining" at or below this

  attr_reader :sizes, :colours

  # stock: { ["XL", "Natural"] => 1, ... }; missing combinations count as 0
  def initialize(sizes:, colours:, stock:)
    @sizes = sizes
    @colours = colours
    @stock = stock
  end

  def count(size, colour) = @stock.fetch([ size, colour ], 0)

  def colour_available?(colour) = sizes.any? { |size| count(size, colour).positive? }

  # Nothing left in any size or colour
  def sold_out? = colours.none? { |colour| colour_available?(colour) }

  def sold_out_sizes(colour) = sizes.reject { |size| count(size, colour).positive? }

  # The first colour with anything left, and its first size in stock
  def default_choice
    colour = colours.find { |c| colour_available?(c) } || colours.first
    size = sizes.find { |s| count(s, colour).positive? } || sizes.first
    [ size, colour ]
  end

  def remaining_note(size, colour)
    left = count(size, colour)
    "#{left} remaining in #{size} #{colour}" if left.between?(1, LOW_STOCK)
  end

  def sold_out_note(colour)
    sold_out = sold_out_sizes(colour)
    return if sold_out.empty?
    colour_available?(colour) ? "Sold out: #{sold_out.join(", ")}" : "#{colour}: sold out"
  end

  # For the page script: { "XL|Natural" => 1, ... }
  def to_h = sizes.product(colours).to_h { |s, c| [ "#{s}|#{c}", count(s, c) ] }
end
