# The Index's own text, edited in the admin ("Index page"): an optional
# large heading and an optional top line (the short centred line at the top,
# like an event's date). There is one.
class IndexPage < ApplicationRecord
  include EditorText

  editor_text :heading, :top_line

  validate :only_one, on: :create
  before_destroy { throw :abort } # the page always has its record

  def self.current = first || new

  # For the admin's lists and headings
  def title = "Index page"

  private

  def only_one
    errors.add(:base, "There is one Index page: edit it instead") if IndexPage.exists?
  end
end
