class Avo::Resources::IndexPage < Avo::BaseResource
  self.title = :title
  self.icon = "tabler/outline/file-text"

  def fields
    field :top_line, as: :tiptap, name: "Top line",
      help: "The short centred line at the top of the Index, naming it. Leave empty for \"Index\". Select text for italic or White."
    field :heading, as: :tiptap,
      help: "Optional large heading at the top of the page, as on events and releases. Enter starts a new line. Select text for italic or White. Leave empty for none."
  end
end
