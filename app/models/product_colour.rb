class ProductColour < ApplicationRecord
  include EditorText

  editor_text :info

  belongs_to :product, touch: true

  validates :name, presence: true
end
