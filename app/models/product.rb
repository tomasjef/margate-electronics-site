# Prints and apparel. Apparel comes in colours (each with its own photos, text
# and Bandcamp listing) and sizes; stock is per size and colour (ProductVariant).
class Product < ApplicationRecord
  include Illustrated
  include Priced
  include Slugged
  include EditorText

  editor_text :top_line, :heading, :info

  KINDS = %w[apparel print].freeze

  has_many :colours, -> { order(:position, :id) }, class_name: "ProductColour", dependent: :destroy
  has_many :variants, -> { order(:position, :id) }, class_name: "ProductVariant", dependent: :destroy

  validates :title, :slug, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :tile_ratio, inclusion: { in: Image::RATIOS.keys }, allow_blank: true

  scope :published, -> { where(published: true) }

  def section = kind == "apparel" ? "Apparel" : "Prints"

  def colour_names = colours.map(&:name)

  # nil for products without sizes (prints)
  def inventory
    return if variants.empty?
    Inventory.new(sizes: variants.map(&:size).uniq,
                  colours: colours.any? ? colour_names : variants.map(&:colour).uniq,
                  stock: variants.to_h { |v| [ [ v.size, v.colour ], v.stock ] })
  end

  # Marked sold out in the admin, or (apparel) nothing left in any size or colour
  def sold_out? = super || inventory&.sold_out? || false

  def info_for(colour) = colours.find { |c| c.name == colour }&.info.presence || info

  def buy_url_for(colour) = colours.find { |c| c.name == colour }&.buy_url.presence || external_buy_url

  def buy_urls = colours.select { |c| c.buy_url.present? }.to_h { |c| [ c.name, c.buy_url ] }
end
