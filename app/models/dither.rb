# A photo's stand-in while it loads: a tiny two-colour version, dithered in
# the site's blue on its grey, kept in the content database as a data URI
# (under 1 KB) and drawn blown up under the photo (media_image), so a tile
# shows a pixelated print of itself instead of a blank box. Made locally
# with ImageMagick (MakeDitherJob); the static build only reads it.
module Dither
  WIDTH = 64 # pixels across; each becomes a block of about 7px on a tile
  # The tokens --color-ink and --color-bg: the dark and the light dots
  INK = "#0000ff"
  GROUND = "#cccccc"

  module_function

  # path: a local image file. Returns "data:image/png;base64,…"
  def from(path)
    png = ImageProcessing::MiniMagick.source(path)
      .loader(page: 0)
      .resize("#{WIDTH}x")
      .colorspace("Gray")
      # Full range and firmer mid-tones, or mid-greys all become one checkerboard
      .normalize
      .sigmoidal_contrast("5x50%")
      .ordered_dither("o8x8")
      .threshold("50%") # strictly two values, so strictly two colours
      .append("+level-colors", "#{INK},#{GROUND}")
      .strip
      .convert("png")
      .call
    "data:image/png;base64,#{Base64.strict_encode64(File.binread(png.path))}"
  ensure
    png&.close!
  end
end
