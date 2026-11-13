# Optional top lines (the short centred line at the top, like an event's
# date) on the pages without an automatic one, and a heading and top line
# for the Index and the Newsletter page, each a one-record page in the
# admin (Tomas, 5 Oct). The Newsletter page keeps its title, "Newsletter".
class AddTopLinesAndIndexAndNewsletterPages < ActiveRecord::Migration[8.1]
  def up
    add_column :about_pages, :top_line, :text
    add_column :stockists_pages, :top_line, :text
    add_column :products, :top_line, :text

    create_table :index_pages do |t|
      t.text :heading
      t.text :top_line
      t.timestamps
    end
    create_table :newsletter_pages do |t|
      t.text :heading
      t.text :top_line
      t.timestamps
    end
    execute "INSERT INTO index_pages (created_at, updated_at) VALUES (CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
    execute "INSERT INTO newsletter_pages (heading, created_at, updated_at) VALUES (#{connection.quote("<p>Newsletter</p>")}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)"
  end

  def down
    drop_table :newsletter_pages
    drop_table :index_pages
    remove_column :products, :top_line
    remove_column :stockists_pages, :top_line
    remove_column :about_pages, :top_line
  end
end
