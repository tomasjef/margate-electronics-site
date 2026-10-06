# Events, releases and products carry photos (Image): a gallery (the first is
# the main photo; with more than one they show as thumbnails) and optional
# scattered photos further down the page.
module Illustrated
  extend ActiveSupport::Concern

  COLUMN = 440     # the page column the main photo fills
  THUMB = 80       # thumbnails' width; their height follows each photo's shape
  SCATTER = 200

  # A thumbnail, and the same photo at the main photo's size (it swaps in
  # there in its own shape)
  Thumb = Data.define(:picture, :main)

  included do
    has_many :images, -> { order(:position, :id) }, as: :imageable, dependent: :destroy
  end

  def gallery_images(colour = nil)
    images.select { |image| image.placement == "gallery" && (colour.nil? || image.colour == colour) }
  end

  def scatter_images = images.select { |image| image.placement == "scatter" }

  def main_image(colour = nil) = gallery_images(colour).first

  def main_picture(colour = nil) = main_image(colour)&.picture(width: COLUMN)

  # Thumbnails only when there's something to choose between. Each in the
  # photo's shape: its crop from the admin, or its own proportions.
  def thumb_pictures(colour = nil)
    gallery = gallery_images(colour)
    return [] unless gallery.size > 1
    gallery.map { |image| Thumb.new(picture: image.picture(width: THUMB), main: image.picture(width: COLUMN)) }
  end

  def scatter_pictures = scatter_images.map { |image| image.picture(width: SCATTER) }

  # What the scattered photos' arrangement is worked out from: the slug, or
  # with "Reshuffle" set, the slug and that number (a new arrangement)
  def scatter_seed = reshuffle.to_i.zero? ? slug : "#{slug}-#{reshuffle}"

  # The home tile: the main photo, in the tile's own shape if one is set
  def tile_picture = main_image&.picture(width: COLUMN, ratio: tile_ratio)
end
