# The home tiles' text is written from each item's fields (Tomas), with a
# switch to show it or not; the typed tile text goes.
class AutomateTileText < ActiveRecord::Migration[8.1]
  def change
    %i[events releases products].each do |table|
      add_column table, :show_tile_text, :boolean, default: true, null: false
      remove_column table, :tile_caption, :text
    end
  end
end
