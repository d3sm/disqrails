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

ActiveRecord::Schema[8.1].define(version: 2026_02_23_183500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.string "author"
    t.text "body_html"
    t.datetime "created_at", null: false
    t.integer "depth", default: 0, null: false
    t.bigint "external_id", null: false
    t.boolean "hn_dead", default: false, null: false
    t.boolean "hn_deleted", default: false, null: false
    t.bigint "parent_external_id"
    t.integer "position", default: 0, null: false
    t.bigint "post_id", null: false
    t.datetime "posted_at"
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_comments_on_external_id", unique: true
    t.index ["post_id", "parent_external_id"], name: "index_comments_on_post_id_and_parent_external_id"
    t.index ["post_id", "position"], name: "index_comments_on_post_id_and_position"
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "external_id"
    t.string "hn_by"
    t.integer "hn_descendants"
    t.integer "hn_rank"
    t.integer "hn_score"
    t.string "hn_type"
    t.string "source", default: "local", null: false
    t.text "source_description"
    t.string "source_image_url"
    t.text "text"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["external_id"], name: "index_posts_on_external_id", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["hn_rank"], name: "index_posts_on_hn_rank"
    t.index ["hn_type"], name: "index_posts_on_hn_type"
  end

  add_foreign_key "comments", "posts"
end
