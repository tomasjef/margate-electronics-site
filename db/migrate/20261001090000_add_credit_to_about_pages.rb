# A line under the About page's artists list, e.g. the website's design and
# build credit (Tomas, 1 Oct)
class AddCreditToAboutPages < ActiveRecord::Migration[8.1]
  def change
    add_column :about_pages, :credit, :text
  end
end
