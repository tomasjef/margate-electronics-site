# A number that gives the scattered photos a fresh arrangement (0: the
# original one, from the slug)
class AddReshuffle < ActiveRecord::Migration[8.1]
  def change
    %i[events releases products].each do |table|
      add_column table, :reshuffle, :integer, default: 0, null: false
    end
  end
end
