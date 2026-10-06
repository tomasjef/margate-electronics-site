# An optional pin for the home page: numbered items go first, in number
# order; everything else keeps the date order.
class AddHomePosition < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :home_position, :integer
    add_column :releases, :home_position, :integer
    add_column :products, :home_position, :integer
  end
end
