# The Buy button's words are automatic unless typed (Release#button_label)
class ReleaseButtonLabelsOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_default :releases, :buy_label, from: "Buy on Bandcamp", to: nil
    change_column_null :releases, :buy_label, true
    change_column_default :releases, :pre_order_label, from: "Pre-order on Bandcamp", to: nil
    change_column_null :releases, :pre_order_label, true
  end
end
