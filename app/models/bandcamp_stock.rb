# Copies Bandcamp's stock onto the site's (read only on Bandcamp's side):
# - a cassette's count onto its release, matched by album title (tape_stock);
# - each option of a merch item onto that size of the colour linked to it by
#   its Bandcamp package (ProductColour#bandcamp_package_id), the option's
#   title being the size ("XL").
# Runs before every publish and every deploy (bin/rails bandcamp:stock).
class BandcampStock
  Result = Data.define(:changes, :unmatched)

  # What bin/rails bandcamp:stock prints. Never stops a publish or build:
  # without keys, or with Bandcamp out of reach, the stock last saved stays.
  def self.report(api: BandcampApi.new, configured: BandcampApi.configured?)
    return [ "Bandcamp stock: skipped, no keys (BANDCAMP_CLIENT_ID, BANDCAMP_CLIENT_SECRET)" ] unless configured
    result = new(api:).call
    lines = [ result.changes.any? ? "Bandcamp stock: #{result.changes.join("; ")}" : "Bandcamp stock: no changes" ]
    lines << "Bandcamp stock: not on the site: #{result.unmatched.join("; ")}" if result.unmatched.any?
    lines
  rescue BandcampApi::Error => e
    [ "Bandcamp stock: #{e.message}; keeping the stock last saved" ]
  end

  def initialize(api: BandcampApi.new)
    @api = api
  end

  def call
    changes = []
    unmatched = []
    @api.merch.each do |item|
      if (colour = ProductColour.find_by(bandcamp_package_id: item["package_id"]))
        Array(item["options"]).each do |option|
          size = option["title"].to_s.strip
          variant = colour.product.variants.find { |v| v.colour == colour.name && v.size.casecmp?(size) }
          next unmatched << "#{colour.product.title} #{colour.name}: no size #{size}" unless variant
          left = option["quantity_available"]
          next if left.nil? || variant.stock == left
          changes << "#{colour.product.title} #{variant.size} #{colour.name}: #{variant.stock} → #{left}"
          variant.update_columns(stock: left, updated_at: Time.current)
        end
      elsif item["album_title"].present? && (release = Release.find_by(title: item["album_title"]))
        left = item["quantity_available"]
        next if release.tape_stock == left
        changes << "#{release.catalogue_number || release.title} tapes: #{release.tape_stock.inspect} → #{left.inspect}"
        release.update_columns(tape_stock: left, updated_at: Time.current)
      else
        unmatched << item["title"].to_s
      end
    end
    Result.new(changes:, unmatched:)
  end
end
