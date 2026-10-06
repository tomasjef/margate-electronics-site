require "erb"

# Every link to a file on R2's public bucket (config.x.media_host). The
# published site is static, so pages link straight to the files: never to
# Active Storage's own routes, which need Rails.
module MediaUrls
  # Widths the site asks Cloudflare for; a small fixed set keeps the number of
  # distinct transformations (free up to 5,000 a month) low.
  WIDTHS = [ 80, 160, 200, 400, 440, 880, 1760, 3520 ].freeze
  # The lightbox: this width, and twice it for sharp screens when the
  # original is bigger (Cloudflare never enlarges past the original)
  LIGHTBOX_WIDTH = 1760

  module_function

  def host = Rails.configuration.x.media_host

  # An audio file by its path in the bucket. Each segment is percent-encoded
  # (spaces as %20): existing names contain spaces, #, &, brackets and
  # apostrophes, and an unencoded # would cut the URL short.
  def audio_url(path)
    "#{host}/#{encode_path(path)}"
  end

  # An image, resized and converted by Cloudflare Image Transformations to
  # the given width (rounded up to one of WIDTHS), in the best format the
  # browser accepts (AVIF or WebP).
  def image_url(blob, width:)
    "#{host}/cdn-cgi/image/width=#{snap(width)},quality=auto,format=auto/#{encode_path(blob.key)}"
  end

  # For link previews (WhatsApp, iMessage, social): 1200x630, cropped to fill
  # from the top, where posters carry their title. JPEG, which every preview
  # app reads.
  OG_SIZE = [ 1200, 630 ].freeze

  def og_image_url(blob)
    "#{host}/cdn-cgi/image/width=#{OG_SIZE[0]},height=#{OG_SIZE[1]},fit=cover,gravity=top,format=jpeg,quality=85/#{encode_path(blob.key)}"
  end

  # The same image at 1x and 2x, for srcset
  def image_srcset(blob, width:)
    [ 1, 2 ].map { |density| "#{image_url(blob, width: width * density)} #{density}x" }.join(", ")
  end

  def encode_path(path)
    path.to_s.split("/").map { |segment| ERB::Util.url_encode(segment) }.join("/")
  end

  def snap(width) = WIDTHS.find { |w| w >= width } || WIDTHS.last
end
