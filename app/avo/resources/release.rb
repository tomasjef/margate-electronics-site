class Avo::Resources::Release < Avo::BaseResource
  # The admin's links use the slug (Slugged#to_param); bulk actions pass several
  self.find_record_method = -> { id.is_a?(Array) ? query.where(slug: id).or(query.where(id: id)) : query.find_by_param!(id) }
  self.title = :title
  self.icon = "tabler/outline/disc"
  self.includes = [ images: { file_attachment: :blob } ]
  self.default_sort_column = :release_date
  self.search = {
    query: -> { query.where("title LIKE ? OR artist LIKE ? OR catalogue_number LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id, only_on: :index

    # Photos, then the audio (also on Edit)
    field :images, as: :has_many, show_on: :edit
    field :tracks, as: :has_many, name: "Audio", show_on: :edit

    # The release
    field :published, as: :boolean, help: "Off keeps it off the site."
    field :catalogue_number, as: :text, help: "e.g. ME004. The page's status line shows it (and 'Pre-order, out on …' before the release date); preview clips are filed under it."
    field :artist, as: :text, required: true
    field :title, as: :text, required: true
    field :slug, as: :text, required: true, help: "The page address: me004 makes /releases/me004/."
    field :format, as: :text, hide_on: :index, help: "e.g. Cassette + digital. With the edition size, the second line under the cover: 'Cassette + digital, edition of 25'."
    field :edition_size, as: :number, hide_on: :index
    field :price_pounds, as: :number, step: 0.01, min: 0, name: "Price (£)", hide_on: :index, help: "In pounds, e.g. 12 or 12.50. Empty shows no price."
    field :release_date, as: :date, format: "dd.LL.yyyy", picker_format: "d.m.Y", help: "A pre-order until this day. Empty: out already."
    field :tape_stock, as: :number, name: "Tapes left (from Bandcamp)", hide_on: :forms,
      help: "Read from Bandcamp on each publish and daily. At 0 the page says Tape Sold Out and offers the digital album."
    field :sold_out, as: :boolean, help: "Everything gone, digital too: Sold Out instead of the button. (Tapes alone sold out come from Bandcamp.)"
    field :external_buy_url, as: :text, hide_on: :index, help: "Bandcamp link. The button says 'Pre-order on Bandcamp' until the release date, then 'Buy on Bandcamp' (for another shop: 'Pre-order' / 'Buy')."

    # Text
    field :heading, as: :tiptap,
      help: "The large heading at the top of the page. Leave empty for 'Artist – Title'; type one only to say something different. Enter starts a new line. Select text for italic or White."
    field :info, as: :tiptap, name: "More info lines",
      help: "The first two lines under the cover are written for you: 'Artist – Title (ME004)' and 'Cassette + digital, edition of 25'. Add any more here, e.g. 'Recorded at M.E.#11, Cafe OTO, 2026'. Enter starts a new line."
    field :description, as: :tiptap, help: "Enter starts a new paragraph, Shift+Enter a new line in the same one. Select text for italic or White."
    field :credits, as: :tiptap, help: "'© 2026 Margate Electronics' (the release year) is added at the end for you. Enter starts a new paragraph, Shift+Enter a new line in the same one. Select text for italic or White."

    # The home page tile
    field :show_tile_text, as: :boolean, name: "Text on the home tile", hide_on: :index,
      help: "Show the text under the tile's photo: the info lines, and 'Out on …' while it's a pre-order."
    field :tile_ratio, as: :select, options: Avo::Resources::Image::SHAPES, include_blank: "The photo's own shape",
      hide_on: :index, help: "Crop of the photo on the home tile."
    field :home_position, as: :number, name: "Home position", hide_on: :index,
      help: "Optional. Pins it to the top of the home page: 1 first, then 2 and so on. Leave empty to follow the date order."

    # The scattered photos
    field :reshuffle, as: :number, name: "Reshuffle photos", hide_on: :index, min: 0,
      help: "The arrangement of the scattered photos on wide screens. Change the number (1, 2, 3…) for a new one; 0 is the original."
  end
end
