class Avo::Resources::ProductVariant < Avo::BaseResource
  self.title = :size
  self.visible_on_sidebar = false

  def fields
    field :id, as: :id, only_on: :index
    field :product, as: :belongs_to
    field :size, as: :text, required: true
    field :colour, as: :text, help: "Must match a colour's name exactly, e.g. Natural."
    field :stock, as: :number, help: "0 shows the size as sold out; 1 to 3 shows 'N remaining'. For a colour linked to Bandcamp this comes from Bandcamp on each publish and daily: a change here is overwritten."
    field :position, as: :number, help: "Order of the sizes: lowest first."
  end
end
