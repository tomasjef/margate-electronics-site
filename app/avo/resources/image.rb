class Avo::Resources::Image < Avo::BaseResource
  # Crop shapes offered for photos and home tiles (Image::RATIOS)
  SHAPES = { "Landscape 4:3" => "4:3", "Square 1:1" => "1:1", "Portrait 4:5" => "4:5", "Portrait 3:4" => "3:4" }.freeze

  self.title = :alt
  self.icon = "tabler/outline/photo"
  self.includes = [ file_attachment: :blob ]
  self.visible_on_sidebar = false

  def fields
    field :id, as: :id, only_on: :index
    field :file, as: :file, is_image: true, accept: "image/*", required: true,
      help: "Uploaded to R2 as it is; the site resizes it. To change the photo, choose a new file and Save. To remove it, delete the whole image (the bin icon on the release's Images list, or Delete at the top)."
    field :imageable, as: :belongs_to, polymorphic_as: :imageable, types: [ ::Event, ::Release, ::Product ], name: "Belongs to"
    # Lists show long text shortened (…), so they never scroll sideways; the
    # full text is on the photo's own page and in the form
    field :alt, as: :text, required: true, name: "Description (alt text)", format_index_using: -> { value.to_s.truncate(40, omission: "…") },
      help: "What the photo shows, for screen readers and search engines."
    field :caption, as: :text, format_index_using: -> { value.to_s.truncate(30, omission: "…") },
      help: "Optional; shown in the lightbox and under scattered photos."
    field :placement, as: :select, options: { "Gallery" => "gallery", "Scattered" => "scatter" },
      help: "Gallery: the main photo (the first) and its thumbnails. Scattered: further down the page."
    field :position, as: :number, help: "Order: 1 first, then 2 and so on (photos with the same number keep upload order). The first gallery photo is the main photo."
    field :display_ratio, as: :select, options: SHAPES, include_blank: "Its own shape", name: "Crop", hide_on: :index
    field :colour, as: :text, hide_on: :index, help: "Apparel: the colour this photo shows, e.g. Natural."
  end
end
