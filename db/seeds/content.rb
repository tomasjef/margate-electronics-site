require "vips"

# The launch content, moved from the design prototype (Figma copy and Tomas's
# notes). db/seeds.rb adds whichever items aren't there yet; the test database
# gets them as the pages' test data. After that, content is edited in the admin.
#
# Photos are uploaded to the storage service in use: R2 in development (the
# R2 keys must be in .env), a local folder in tests. Placeholders from the
# prototype (photos not exported yet, Figma's stand-in track titles) are left
# out rather than published.
module ContentSeeds
  IMAGES = Rails.root.join("app/assets/images/prototype")

  BANDCAMP = "https://margate-electronics.bandcamp.com"
  KOKE_NO_NE = "#{BANDCAMP}/album/koke-no-ne"
  # The live site links OutSavvy for ME#13 tickets
  TICKETS_ME13 = "https://www.outsavvy.com/event/39153/margate-electronics-13-ambient-garden"

  ABOUT_TEXT = "<p>Margate Electronics is an experimental electronic music event series &amp; label, based in Margate, UK.</p><p>Since September 2023 we have put on evenings of live experimental electronic music, sound and moving image, first at Faith in Strangers, then at Margate Arts Club, with a night at Cafe OTO in London.</p><p>The label releases limited edition cassettes and digital albums, some of them recorded live at our events.</p><p>Margate Electronics \#8 to \#12 were supported using public funding by Arts Council England.</p>"
  ABOUT_ARTISTS = "<p>A'Bear</p><p>Al Wootton</p><p>Ali Renault</p><p>ALM Busy Circuits</p><p>Ambross</p><p>Ben Sun</p><p>Cestrian</p><p>Chupacabras</p><p>Clementine Blue</p><p>Eva Papamargariti</p><p>Geoffrey Papin</p><p>Gilli.jpg</p><p>hellocatfood</p><p>Jonas Ransson</p><p>Jorja Chalmers</p><p>KMBN</p><p>Kodama こだま</p><p>Loula Yorke</p><p>M2C</p><p>Melinda Bronstein</p><p>Michael son of Michael</p><p>Microcorps</p><p>Missing Music</p><p>Mosaic Tapes</p><p>Nik Colk Void</p><p>Pond</p><p>Rhizocorp</p><p>Richard Pike</p><p>Sculpture</p><p>Sergio Serra</p><p>Smelliott</p><p>Soborgnost</p><p>Thomas Ridley</p><p>Timothy J. Fairplay</p><p>Tomas Jefanovas</p><p>Tythe</p><p>Will Materialise</p><p>Y Bülbül</p><p>YKLU &amp; Danny</p><p>Yuri Suzuki</p><p>Zoe A.</p>"

  module_function

  # Adds each item that isn't there yet (by its slug), so it's safe to run again
  # and leaves anything added or edited in the admin alone.
  def run
    ActiveRecord::Base.transaction do
      events
      releases
      products
      about
      stockists
      stockists_page
      index_page
      newsletter_page
    end
  end

  # The shops that stocked the tapes at launch (the admin edits them after)
  def stockists
    return if Stockist.exists?
    [
      [ "Margate", "Asobi Store", "https://asobi.co.uk" ],
      [ "Margate", "Ghost Papa Records", "https://www.discogs.com/seller/Ghost_Papa_Records/profile" ],
      [ "London", "Atlantis Records Hackney", "https://www.instagram.com/atlantis_records_hackney" ],
      [ "London", "Jelly Records", "https://jellyrecords.co.uk/" ],
      [ "Glasgow", "Monorail Music", "https://monorailmusic.com/" ],
      [ "Vilnius", "Empty Brain Resort", "https://emptybrainresalt.us/" ]
    ].each.with_index(1) { |(city, name, url), position| Stockist.create!(city:, name:, url:, position:) }
  end

  # The lines above and under the stockists list (the admin edits them after)
  # The Index and Newsletter pages' own text (the admin edits them after)
  def index_page
    IndexPage.create! unless IndexPage.exists?
  end

  def newsletter_page
    NewsletterPage.create! unless NewsletterPage.exists?
  end

  def stockists_page
    return if StockistsPage.exists?
    StockistsPage.create!(intro: "<p>Our tapes are stocked in these shops:</p>",
      outro: %(<p>Interested in stocking our releases? <a href="mailto:#{Links::EMAIL}">Get in touch</a>.</p>))
  end

  # The About page as it launched (the admin edits it from then on)
  def about
    return if AboutPage.exists?
    AboutPage.create!(
      heading: "<p>Margate Electronics</p>",
      body: ABOUT_TEXT,
      artists: ABOUT_ARTISTS
    )
  end

  # Runs the block only when no record of the model has this slug
  def missing?(model, slug) = !model.exists?(slug: slug)

  # file: a photo in app/assets/images/prototype
  def photo(record, file, alt:, placement: "gallery", caption: nil, colour: nil, display_ratio: nil)
    path = IMAGES.join(file)
    size = Vips::Image.new_from_file(path.to_s)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(path), filename: file, content_type: "image/jpeg",
      metadata: { "width" => size.width, "height" => size.height, "identified" => true, "analyzed" => true }
    )
    position = record.images.size + 1 # numbered from 1
    record.images.create!(file: blob, alt: alt, caption: caption, placement: placement, colour: colour,
                          display_ratio: display_ratio, position: position)
  end

  def events
    if missing?(Event, "me-13")
      me13 = Event.create!(
        title: "Margate Electronics #13: Ambient Garden", slug: "me-13", date: Date.new(2026, 10, 9),
        doors_at: "7PM", music_at: "8PM", venue: "Margate Arts Club, Margate, UK",
        tickets: "£8, £10 adv / £13 otd / £20 ticket+tape",
        live: %(<a href="#">Kodama こだま</a> (<a href="#">Akiharu Kitagawa</a> &amp; <a href="#">Clementine Blue</a>), Pond (<a href="#">Rosie Carr</a> &amp; <a href="#">Pedro Figueiredo</a>)),
        heading: "Margate Electronics #13: Ambient Garden <br>Kodama こだま (ME004) Tape Launch Party",
        external_ticket_url: TICKETS_ME13,
        description: <<~HTML,
          <p>An evening of experimental live music, themed around nature-inspired, slow-unfolding sound: drifting textures, field recordings and gentle drone, alongside the ethereal koto harp and analogue synthesisers, woven together in a space for listening.</p>
          <p>Launching Kodama's new release koke no ne こけのね - a limited edition tape and digital on Margate Electronics label. Buy the ticket+tape deal or pre-order on our <a href="#{KOKE_NO_NE}">Bandcamp</a></p>
        HTML
      )
      photo(me13, "me13-poster.jpg", alt: "Margate Electronics #13: Ambient Garden poster")
      photo(me13, "artist-kodama.jpg", alt: "Kodama こだま", caption: "Kodama こだま", placement: "scatter")
      photo(me13, "artist-pond.jpg", alt: "Pond", caption: "Pond", placement: "scatter")
    end

    if missing?(Event, "me-12")
      me12 = Event.create!(
        title: "Margate Electronics #12: What Does the Future Look Like?", slug: "me-12",
        date: Date.new(2026, 4, 24), venue: "Margate Arts Club, Margate, UK",
        live: %(<a href="#">hellocatfood</a> (AV), <a href="#">Rhizocorp</a>), screening: %(<a href="#">Eva Papamargariti</a>),
        heading: "Margate Electronics #12: <br>What Does the Future Look Like?",
        description: <<~HTML,
          <p>Three artists working with experimental processes such as live coding, video synthesis, live hardware sampling, tape manipulation, and 3D moving image.</p>
        HTML
      )
      photo(me12, "me12-poster.jpg", alt: "Margate Electronics #12 poster")
      photo(me12, "artist-hellocatfood.jpg", alt: "hellocatfood", caption: "hellocatfood", placement: "scatter")
      photo(me12, "artist-rhizocorp.jpg", alt: "Rhizocorp", caption: "Rhizocorp", placement: "scatter")
      photo(me12, "artist-eva-papamargariti.jpg", alt: "Eva Papamargariti", caption: "Eva Papamargariti", placement: "scatter")
      me12.tracks.create!(title: "hellocatfood", audio_path: "ME12_Hellocatfood_master_streaming.mp3", position: 1)
    end
  end

  def releases
    if missing?(Release, "me004")
      me004 = Release.create!(
        catalogue_number: "ME004", artist: "Kodama こだま", title: "koke no ne こけのね", slug: "me004",
        format: "Cassette + digital", edition_size: 25, price_pence: 1200, release_date: Date.new(2026, 10, 9),
        heading: "Kodama こだま · ME004 <br>koke no ne こけのね",
        external_buy_url: KOKE_NO_NE, tile_ratio: "4:3",
        description: <<~HTML,
          <p>Weaving together the ethereal sound of the Koto harp and the deep tone of analog synthesisers, Akiharu Kitagawa and Clementine Blue are exploring a cross-genre musical collaboration. Their semi-improvised performance is drawing inspiration from the nature in Japan and in the UK, inviting people to daydream and explore a new musical landscape.</p>
          <p>The music was created between Itoshima, Kyoto, Margate and Nottingham. The tracks take you on a gentle walk through an ambient garden, acknowledging humble plants and birds of daily life such as mugwort, mosses and magpies. The album title, translating as ‘moss sounds’ or ‘moss roots’ bows to the discreet, often unnoticed green carpet.</p>
          <p>Aki’s koto sound oscillates between the playful, celestial harmonies of his usual 13 string koto (Two For Joy), and the calming earthy lower range of a 17 string koto (Kokedera).</p>
          <p>Floating between Japan and Europe, the field recordings from different places slowly build their own imaginary world, with sounds sampled from the moss temple of Kyoto, birds in Tokyo, leaves crushing near a Swiss lake. Koke no ne is your reminder to spend time outside and notice the little plants growing between the cracks and the birds rustling in your back garden.</p>
        HTML
        credits: <<~HTML,
          <p><em>Akiharu Kitagawa: koto<br>Clementine Blue: synthesisers<br>Recorded and produced by Clementine Blue<br>01 &amp; 03 comp. Clementine Blue<br>02 comp. Akiharu Kitagawa</em></p>
          <p><em>Mastering: Nicholas de Carlo<br>Artwork: Josef Ball<br>Graphic design: Tomas Jefanovas</em></p>
        HTML
      )
      photo(me004, "me004-tile.jpg", alt: "Kodama こだま – koke no ne こけのね cassette")
    end

    if missing?(Release, "me003")
      me003 = Release.create!(
        catalogue_number: "ME003", artist: "Tomas Jefanovas", title: "(Ne)Žmogus", slug: "me003",
        format: "Cassette + digital", edition_size: 25, price_pence: 1200, release_date: Date.new(2026, 8, 10),
        heading: "Tomas Jefanovas · ME003 <br>(Ne)Žmogus",
        info: "Recorded at M.E.#11, Cafe OTO, 2026",
        external_buy_url: "#{BANDCAMP}/album/ne-mogus",
        description: <<~HTML,
          <p>Recorded live at Margate Electronics #11, Feb 2026.</p>
          <p>Tomas Jefanovas is a Lithuanian media artist based in Margate, UK. His practice explores experimental electronic sound and visual processing, building live audio-visual sets around minimal structures, rhythms and noise-driven textures.</p>
          <p>This is a recording of a live improvised performance using a minimal setup: Waldorf Microwave XT synthesiser as the sole sound source, Octatrack as step sequencer and mixer, and two effects units, Jomox T-Resonator MkII for delay and Eventide Space for reverb. A slowly unravelling opening set.</p>
          <p>The title (Ne)Žmogus [(In)Human] is Lithuanian and reads both ways, Human and Inhuman.</p>
        HTML
        credits: <<~HTML,
          <p><em>Written and performed by Tomas Jefanovas<br>Recorded at Cafe OTO, London<br>Mastering: Brassica<br>Graphic design: Tomas Jefanovas</em></p>
        HTML
      )
      photo(me003, "me003-tile-green.jpg", alt: "Tomas Jefanovas – (Ne)Žmogus cassette", display_ratio: "3:4")
    end
  end

  def products
    if missing?(Product, "t-shirt")
      tshirt = Product.create!(
        kind: "apparel", title: "Margate Electronics T-shirt", slug: "t-shirt", heading: "Margate Electronics T-shirt",
        price_pence: 3000,
      )
      tshirt.colours.create!(name: "Natural", position: 1, buy_url: "#{BANDCAMP}/merch/m-e-t-shirt",
        info: "Margate Electronics T-shirt<br>Screen-printed on a heavyweight 215gsm organic cotton T-shirt.<br>Fabric: natural raw<br>Print: blue")
      tshirt.colours.create!(name: "Black", position: 2, buy_url: "#{BANDCAMP}/merch/m-e-t-shirt-2",
        info: "Margate Electronics T-shirt<br>Screen-printed on a heavyweight 215gsm organic cotton T-shirt.<br>Fabric: black<br>Print: white")
      # Stock as Tomas gave it (25 Sep): one XL left in each colour
      %w[XL L M S].each_with_index do |size, i|
        %w[Natural Black].each do |colour|
          tshirt.variants.create!(size: size, colour: colour, stock: size == "XL" ? 1 : 0, position: i)
        end
      end
      photo(tshirt, "tshirt-tile.jpg", alt: "Margate Electronics T-shirt, natural", colour: "Natural", display_ratio: "4:5")
    end

    if missing?(Product, "waffle")
      waffle = Product.create!(
        kind: "print", title: "Waffle", slug: "waffle", heading: "<em>Waffle</em> by Tomas Jefanovas", price_pence: 2000,
        info: "A3 - 4x colour riso print, unframed<br>Signed and numbered by the artist<br>Printed on 240gsm Munken paper",
      )
      photo(waffle, "print-waffle.jpg", alt: "Waffle riso print")
    end
  end
end
