# One size (and colour) of a product, with its stock
class ProductVariant < ApplicationRecord
  belongs_to :product, touch: true

  validates :size, presence: true
  validates :stock, numericality: { greater_than_or_equal_to: 0, only_integer: true }
end
