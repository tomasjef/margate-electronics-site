# A release's status line is automatic too (Tomas): its catalogue number, and
# while it's a pre-order "ME004 – Pre-order, out on 09.10.2026".
class RemoveStatusLineFromReleases < ActiveRecord::Migration[8.1]
  def change
    remove_column :releases, :status_line, :string
  end
end
