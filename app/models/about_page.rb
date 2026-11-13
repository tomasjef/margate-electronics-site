# The About page, edited in the admin: an optional large heading, its text,
# the artists we have worked with (one per line, shown A to Z) and a credit
# line under them. There is one.
class AboutPage < ApplicationRecord
  include EditorText

  editor_text :top_line, :heading, :body, :artists, :credit

  validate :only_one, on: :create
  before_destroy { throw :abort } # the page always has its text

  def self.current = first || new

  # For the admin's lists and headings
  def title = "About"

  # One name per line of the editor, A to Z, each once
  def artist_names
    artists.to_s.split(ApplicationHelper::LINE_BREAK)
      .map { |line| Nokogiri::HTML5.fragment(line).text.squish }
      .compact_blank.uniq.sort_by(&:downcase)
  end

  private

  def only_one
    errors.add(:base, "There is one About page: edit it instead") if AboutPage.exists?
  end
end
