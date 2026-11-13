require "test_helper"

# Link previews (WhatsApp, iMessage, social) and search descriptions
class SocialMetaTest < ActionDispatch::IntegrationTest
  def meta(property) = css_select("meta[property='#{property}'], meta[name='#{property}']").first&.[]("content")

  test "the ME#13 page previews with its heading, opening line and poster" do
    get "/events/me-13/"
    assert_equal "Margate Electronics #13: Ambient Garden – Kodama こだま (ME004) Tape Launch Party", meta("og:title")
    assert_match(/\AAn evening of experimental live music, themed around nature-inspired/, meta("og:description"))
    assert_operator meta("og:description").length, :<=, 201
    assert_equal meta("og:description"), meta("description")
    assert_match %r{\Ahttps://media\.margate-electronics\.org/cdn-cgi/image/width=1200,height=630,fit=cover,gravity=top,format=jpeg,quality=85/\w+\z},
                 meta("og:image")
    assert_equal "Margate Electronics #13: Ambient Garden poster", meta("og:image:alt")
    assert_equal "http://www.example.com/events/me-13/", meta("og:url")
    assert_select "link[rel=canonical][href='http://www.example.com/events/me-13/']"
    assert_equal "summary_large_image", meta("twitter:card")
  end

  test "the home page previews with the site line and the next event's poster" do
    travel_to Date.new(2026, 9, 28) do
      get "/"
      assert_equal "Margate Electronics", meta("og:title")
      assert_equal "Margate Electronics is an experimental electronic music event series & label, based in Margate, UK.", meta("og:description")
      poster = Event.find_by!(slug: "me-13").main_image.file.blob.key
      assert_includes meta("og:image"), poster
    end
  end

  test "a release previews with its own text, a product with its details" do
    get "/releases/me004/"
    assert_match(/\AWeaving together the ethereal sound/, meta("og:description"))
    get "/prints/waffle/"
    assert_equal "A3 – 4x colour riso print, unframed · Signed and numbered by the artist · Printed on 240gsm Munken paper", meta("og:description")
  end

  test "a page without a photo of its own shares the next event's poster" do
    travel_to Date.new(2026, 9, 28) do
      get "/about/"
      assert_equal "About Margate Electronics", meta("og:title")
      assert_includes meta("og:image"), Event.find_by!(slug: "me-13").main_image.file.key
      assert_equal "summary_large_image", meta("twitter:card")
      %w[/newsletter/ /404].each { |path| get path; assert meta("og:image"), path }
    end
  end
end
