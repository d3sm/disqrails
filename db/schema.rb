ActiveRecord::Schema[8.1].define(version: 20_260_224_121_101) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "comment_reactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "comment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.integer "value", limit: 2, null: false
    t.index ["comment_id"], name: "index_comment_reactions_on_comment_id"
    t.index %w[user_id comment_id], name: "index_comment_reactions_on_user_id_and_comment_id", unique: true
    t.check_constraint "value = ANY (ARRAY['-1'::integer, 1])", name: "check_comment_reactions_value"
  end

  create_table "comments", force: :cascade do |t|
    t.string "author"
    t.text "body_html"
    t.datetime "created_at", null: false
    t.integer "depth", default: 0, null: false
    t.bigint "external_id"
    t.boolean "hn_dead", default: false, null: false
    t.boolean "hn_deleted", default: false, null: false
    t.boolean "local_reply", default: false, null: false
    t.bigint "parent_external_id"
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.bigint "post_id", null: false
    t.datetime "posted_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["external_id"], name: "index_comments_on_external_id", unique: true
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index %w[post_id parent_external_id], name: "index_comments_on_post_id_and_parent_external_id"
    t.index %w[post_id position], name: "index_comments_on_post_id_and_position"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "feed_tags", force: :cascade do |t|
    t.bigint "feed_id", null: false
    t.bigint "tag_id", null: false
    t.index %w[feed_id tag_id], name: "index_feed_tags_on_feed_id_and_tag_id", unique: true
    t.index ["feed_id"], name: "index_feed_tags_on_feed_id"
    t.index ["tag_id"], name: "index_feed_tags_on_tag_id"
  end

  create_table "feeds", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", default: "personal_blog"
    t.datetime "created_at", null: false
    t.integer "error_count", default: 0, null: false
    t.string "etag"
    t.boolean "featured", default: false
    t.integer "fetch_interval_minutes", default: 60, null: false
    t.string "last_error"
    t.datetime "last_fetched_at"
    t.string "last_modified_header"
    t.string "name", null: false
    t.string "site_url"
    t.string "source_type", default: "rss", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index %w[active last_fetched_at], name: "index_feeds_on_active_and_last_fetched_at"
    t.index ["url"], name: "index_feeds_on_url", unique: true
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "provider", null: false
    t.string "provider_email"
    t.string "provider_handle"
    t.string "provider_uid", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index %w[provider provider_uid], name: "index_identities_on_provider_and_provider_uid", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "nickname_change_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "reason"
    t.string "requested_nickname", null: false
    t.datetime "reviewed_at"
    t.uuid "reviewed_by"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["status"], name: "index_nickname_change_requests_on_status"
    t.index %w[user_id status], name: "index_nickname_change_requests_on_user_id_and_status"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text])",
                       name: "check_ncr_status"
  end

  create_table "post_reactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "post_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.integer "value", limit: 2, null: false
    t.index ["post_id"], name: "index_post_reactions_on_post_id"
    t.index %w[user_id post_id], name: "index_post_reactions_on_user_id_and_post_id", unique: true
    t.check_constraint "value = ANY (ARRAY['-1'::integer, 1])", name: "check_post_reactions_value"
  end

  create_table "posts", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.bigint "external_id"
    t.bigint "feed_id"
    t.string "hn_by"
    t.integer "hn_descendants"
    t.integer "hn_rank"
    t.integer "hn_score"
    t.string "hn_type"
    t.datetime "published_at"
    t.string "source", default: "local", null: false
    t.text "source_description"
    t.string "source_image_url"
    t.text "text"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.uuid "user_id"
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["external_id"], name: "index_posts_on_external_id", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["feed_id"], name: "index_posts_on_feed_id"
    t.index ["hn_rank"], name: "index_posts_on_hn_rank"
    t.index ["hn_type"], name: "index_posts_on_hn_type"
    t.index ["published_at"], name: "index_posts_on_published_at"
    t.index ["url"], name: "index_posts_on_url"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "feed_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["feed_id"], name: "index_subscriptions_on_feed_id"
    t.index %w[user_id feed_id], name: "index_subscriptions_on_user_id_and_feed_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.integer "karma", default: 0, null: false
    t.string "nickname", null: false
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["nickname"], name: "index_users_on_nickname", unique: true, where: "(deleted_at IS NULL)"
    t.check_constraint "role::text = ANY (ARRAY['user'::character varying::text, 'overseer'::character varying::text])",
                       name: "check_users_role"
  end

  add_foreign_key "comment_reactions", "comments"
  add_foreign_key "comment_reactions", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "feed_tags", "feeds"
  add_foreign_key "feed_tags", "tags"
  add_foreign_key "identities", "users"
  add_foreign_key "nickname_change_requests", "users"
  add_foreign_key "nickname_change_requests", "users", column: "reviewed_by"
  add_foreign_key "post_reactions", "posts"
  add_foreign_key "post_reactions", "users"
  add_foreign_key "posts", "feeds"
  add_foreign_key "posts", "users"
  add_foreign_key "subscriptions", "feeds"
  add_foreign_key "subscriptions", "users"
end
