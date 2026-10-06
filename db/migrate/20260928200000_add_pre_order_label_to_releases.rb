# The Buy button's words while a release is a pre-order; buy_label shows once
# it's out, so the button changes by itself on the release date.
class AddPreOrderLabelToReleases < ActiveRecord::Migration[8.1]
  def change
    add_column :releases, :pre_order_label, :string, default: "Pre-order on Bandcamp", null: false
  end
end
