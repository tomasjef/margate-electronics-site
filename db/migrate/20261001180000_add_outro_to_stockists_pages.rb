# A line under the stockists list, editable in the admin (Tomas, 1 Oct),
# starting with the line he gave, "Get in touch" linked to the e-mail.
class AddOutroToStockistsPages < ActiveRecord::Migration[8.1]
  OUTRO = %(<p>Interested in stocking our releases? <a href="mailto:#{Links::EMAIL}">Get in touch</a>.</p>)

  def up
    add_column :stockists_pages, :outro, :text
    execute "UPDATE stockists_pages SET outro = #{connection.quote(OUTRO)}"
  end

  def down
    remove_column :stockists_pages, :outro
  end
end
