# The Archive page's artist index: the About page's list of artists (curated
# by Tomas, one name per line), each with the events whose lineup names them
# and the releases that are theirs. A name is found as a whole word, ignoring
# case and the lineup's links ("Clementine Blue" is in ME#3's Live line and
# in ME#13's, inside the brackets after Kodama).
class ArtistIndex
  Entry = Data.define(:name, :appearances)

  def initialize(names: AboutPage.current.artist_names,
                 events: Event.published.order(:date).to_a,
                 releases: Release.published.order(:release_date).to_a)
    @names = names
    @events = events.map { |event| [ event, plain(event.lineup.map(&:last).join(" ")) ] }
    @releases = releases
  end

  def entries
    @names.map do |name|
      pattern = /(?<![\p{L}\p{N}])#{Regexp.escape(name)}(?![\p{L}\p{N}])/i
      Entry.new(name: name, appearances: @events.filter_map { |event, text| event if text.match?(pattern) } +
                                         @releases.select { |release| release.artist.to_s.match?(pattern) })
    end
  end

  private

  def plain(html) = Nokogiri::HTML5.fragment(html).text.squish
end
