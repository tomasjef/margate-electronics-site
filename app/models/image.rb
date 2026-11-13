# A photo of an event, release or product, stored on R2 (the public media
# bucket) and linked from the pages through MediaUrls.
class Image < ApplicationRecord
  PLACEMENTS = %w[gallery scatter].freeze
  # Shapes a photo can be cropped to on the page; blank keeps its own shape
  RATIOS = { "4:3" => Rational(4, 3), "1:1" => Rational(1), "4:5" => Rational(4, 5), "3:4" => Rational(3, 4) }.freeze

  belongs_to :imageable, polymorphic: true, touch: true
  has_one_attached :file

  validates :alt, presence: true
  validates :placement, inclusion: { in: PLACEMENTS }
  validates :display_ratio, inclusion: { in: RATIOS.keys }, allow_blank: true
  validate :file_attached

  # A new file needs a new dithered stand-in (Dither), made after saving
  before_save { self.dither = nil if attachment_changes["file"] }
  after_save_commit :make_dither, if: -> { file.attached? && dither.nil? }

  # The photo's own width / height, once Active Storage has measured it
  def natural_ratio
    width, height = file.blob&.metadata&.values_at("width", "height")
    width && height ? Rational(width, height) : Rational(1)
  end

  # ratio: a key of RATIOS; blank uses display_ratio, then the photo's own shape.
  # height: a fixed box (thumbnails) instead of one from the ratio.
  def picture(width:, height: nil, ratio: nil)
    shape = RATIOS[ratio.presence || display_ratio.presence] || natural_ratio
    Picture.new(blob: file.blob, width: width, height: height || (width / shape).round, alt: alt, caption: caption_lines, dither: dither)
  end

  # The credit ("Photo © …", "Design © …", "Courtesy of …") starts a new
  # line of the caption, however it was typed
  CREDIT = /\s+(?=(?:Photos?|Design|Artwork)\s+(?:©|by\b)|Courtesy of\b)/

  def caption_lines = caption&.sub(CREDIT, "\n")

  private

  def make_dither = MakeDitherJob.perform_later(self)

  def file_attached
    errors.add(:file, "is missing") unless file.attached?
  end
end
