class Avo::Resources::NewsletterPage < Avo::BaseResource
  self.title = :title
  self.icon = "tabler/outline/file-text"

  def fields
    field :top_line, as: :tiptap, name: "Top line",
      help: "The short centred line at the top of /newsletter/, naming the page. Leave empty for \"Newsletter\". Select text for italic or White."
    field :heading, as: :tiptap, name: "Title",
      help: "Optional title above the sign-up field, in the body size. The top line already names the page (\"Newsletter\"). Select text for italic or White. Leave empty for none."
  end
end
