# Events (tickets gone) and products (prints; apparel also counts as sold out
# when every size and colour is at 0) can be marked sold out, like releases.
class AddSoldOutToEventsAndProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :sold_out, :boolean, default: false, null: false
    add_column :products, :sold_out, :boolean, default: false, null: false
  end
end
