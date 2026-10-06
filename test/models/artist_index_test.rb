require "test_helper"

# The Archive's artist index: the About page's names, found in lineups and
# release artists
class ArtistIndexTest < ActiveSupport::TestCase
  def appearances(name, **records)
    ArtistIndex.new(names: [ name ], **records).entries.first.appearances
  end

  test "a name is found in the lineups, links and brackets ignored, and in release artists" do
    assert_equal [ Event.find_by!(slug: "me-13"), Release.find_by!(slug: "me004") ], appearances("Kodama こだま")
    assert_equal [ Event.find_by!(slug: "me-13") ], appearances("Clementine Blue")
    assert_equal [ Event.find_by!(slug: "me-12") ], appearances("Eva Papamargariti") # the Screening line
  end

  test "whole words only, ignoring case" do
    event = Event.new(title: "Margate Electronics #3", slug: "me-3", date: Date.new(2023, 11, 23),
                      live: "<p>Ben Sun, Gilli, Chupacabras &amp; Yuri Suzuki</p>")
    assert_equal [ event ], appearances("chupacabras", events: [ event ], releases: [])
    assert_equal [ event ], appearances("Yuri Suzuki", events: [ event ], releases: [])
    assert_empty appearances("Gil", events: [ event ], releases: [])
    assert_empty appearances("Sun Ra", events: [ event ], releases: [])
  end

  test "a name found nowhere is still listed, with no appearances" do
    entry = ArtistIndex.new(names: [ "Nobody Here" ]).entries.first
    assert_equal "Nobody Here", entry.name
    assert_empty entry.appearances
  end

  test "events have a series title, Margate Electronics and the number, without the theme" do
    assert_equal "12", Event.find_by!(slug: "me-12").number
    assert_equal "Margate Electronics #7", Event.new(title: "Margate Electronics #7").series_title
    assert_equal "Margate Electronics #13", Event.find_by!(slug: "me-13").series_title
    assert_equal "Launch Party", Event.new(title: "Launch Party").series_title
    assert_equal "M.E.#13", Event.find_by!(slug: "me-13").short_number
  end
end
