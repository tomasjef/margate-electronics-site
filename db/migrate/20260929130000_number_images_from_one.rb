# Photos are numbered from 1 (Tomas): new ones start at 1, and every
# existing photo moves up by one, which keeps each set in the same order.
class NumberImagesFromOne < ActiveRecord::Migration[8.1]
  def up
    change_column_default :images, :position, from: 0, to: 1
    execute "UPDATE images SET position = position + 1"
  end

  def down
    execute "UPDATE images SET position = position - 1"
    change_column_default :images, :position, from: 1, to: 0
  end
end
