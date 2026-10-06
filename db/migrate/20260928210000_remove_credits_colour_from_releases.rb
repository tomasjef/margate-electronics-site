# White text is now a style in the admin's text editor, on any text, so the
# credits' own colour setting goes (both releases had it on blue).
class RemoveCreditsColourFromReleases < ActiveRecord::Migration[8.1]
  def change
    remove_column :releases, :credits_colour, :string, null: false, default: "blue"
  end
end
