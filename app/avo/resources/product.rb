class Avo::Resources::Product < Avo::BaseResource
  # The admin's links use the slug (Slugged#to_param); bulk actions pass several
  self.find_record_method = -> { id.is_a?(Array) ? query.where(slug: id).or(query.where(id: id)) : query.find_by_param!(id) }
  self.title = :title
  self.icon = "tabler/outline/shirt"
  self.includes = [ images: { file_attachment: :blob } ]
  self.search = {
    query: -> { query.where("title LIKE ? OR slug LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id, only_on: :index

    # Photos, then colours and sizes (also on Edit)
    field :images, as: :has_many, show_on: :edit
    field :colours, as: :has_many, show_on: :edit
    field :variants, as: :has_many, name: "Sizes and stock", show_on: :edit

    # The product
    field :published, as: :boolean, help: "Off keeps it off the site."
    field :kind, as: :select, options: { "Apparel" => "apparel", "Print" => "print" }, required: true
    field :title, as: :text, required: true
    field :slug, as: :text, required: true, help: "The page address: t-shirt makes /apparel/t-shirt/."
    field :price_pounds, as: :number, step: 0.01, min: 0, name: "Price (£)", help: "In pounds, e.g. 30 or 12.50. Empty shows no price."
    field :listed_on, as: :date, format: "dd.LL.yyyy", picker_format: "d.m.Y", hide_on: :index, help: "Its place in the home feed (newest first)."
    field :external_buy_url, as: :text, hide_on: :index, help: "Bandcamp link (a colour's own link wins)."
    field :sold_out, as: :boolean, help: "Sold Out instead of Buy. Apparel is also sold out when every size and colour is at 0."

    # Text
    field :top_line, as: :tiptap, name: "Top line",
      help: "Optional short line at the top of the page, centred, like an event's date. Select text for italic or White. Leave empty for none."
    field :heading, as: :tiptap,
      help: "Optional large heading at the top of the page. Enter starts a new line. Select text for italic or White."
    field :info, as: :tiptap,
      help: "The lines under the photo. With colours, each colour can have its own instead. Enter starts a new line. Select text for italic or White."

    # The home page tile
    field :show_tile_text, as: :boolean, name: "Text on the home tile", hide_on: :index,
      help: "Show the text under the tile's photo: the heading (or title), then the Info lines."
    field :tile_ratio, as: :select, options: Avo::Resources::Image::SHAPES, include_blank: "The photo's own shape",
      hide_on: :index, help: "Crop of the photo on the home tile."
    field :home_position, as: :number, name: "Home position", hide_on: :index,
      help: "Optional. Pins it to the top of the home page: 1 first, then 2 and so on. Leave empty to follow the date order."

    # The scattered photos
    field :reshuffle, as: :number, name: "Reshuffle photos", hide_on: :index, min: 0,
      help: "The arrangement of the scattered photos on wide screens. Change the number (1, 2, 3…) for a new one; 0 is the original."
  end
end
