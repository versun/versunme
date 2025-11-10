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

ActiveRecord::Schema[8.1].define(version: 2025_11_10_000602) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "level", default: 0
    t.string "target"
    t.datetime "updated_at", null: false
  end



  create_table "articles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "crosspost_bluesky", default: false, null: false
    t.boolean "crosspost_mastodon", default: false, null: false
    t.boolean "crosspost_twitter", default: false, null: false
    t.string "description"
    t.datetime "scheduled_at"
    t.boolean "send_newsletter", default: false, null: false
    t.string "slug"
    t.integer "status", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "crossposts", force: :cascade do |t|
    t.string "access_token"
    t.string "access_token_secret"
    t.string "api_key"
    t.string "api_key_secret"
    t.string "app_password"
    t.string "client_id"
    t.string "client_key"
    t.string "client_secret"
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.string "platform", null: false
    t.string "server_url"
    t.text "settings"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["platform"], name: "index_crossposts_on_platform", unique: true
  end

  create_table "listmonks", force: :cascade do |t|
    t.string "api_key"
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.integer "list_id"
    t.integer "template_id"
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "username"
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "page_order", default: 0, null: false
    t.string "redirect_url"
    t.string "slug"
    t.integer "status", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "rails_pulse_operations", force: :cascade do |t|
    t.string "codebase_location"
    t.datetime "created_at", null: false
    t.decimal "duration", precision: 15, scale: 6, null: false
    t.string "label", null: false
    t.datetime "occurred_at", null: false
    t.string "operation_type", null: false
    t.integer "query_id"
    t.integer "request_id", null: false
    t.float "start_time", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.index ["created_at", "query_id"], name: "idx_operations_for_aggregation"
    t.index ["created_at"], name: "idx_operations_created_at"
    t.index ["occurred_at", "duration", "operation_type"], name: "index_rails_pulse_operations_on_time_duration_type"
    t.index ["occurred_at"], name: "index_rails_pulse_operations_on_occurred_at"
    t.index ["operation_type"], name: "index_rails_pulse_operations_on_operation_type"
    t.index ["query_id", "duration", "occurred_at"], name: "index_rails_pulse_operations_query_performance"
    t.index ["query_id", "occurred_at"], name: "index_rails_pulse_operations_on_query_and_time"
    t.index ["query_id"], name: "index_rails_pulse_operations_on_query_id"
    t.index ["request_id"], name: "index_rails_pulse_operations_on_request_id"
  end

  create_table "rails_pulse_queries", force: :cascade do |t|
    t.datetime "analyzed_at"
    t.text "backtrace_analysis"
    t.datetime "created_at", null: false
    t.text "explain_plan"
    t.text "index_recommendations"
    t.text "issues"
    t.text "metadata"
    t.text "n_plus_one_analysis"
    t.string "normalized_sql", limit: 1000, null: false
    t.text "query_stats"
    t.text "suggestions"
    t.text "tags"
    t.datetime "updated_at", null: false
    t.index ["normalized_sql"], name: "index_rails_pulse_queries_on_normalized_sql", unique: true
  end

  create_table "rails_pulse_requests", force: :cascade do |t|
    t.string "controller_action"
    t.datetime "created_at", null: false
    t.decimal "duration", precision: 15, scale: 6, null: false
    t.boolean "is_error", default: false, null: false
    t.datetime "occurred_at", null: false
    t.string "request_uuid", null: false
    t.integer "route_id", null: false
    t.integer "status", null: false
    t.text "tags"
    t.datetime "updated_at", null: false
    t.index ["created_at", "route_id"], name: "idx_requests_for_aggregation"
    t.index ["created_at"], name: "idx_requests_created_at"
    t.index ["occurred_at"], name: "index_rails_pulse_requests_on_occurred_at"
    t.index ["request_uuid"], name: "index_rails_pulse_requests_on_request_uuid", unique: true
    t.index ["route_id", "occurred_at"], name: "index_rails_pulse_requests_on_route_id_and_occurred_at"
    t.index ["route_id"], name: "index_rails_pulse_requests_on_route_id"
  end

  create_table "rails_pulse_routes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "method", null: false
    t.string "path", null: false
    t.text "tags"
    t.datetime "updated_at", null: false
    t.index ["method", "path"], name: "index_rails_pulse_routes_on_method_and_path", unique: true
  end

  create_table "rails_pulse_summaries", force: :cascade do |t|
    t.float "avg_duration"
    t.integer "count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "error_count", default: 0
    t.float "max_duration"
    t.float "min_duration"
    t.float "p50_duration"
    t.float "p95_duration"
    t.float "p99_duration"
    t.datetime "period_end", null: false
    t.datetime "period_start", null: false
    t.string "period_type", null: false
    t.integer "status_2xx", default: 0
    t.integer "status_3xx", default: 0
    t.integer "status_4xx", default: 0
    t.integer "status_5xx", default: 0
    t.float "stddev_duration"
    t.integer "success_count", default: 0
    t.integer "summarizable_id", null: false
    t.string "summarizable_type", null: false
    t.float "total_duration"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_rails_pulse_summaries_on_created_at"
    t.index ["period_type", "period_start"], name: "index_rails_pulse_summaries_on_period"
    t.index ["summarizable_type", "summarizable_id", "period_type", "period_start"], name: "idx_pulse_summaries_unique", unique: true
    t.index ["summarizable_type", "summarizable_id"], name: "index_rails_pulse_summaries_on_summarizable"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.text "custom_css"
    t.text "description"
    t.text "giscus"
    t.text "head_code"
    t.text "social_links"
    t.text "static_files"
    t.string "time_zone", default: "UTC"
    t.string "title"
    t.text "tool_code"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "social_media_posts", force: :cascade do |t|
    t.integer "article_id", null: false
    t.datetime "created_at", null: false
    t.string "platform", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["article_id", "platform"], name: "index_social_media_posts_on_article_id_and_platform", unique: true
    t.index ["article_id"], name: "index_social_media_posts_on_article_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "user_name", null: false
    t.index ["user_name"], name: "index_users_on_user_name", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "rails_pulse_operations", "rails_pulse_queries", column: "query_id"
  add_foreign_key "rails_pulse_operations", "rails_pulse_requests", column: "request_id"
  add_foreign_key "rails_pulse_requests", "rails_pulse_routes", column: "route_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "social_media_posts", "articles"
end
