# An optional large heading at the top of the About and Stockists pages,
# edited in the admin like an event's (Tomas, 5 Oct). About starts with the
# label's name; Stockists starts empty (no heading, as before).
class AddHeadingToAboutAndStockistsPages < ActiveRecord::Migration[8.1]
  def up
    add_column :about_pages, :heading, :text
    add_column :stockists_pages, :heading, :text
    execute "UPDATE about_pages SET heading = #{connection.quote("<p>Margate Electronics</p>")}"
  end

  def down
    remove_column :about_pages, :heading
    remove_column :stockists_pages, :heading
  end
end
