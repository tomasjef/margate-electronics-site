require "test_helper"

# Stock from Bandcamp, with Bandcamp's answer faked: items shaped like the
# real ones (1 Oct 2026), the T-shirt's colours named by emoji
class BandcampStockTest < ActiveSupport::TestCase
  FakeApi = Struct.new(:items) do
    def merch = items
  end

  def tshirt = Product.find_by!(slug: "t-shirt")

  def merch(natural:, black:, me004:)
    [
      { "package_id" => 470822677, "title" => "Limited Edition Cassette", "album_title" => "koke no ne こけのね", "quantity_available" => me004 },
      { "package_id" => 1835340623, "title" => "M.E. T-shirt ⚪️🔵", "album_title" => "", "options" => natural.map { |size, left| { "title" => size, "quantity_available" => left } } },
      { "package_id" => 763565684, "title" => "M.E. T-shirt ⚫️⚪️", "album_title" => "", "options" => black.map { |size, left| { "title" => size, "quantity_available" => left } } },
      { "package_id" => 1, "title" => "Tote bag", "album_title" => "" }
    ]
  end

  setup do
    tshirt.colours.find_by!(name: "Natural").update!(bandcamp_package_id: 1835340623)
    tshirt.colours.find_by!(name: "Black").update!(bandcamp_package_id: 763565684)
  end

  test "sizes take their colour's Bandcamp stock; a cassette its release's; the rest is reported" do
    result = BandcampStock.new(api: FakeApi.new(merch(natural: { "XL" => 2, "L" => 0 }, black: { "XL" => 0, "S" => 5 }, me004: 19))).call
    stock = ->(size, colour) { tshirt.variants.find_by!(size:, colour:).stock }
    assert_equal 2, stock.("XL", "Natural")
    assert_equal 0, stock.("L", "Natural")
    assert_equal 0, stock.("XL", "Black")
    assert_equal 5, stock.("S", "Black")
    assert_equal 19, Release.find_by!(slug: "me004").tape_stock
    assert_includes result.unmatched, "Tote bag"
    assert result.changes.any? { |c| c.start_with?("ME004 tapes") }

    again = BandcampStock.new(api: FakeApi.new(merch(natural: { "XL" => 2, "L" => 0 }, black: { "XL" => 0, "S" => 5 }, me004: 19))).call
    assert_empty again.changes, "nothing changes the second time"
  end

  test "Bandcamp out of reach, or no keys: it says so and keeps the stock last saved" do
    failing = Class.new { def merch = raise(BandcampApi::Error, "Bandcamp couldn't be reached (SocketError)") }
    stock = tshirt.variants.find_by!(size: "XL", colour: "Natural").stock
    assert_equal [ "Bandcamp stock: Bandcamp couldn't be reached (SocketError); keeping the stock last saved" ],
                 BandcampStock.report(api: failing.new, configured: true)
    assert_equal stock, tshirt.variants.find_by!(size: "XL", colour: "Natural").stock
    assert_match(/skipped, no keys/, BandcampStock.report(api: failing.new, configured: false).first)
  end

  test "tapes gone: Tape Sold Out and the digital album; Sold Out still means everything" do
    release = Release.find_by!(slug: "me003")
    assert_not release.tape_sold_out?, "no Bandcamp count yet: nothing changes"
    release.update!(tape_stock: 0)
    assert release.tape_sold_out?
    assert_equal "Buy Digital on Bandcamp", release.button_label(Date.new(2026, 10, 1))
    item = Feed.new(today: Date.new(2026, 10, 1)).items.find { |i| i.path == "/releases/me003/" }
    assert_equal "Tape Sold Out", item.label
    release.update!(sold_out: true)
    assert_equal "Sold Out", Feed.new(today: Date.new(2026, 10, 1)).items.find { |i| i.path == "/releases/me003/" }.label
  end
end
