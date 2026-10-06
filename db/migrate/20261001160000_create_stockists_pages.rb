# The line above the stockists list, editable in the admin (Tomas, 1 Oct):
# one record, starting with the line he gave.
class CreateStockistsPages < ActiveRecord::Migration[8.1]
  INTRO = "<p>Our tapes are stocked in these shops:</p>"

  def up
    create_table :stockists_pages do |t|
      t.text :intro
      t.timestamps
    end
    execute "INSERT INTO stockists_pages (intro, created_at, updated_at) VALUES (#{connection.quote(INTRO)}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
  end

  def down
    drop_table :stockists_pages
  end
end
