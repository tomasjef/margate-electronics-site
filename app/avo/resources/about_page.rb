class Avo::Resources::AboutPage < Avo::BaseResource
  self.title = :title
  self.icon = "tabler/outline/info-circle"

  def fields
    field :top_line, as: :tiptap, name: "Top line",
      help: "The short centred line at the top of the page, naming it. Leave empty for \"About\". Select text for italic or White."
    field :heading, as: :tiptap,
      help: "Optional large heading at the top of the page, as on events and releases. Enter starts a new line. Select text for italic or White. Leave empty for none."
    field :body, as: :tiptap, name: "Text",
      help: "The About page's text. Enter starts a new paragraph, Shift+Enter a new line in the same one. Select text for italic, White or a link."
    field :artists, as: :tiptap, name: "Artists we have worked with",
      help: "One name per line (Enter after each), plain names: italic and links aren't shown. The page lists them A to Z in two columns, each once."
    field :credit, as: :tiptap, name: "Credit (under the artists)",
      help: "Optional, e.g. the website's design and build credit. Select text for italic, White or a link. Leave empty to leave it out."
  end
end
