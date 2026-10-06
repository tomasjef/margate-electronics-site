# Stock from Bandcamp (Tomas, 1 Oct): each T-shirt colour linked to its
# Bandcamp item, and a release's cassettes left. The T-shirt's two Bandcamp
# items are named by emoji: ⚪️🔵 (white shirt, blue print) is Natural,
# ⚫️⚪️ (black shirt, white print) is Black.
class AddBandcampStock < ActiveRecord::Migration[8.1]
  def up
    add_column :product_colours, :bandcamp_package_id, :bigint
    add_index :product_colours, :bandcamp_package_id, unique: true
    add_column :releases, :tape_stock, :integer
    { "Natural" => 1835340623, "Black" => 763565684 }.each do |name, package_id|
      execute <<~SQL
        UPDATE product_colours SET bandcamp_package_id = #{package_id}
        WHERE name = #{connection.quote(name)} AND product_id IN (SELECT id FROM products WHERE slug = 't-shirt')
      SQL
    end
  end

  def down
    remove_column :releases, :tape_stock
    remove_index :product_colours, :bandcamp_package_id
    remove_column :product_colours, :bandcamp_package_id
  end
end
