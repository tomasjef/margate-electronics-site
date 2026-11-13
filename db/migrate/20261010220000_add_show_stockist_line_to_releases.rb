class AddShowStockistLineToReleases < ActiveRecord::Migration[8.1]
  def change
    add_column :releases, :show_stockist_line, :boolean, default: true, null: false
  end
end
