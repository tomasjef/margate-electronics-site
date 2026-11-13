# The Stockists page's own text, edited in the admin: an optional large
# heading and the lines above and under the list (the shops themselves are
# Stockists). There is one.
class StockistsPage < ApplicationRecord
  include EditorText

  editor_text :top_line, :heading, :intro, :outro

  validate :only_one, on: :create
  before_destroy { throw :abort } # the page always has its record

  def self.current = first || new

  # For the admin's lists and headings
  def title = "Stockists page"

  private

  def only_one
    errors.add(:base, "There is one Stockists page: edit it instead") if StockistsPage.exists?
  end
end
