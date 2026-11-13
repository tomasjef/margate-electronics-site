# Stockists, one list edited in the admin (Tomas, 1 Oct): the /stockists/
# page, the line under a release's price, and the About page's link. Starts
# with the shops the About page listed by hand, and swaps that list for one
# sentence linking to the page (the paragraphs around it unchanged).
class CreateStockists < ActiveRecord::Migration[8.1]
  SHOPS = [
    [ "Margate", "Asobi Store", "https://asobi.co.uk" ],
    [ "Margate", "Ghost Papa Records", "https://www.discogs.com/seller/Ghost_Papa_Records/profile" ],
    [ "London", "Atlantis Records Hackney", "https://www.instagram.com/atlantis_records_hackney" ],
    [ "London", "Jelly Records", "https://jellyrecords.co.uk/" ],
    [ "Glasgow", "Monorail Music", "https://monorailmusic.com/" ],
    [ "Vilnius", "Empty Brain Resort", "https://emptybrainresalt.us/" ] # the domain is right as it is
  ].freeze

  SENTENCE = %(<p>Our tapes are also stocked in independent record shops. See <a href="/stockists/">stockists</a>.</p>)
  LIST = %r{<p>Margate: .*?Empty Brain Resort</a>(?:<br>\s*)*}m

  # The About text with its hand-written list (and the line breaks after it)
  # swapped for the sentence; what followed the list in its paragraph starts
  # a paragraph of its own. Nil when there's no list.
  def self.about_without_list(body)
    return unless body.to_s.match?(LIST)
    body.sub(" and also stocked in these physical shops:</p>", ".</p>").sub(LIST, "#{SENTENCE}<p>").gsub("<p></p>", "")
  end

  def up
    create_table :stockists do |t|
      t.string :city, null: false
      t.string :name, null: false
      t.string :url, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    SHOPS.each.with_index(1) do |(city, name, url), position|
      execute "INSERT INTO stockists (city, name, url, position, created_at, updated_at) VALUES " \
              "(#{quote(city)}, #{quote(name)}, #{quote(url)}, #{position}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    end

    select_rows("SELECT id, body FROM about_pages").each do |id, body|
      updated = self.class.about_without_list(body)
      next say("About: no hand-written shop list found, left as it is") unless updated
      execute "UPDATE about_pages SET body = #{quote(updated)}, updated_at = CURRENT_TIMESTAMP WHERE id = #{id}"
    end
  end

  def down
    drop_table :stockists
  end

  private

  def quote(value) = connection.quote(value)
end
