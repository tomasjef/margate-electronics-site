# Fields that were always the same or never used (29 Sep): the words on the
# buttons are fixed or come from the link, an event's number comes from its
# title, and sizes had an unused SKU
class RemoveUnneededFields < ActiveRecord::Migration[8.1]
  def change
    remove_column :events, :number, :integer
    remove_column :events, :ticket_label, :string, default: "Book Tickets", null: false
    remove_column :releases, :buy_label, :string
    remove_column :releases, :pre_order_label, :string
    remove_column :products, :buy_label, :string, default: "Buy", null: false
    remove_column :product_variants, :sku, :string
  end
end
