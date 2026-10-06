# A photo's dithered stand-in while it loads (Dither), as a data URI
class AddDitherToImages < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :dither, :text
  end
end
