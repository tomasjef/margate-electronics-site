# An image as a page shows it: the file (an Active Storage blob on R2), the box
# it is drawn in (width and height, so the page never jumps while it loads;
# the photo is cropped to fill the box), alt text and an optional caption.
# A picture without a file draws a marked "Image to come" box of the same size.
# dither: its dithered stand-in while loading (Dither), when made.
Picture = Data.define(:blob, :width, :height, :alt, :caption, :dither) do
  def initialize(blob:, width:, height:, alt: "", caption: nil, dither: nil) = super

  def placeholder? = blob.nil?
  def ratio = "#{width} / #{height}"
end
