# Prices are kept in pence and shown as £12 or £12.50. The admin edits them
# in pounds (price_pounds: "12", "12.50", "£12" all work).
module Priced
  extend ActiveSupport::Concern

  included do
    validates :price_pence, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
    validate { errors.add(:price_pounds, "must be an amount in pounds, e.g. 12 or 12.50") if @unreadable_price }
  end

  def price = price_pounds && "£#{price_pounds}"

  # "12" or "12.50"; nil without a price
  def price_pounds
    return if price_pence.nil?
    pounds, pence = price_pence.divmod(100)
    # Not format(): releases have a format column (cassette, digital...)
    pence.zero? ? pounds.to_s : "%d.%02d" % [ pounds, pence ]
  end

  # Empty clears the price
  def price_pounds=(value)
    text = value.to_s.delete("£, ")
    @unreadable_price = nil
    self.price_pence = text.empty? ? nil : (BigDecimal(text) * 100).round.to_i
  rescue ArgumentError
    @unreadable_price = value
  end
end
