require "test_helper"

class StockistsTest < ActionDispatch::IntegrationTest
  test "the stockists page: cities in order, each shop a well-formed link" do
    get "/stockists/"
    assert_response :success
    assert_select "dl.stockists dt", 4
    assert_equal %w[Margate London Glasgow Vilnius], css_select("dl.stockists dt").map { |dt| dt.text.strip }
    links = css_select("dl.stockists dd a")
    assert_equal 6, links.size
    links.each do |a|
      assert_match %r{\Ahttps://[^\s"]+\z}, a["href"]
      assert_equal "_blank", a["target"]
      assert_includes a["rel"], "noopener"
    end
    assert_select "dd a[href='https://emptybrainresalt.us/']", text: "Empty Brain Resort"
    assert_select "dd a[href='https://www.discogs.com/seller/Ghost_Papa_Records/profile']", text: "Ghost Papa Records"
    assert_select ".breadcrumb__chip", 0
    assert_select ".site-header__status", text: "Stockists"
    assert_select "a.back-link", 0, "not a section page: no Back"
  end

  test "shops follow their positions; a city follows its first shop" do
    Stockist.find_by!(name: "Monorail Music").update!(position: 0)
    assert_equal %w[Glasgow Margate London Vilnius], Stockist.by_city.keys
    assert_not Stockist.new(city: "X", name: "Y", url: "monorailmusic.com").valid?, "a full web address"
  end

  test "the lines above and under the list come from the admin, and can be left out" do
    get "/stockists/"
    assert_select ".stockists__intro + dl.stockists", 1
    assert_select ".stockists__intro p", text: "Our tapes are stocked in these shops:"
    assert_select "dl.stockists + .stockists__outro p", text: "Interested in stocking our releases? Get in touch."
    assert_select ".stockists__outro a[href='mailto:#{Links::EMAIL}']", text: "Get in touch"

    StockistsPage.current.update!(intro: "<p></p>", outro: "<p></p>")
    assert_nil StockistsPage.current.intro, "a cleared editor stores nothing"
    get "/stockists/"
    assert_select ".stockists__intro", 0
    assert_select ".stockists__outro", 0
    assert_select "dl.stockists dt", 4
    assert_not StockistsPage.new(intro: "<p>Another</p>").valid?, "there is one Stockists page"
  end

  test "the admin's Stockists page opens the one record for editing" do
    sign_in_as users(:one)
    page = StockistsPage.current
    get "/admin/resources/stockists_pages"
    assert_redirected_to "/admin/resources/stockists_pages/#{page.id}/edit"
    get "/admin/resources/stockists_pages/new"
    assert_redirected_to "/admin/resources/stockists_pages/#{page.id}/edit"
    get "/admin/resources/stockists_pages/#{page.id}/edit"
    assert_response :success
  end

  test "the admin lists and edits stockists" do
    sign_in_as users(:one)
    get "/admin/resources/stockists"
    assert_response :success
    get "/admin/resources/stockists/#{Stockist.first.id}/edit"
    assert_response :success
  end

  test "the migration swaps About's hand-written list for one sentence, keeping the rest" do
    require Rails.root.join("db/migrate/20261001150000_create_stockists")
    body = %(<p>Intro.</p><p>The label releases tapes. Available on our <a href="https://x.bandcamp.com/">Bandcamp</a> and also stocked in these physical shops:</p>) +
           %(<p>Margate: <a href="https://asobi.co.uk">Asobi Store</a><br>Vilnius: <a href="https://emptybrainresalt.us/">Empty Brain Resort</a><br><br>From May 2025 to July 2026, supported.</p>)
    assert_equal %(<p>Intro.</p><p>The label releases tapes. Available on our <a href="https://x.bandcamp.com/">Bandcamp</a>.</p>) +
                 %(<p>Our tapes are also stocked in independent record shops. See <a href="/stockists/">stockists</a>.</p>) +
                 %(<p>From May 2025 to July 2026, supported.</p>), CreateStockists.about_without_list(body)
    assert_nil CreateStockists.about_without_list("<p>No list here.</p>")
  end

  test "a release on sale points to the stockists, under the tapes-remaining line" do
    travel_to Date.new(2026, 10, 1) do
      Release.find_by!(slug: "me003").update!(tape_stock: 9)
      get "/releases/me003"
      assert_select ".stock-notes .stock-note:first-child", text: "9 of 25 tapes remaining"
      assert_select ".stock-notes .stockist-line", text: "Also in select record shops: see stockists"
      assert_select ".stockist-line a[href='/stockists/']:not([target])", text: "stockists"
      assert_select ".price-row a.button", 1, "Bandcamp stays the one button"
    end
  end

  test "no stockists line before the release date (ME004's pre-order); it appears once out" do
    travel_to Date.new(2026, 10, 1) do
      get "/releases/me004"
      assert_select ".stockist-line", 0
    end
    travel_to Date.new(2026, 10, 9) do
      get "/releases/me004"
      assert_select ".stockist-line", text: /Also in select record shops/
    end
  end

  test "tapes gone on Bandcamp, or sold out: the line says so and still points to the shops" do
    travel_to Date.new(2026, 10, 1) do
      Release.find_by!(slug: "me003").update!(tape_stock: 0)
      get "/releases/me003"
      assert_select ".stockist-line", text: "Sold out on Bandcamp. A few copies may still be in shops, see stockists."
      Release.find_by!(slug: "me003").update!(tape_stock: 5, sold_out: true)
      get "/releases/me003"
      assert_select ".stockist-line", text: /\ASold out on Bandcamp/
    end
  end

  test "the Index and Newsletter pages are one record each, opened for editing" do
    sign_in_as users(:one)
    { "index_pages" => IndexPage, "newsletter_pages" => NewsletterPage }.each do |path, model|
      page = model.current
      get "/admin/resources/#{path}"
      assert_redirected_to "/admin/resources/#{path}/#{page.id}/edit"
      get "/admin/resources/#{path}/new"
      assert_redirected_to "/admin/resources/#{path}/#{page.id}/edit"
      assert_not model.new.valid?, "there is one #{model.name}"
    end
  end
end
