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

ActiveRecord::Schema[8.1].define(version: 2026_02_27_084621) do
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
    t.index ["user_id", "comment_id"], name: "index_comment_reactions_on_user_id_and_comment_id", unique: true
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
    t.index ["post_id", "parent_external_id"], name: "index_comments_on_post_id_and_parent_external_id"
    t.index ["post_id", "position"], name: "index_comments_on_post_id_and_position"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "feed_tags", force: :cascade do |t|
    t.bigint "feed_id", null: false
    t.bigint "tag_id", null: false
    t.index ["feed_id", "tag_id"], name: "index_feed_tags_on_feed_id_and_tag_id", unique: true
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
    t.index ["active", "last_fetched_at"], name: "index_feeds_on_active_and_last_fetched_at"
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
    t.index ["provider", "provider_uid"], name: "index_identities_on_provider_and_provider_uid", unique: true
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
    t.index ["user_id", "status"], name: "index_nickname_change_requests_on_user_id_and_status"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'approved'::character varying::text, 'rejected'::character varying::text])", name: "check_ncr_status"
  end

  create_table "post_reactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "post_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.integer "value", limit: 2, null: false
    t.index ["post_id"], name: "index_post_reactions_on_post_id"
    t.index ["user_id", "post_id"], name: "index_post_reactions_on_user_id_and_post_id", unique: true
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
    t.index ["url"], name: "index_posts_on_url", unique: true, where: "(url IS NOT NULL)"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "feed_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["feed_id"], name: "index_subscriptions_on_feed_id"
    t.index ["user_id", "feed_id"], name: "index_subscriptions_on_user_id_and_feed_id", unique: true
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
    t.check_constraint "role::text = ANY (ARRAY['user'::character varying::text, 'overseer'::character varying::text])", name: "check_users_role"
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
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "subscriptions", "feeds"
  add_foreign_key "subscriptions", "users"
end
