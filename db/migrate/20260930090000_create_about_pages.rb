# The About page moves into the admin (Tomas, 30 Sep): its text and the
# artists list, one record, starting with what the page said in the code.
class CreateAboutPages < ActiveRecord::Migration[8.1]
  TEXT = "<p>Margate Electronics is an experimental electronic music event series &amp; label, based in Margate, UK.</p><p>Since September 2023 we have put on evenings of live experimental electronic music, sound and moving image, first at Faith in Strangers, then at Margate Arts Club, with a night at Cafe OTO in London.</p><p>The label releases limited edition cassettes and digital albums, some of them recorded live at our events.</p><p>Margate Electronics \#8 to \#12 were supported using public funding by Arts Council England.</p>"
  ARTISTS = "<p>A'Bear</p><p>Al Wootton</p><p>Ali Renault</p><p>ALM Busy Circuits</p><p>Ambross</p><p>Ben Sun</p><p>Cestrian</p><p>Chupacabras</p><p>Clementine Blue</p><p>Eva Papamargariti</p><p>Geoffrey Papin</p><p>Gilli.jpg</p><p>hellocatfood</p><p>Jonas Ransson</p><p>Jorja Chalmers</p><p>KMBN</p><p>Kodama こだま</p><p>Loula Yorke</p><p>M2C</p><p>Melinda Bronstein</p><p>Michael son of Michael</p><p>Microcorps</p><p>Missing Music</p><p>Mosaic Tapes</p><p>Nik Colk Void</p><p>Pond</p><p>Rhizocorp</p><p>Richard Pike</p><p>Sculpture</p><p>Sergio Serra</p><p>Smelliott</p><p>Soborgnost</p><p>Thomas Ridley</p><p>Timothy J. Fairplay</p><p>Tomas Jefanovas</p><p>Tythe</p><p>Will Materialise</p><p>Y Bülbül</p><p>YKLU &amp; Danny</p><p>Yuri Suzuki</p><p>Zoe A.</p>"

  def up
    create_table :about_pages do |t|
      t.text :body
      t.text :artists
      t.timestamps
    end
    execute "INSERT INTO about_pages (body, artists, created_at, updated_at) VALUES (#{connection.quote(TEXT)}, #{connection.quote(ARTISTS)}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
  end

  def down
    drop_table :about_pages
  end
end
