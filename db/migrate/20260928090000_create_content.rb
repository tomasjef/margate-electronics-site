# The site's content: events, releases, products, their tracks and images.
# Edited in the admin, stored in the committed content database, published
# as a static site. Rich text (descriptions, credits, captions) is HTML from
# the admin's editor, shown through ApplicationHelper#copy.
class CreateContent < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.integer :number
      t.string :title, null: false
      t.string :slug, null: false, index: { unique: true }
      t.date :date, null: false
      t.string :doors_at
      t.string :music_at
      t.string :venue
      t.text :heading                 # optional large page heading (HTML, may contain <br>)
      t.string :status_line           # optional; default "Upcoming – 09.10.2026"
      t.text :description
      t.text :tile_caption
      t.string :tile_ratio            # optional shape of the home tile photo
      t.string :external_ticket_url
      t.string :ticket_label, null: false, default: "Book Tickets"
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    create_table :releases do |t|
      t.string :catalogue_number
      t.string :artist, null: false
      t.string :title, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :format
      t.integer :edition_size
      t.integer :price_pence
      t.date :release_date
      t.boolean :sold_out, null: false, default: false
      t.text :info                    # the lines under the cover
      t.text :heading
      t.string :status_line
      t.text :description
      t.text :credits
      t.string :credits_colour, null: false, default: "blue"
      t.string :buy_label, null: false, default: "Buy on Bandcamp"
      t.string :external_buy_url
      t.text :tile_caption
      t.string :tile_ratio
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    create_table :products do |t|
      t.string :kind, null: false     # "apparel" or "print"
      t.string :title, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :heading
      t.text :info                    # when it doesn't change with the colour
      t.integer :price_pence
      t.date :listed_on               # for the home feed's order
      t.string :buy_label, null: false, default: "Buy"
      t.string :external_buy_url
      t.string :stripe_price_id       # phase 2; empty until then
      t.text :tile_caption
      t.string :tile_ratio
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    create_table :product_colours do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name, null: false
      t.text :info                    # replaces the product's info for this colour
      t.string :buy_url               # each colour can be its own Bandcamp listing
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :size, null: false
      t.string :colour
      t.integer :stock, null: false, default: 0
      t.string :sku
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :tracks do |t|
      t.references :trackable, polymorphic: true, null: false  # a Release, or an Event (recordings)
      t.string :title, null: false
      t.string :duration              # as shown, e.g. "20:23"
      t.integer :position, null: false, default: 0
      t.string :audio_path            # in the public media bucket
      t.string :master_path           # releases: the full file, private bucket
      t.integer :preview_start, null: false, default: 60
      t.timestamps
    end

    create_table :images do |t|
      t.references :imageable, polymorphic: true, null: false
      t.string :placement, null: false, default: "gallery"  # gallery, scatter
      t.integer :position, null: false, default: 0
      t.string :alt, null: false
      t.string :caption
      t.string :colour                # apparel: which colour's photo set
      t.string :display_ratio         # optional crop shape on the page
      t.timestamps
    end
  end
end
