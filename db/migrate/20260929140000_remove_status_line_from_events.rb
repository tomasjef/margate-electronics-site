# An event's status line is always automatic (Tomas): "Upcoming – 09.10.2026"
# until its date, then "Archived – 09.10.2026". Releases keep theirs.
class RemoveStatusLineFromEvents < ActiveRecord::Migration[8.1]
  def change
    remove_column :events, :status_line, :string
  end
end
