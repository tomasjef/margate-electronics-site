# The Newsletter page's top line now names it ("Newsletter", as on About,
# Stockists and the Index), so its title above the field, the same word,
# starts empty (Tomas, 5 Oct); it can be filled in again in the admin.
class ClearNewsletterPageTitle < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE newsletter_pages SET heading = NULL WHERE heading = #{connection.quote("<p>Newsletter</p>")}"
  end

  def down
    execute "UPDATE newsletter_pages SET heading = #{connection.quote("<p>Newsletter</p>")} WHERE heading IS NULL"
  end
end
