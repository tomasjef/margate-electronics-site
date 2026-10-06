class Avo::Resources::Stockist < Avo::BaseResource
  self.title = :name
  self.icon = "tabler/outline/building-store"
  self.default_sort_column = :position
  self.default_sort_direction = :asc

  def fields
    field :id, as: :id, only_on: :index
    field :city, as: :text, required: true, help: "Shops are grouped by city on /stockists/, e.g. Margate."
    field :name, as: :text, required: true, help: "As the shop writes it, e.g. Ghost Papa Records."
    field :url, as: :text, required: true, name: "Web address",
      format_index_using: -> { value.to_s.truncate(40, omission: "…") }, help: "The shop's website or page, starting https://"
    field :position, as: :number,
      help: "Order: lowest first. Cities follow their first shop (Margate 1–2, London 3–4…)."
  end
end
