# Text edited in the admin's text editor. Cleared, the editor leaves an empty
# paragraph ("<p></p>"), which would count as text: store nothing instead.
module EditorText
  extend ActiveSupport::Concern

  class_methods do
    def editor_text(*fields)
      normalizes(*fields, with: ->(html) { html.gsub(/<[^>]*>|&nbsp;/, "").strip.empty? ? nil : html })
    end
  end
end
