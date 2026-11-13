# The Newsletter's own text, edited in the admin ("Newsletter page"): an optional
# large heading and an optional top line (the short centred line at the top,
# like an event's date). There is one.
class NewsletterPage < ApplicationRecord
  include EditorText

  editor_text :heading, :top_line

  validate :only_one, on: :create
  before_destroy { throw :abort } # the page always has its record

  def self.current = first || new

  # For the admin's lists and headings
  def title = "Newsletter page"

  private

  def only_one
    errors.add(:base, "There is one Newsletter page: edit it instead") if NewsletterPage.exists?
  end
end
