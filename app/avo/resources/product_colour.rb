class Avo::Resources::ProductColour < Avo::BaseResource
  self.title = :name
  self.visible_on_sidebar = false

  def fields
    field :id, as: :id
    field :product, as: :belongs_to
    field :name, as: :text, required: true, help: "e.g. Natural. Photos with this colour show when it's chosen."
    field :info, as: :tiptap, help: "Optional: this colour's lines under the photo. Enter starts a new line. Select text for italic or White."
    field :buy_url, as: :text, format_index_using: -> { value.to_s.truncate(40, omission: "…") }, help: "Optional: this colour's own Bandcamp listing."
    field :bandcamp_package_id, as: :number, name: "Bandcamp item", hide_on: :index,
      help: "Links this colour to its Bandcamp merch item, so its sizes' stock comes from Bandcamp (each publish and daily). Natural and Black are set; a new colour needs its number from Claude."
    field :position, as: :number, help: "Order: lowest first."
  end
end
