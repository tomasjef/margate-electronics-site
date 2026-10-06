# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_05_200000) do
  create_table "about_pages", force: :cascade do |t|
    t.text "body"
    t.text "artists"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "credit"
    t.text "heading"
    t.text "top_line"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.date "date", null: false
    t.string "doors_at"
    t.string "music_at"
    t.string "venue"
    t.text "heading"
    t.text "description"
    t.string "tile_ratio"
    t.string "external_ticket_url"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sold_out", default: false, null: false
    t.integer "home_position"
    t.string "tickets"
    t.text "live"
    t.text "dj"
    t.text "screening"
    t.text "workshop"
    t.boolean "show_tile_text", default: true, null: false
    t.integer "reshuffle", default: 0, null: false
    t.index ["slug"], name: "index_events_on_slug", unique: true
  end

  create_table "images", force: :cascade do |t|
    t.string "imageable_type", null: false
    t.integer "imageable_id", null: false
    t.string "placement", default: "gallery", null: false
    t.integer "position", default: 1, null: false
    t.string "alt", null: false
    t.string "caption"
    t.string "colour"
    t.string "display_ratio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "dither"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable"
  end

  create_table "index_pages", force: :cascade do |t|
    t.text "heading"
    t.text "top_line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "newsletter_pages", force: :cascade do |t|
    t.text "heading"
    t.text "top_line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_colours", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "name", null: false
    t.text "info"
    t.string "buy_url"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bandcamp_package_id"
    t.index ["bandcamp_package_id"], name: "index_product_colours_on_bandcamp_package_id", unique: true
    t.index ["product_id"], name: "index_product_colours_on_product_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "size", null: false
    t.string "colour"
    t.integer "stock", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variants_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "kind", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.text "heading"
    t.text "info"
    t.integer "price_pence"
    t.date "listed_on"
    t.string "external_buy_url"
    t.string "stripe_price_id"
    t.string "tile_ratio"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sold_out", default: false, null: false
    t.integer "home_position"
    t.boolean "show_tile_text", default: true, null: false
    t.integer "reshuffle", default: 0, null: false
    t.text "top_line"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "releases", force: :cascade do |t|
    t.string "catalogue_number"
    t.string "artist", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.string "format"
    t.integer "edition_size"
    t.integer "price_pence"
    t.date "release_date"
    t.boolean "sold_out", default: false, null: false
    t.text "info"
    t.text "heading"
    t.text "description"
    t.text "credits"
    t.string "external_buy_url"
    t.string "tile_ratio"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "home_position"
    t.boolean "show_tile_text", default: true, null: false
    t.integer "reshuffle", default: 0, null: false
    t.integer "tape_stock"
    t.index ["slug"], name: "index_releases_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stockists", force: :cascade do |t|
    t.string "city", null: false
    t.string "name", null: false
    t.string "url", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stockists_pages", force: :cascade do |t|
    t.text "intro"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "outro"
    t.text "heading"
    t.text "top_line"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "trackable_type", null: false
    t.integer "trackable_id", null: false
    t.string "title", null: false
    t.string "duration"
    t.integer "position", default: 1, null: false
    t.string "audio_path"
    t.string "master_path"
    t.integer "preview_start", default: 60, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trackable_type", "trackable_id"], name: "index_tracks_on_trackable"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "product_colours", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "sessions", "users"
end
