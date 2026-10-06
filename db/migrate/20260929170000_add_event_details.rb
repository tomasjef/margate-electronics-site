# The text under an event's poster is written from fields (Tomas): ticket
# prices, then the title and lineup, then venue, date and time, then the
# free description.
class AddEventDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :tickets, :string
    add_column :events, :live, :text
    add_column :events, :dj, :text
    add_column :events, :screening, :text
    add_column :events, :workshop, :text
  end
end
