class Avo::Resources::StockistsPage < Avo::BaseResource
  self.title = :title
  self.icon = "tabler/outline/file-text"

  def fields
    field :top_line, as: :tiptap, name: "Top line",
      help: "The short centred line at the top of the page, naming it. Leave empty for \"Stockists\". Select text for italic or White."
    field :heading, as: :tiptap,
      help: "Optional large heading at the top of the page, as on events and releases. Enter starts a new line. Select text for italic or White. Leave empty for none."
    field :intro, as: :tiptap, name: "Text above the list",
      help: "Shown above the shops on /stockists/. Select text for italic, White or a link. Leave empty to leave it out. The shops are edited under Stockists."
    field :outro, as: :tiptap, name: "Text under the list",
      help: "Shown under the shops, e.g. an invitation to get in touch. Select text for italic, White or a link. Leave empty to leave it out."
  end
end
