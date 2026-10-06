# Tracks are numbered from 1, like photos (Tomas): new ones start at 1, and
# a set that starts at 0 moves up by one (its order stays the same).
class NumberTracksFromOne < ActiveRecord::Migration[8.1]
  def up
    change_column_default :tracks, :position, from: 0, to: 1
    execute <<~SQL
      UPDATE tracks SET position = position + 1
      WHERE (trackable_type, trackable_id) IN (
        SELECT trackable_type, trackable_id FROM tracks GROUP BY trackable_type, trackable_id HAVING MIN(position) = 0
      )
    SQL
  end

  def down
    change_column_default :tracks, :position, from: 1, to: 0
  end
end
