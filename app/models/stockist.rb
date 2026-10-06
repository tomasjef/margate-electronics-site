# A record shop that stocks the label's tapes, edited in the admin. Shown on
# /stockists/, grouped by city in the order of their positions.
class Stockist < ApplicationRecord
  validates :city, :name, presence: true
  validates :url, format: { with: %r{\Ahttps?://\S+\z}, message: "must be a full web address (https://…)" }

  # { "Margate" => [shops], "London" => [...] }: cities in the order of their
  # first shop's position, shops in position order
  def self.by_city = order(:position, :id).group_by(&:city)
end
