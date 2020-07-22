# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_22_094420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.bigint "help_request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.bigint "offer_request_id"
    t.index ["deleted_at"], name: "index_chat_rooms_on_deleted_at"
    t.index ["help_request_id"], name: "index_chat_rooms_on_help_request_id"
    t.index ["offer_request_id"], name: "index_chat_rooms_on_offer_request_id"
  end

  create_table "chats", force: :cascade do |t|
    t.text "message"
    t.text "image_path"
    t.bigint "chat_room_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "latitude"
    t.float "longitude"
    t.datetime "deleted_at"
    t.boolean "is_read", default: false
    t.string "type", default: "GeneralChat"
    t.string "image_type"
    t.index ["chat_room_id"], name: "index_chats_on_chat_room_id"
    t.index ["deleted_at"], name: "index_chats_on_deleted_at"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "email"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "help_request_views", force: :cascade do |t|
    t.bigint "help_request_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_help_request_views_on_deleted_at"
    t.index ["help_request_id"], name: "index_help_request_views_on_help_request_id"
    t.index ["user_id"], name: "index_help_request_views_on_user_id"
  end

  create_table "help_requests", force: :cascade do |t|
    t.text "description"
    t.float "price"
    t.bigint "color_status", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "latitude"
    t.float "longitude"
    t.bigint "status", default: 1
    t.datetime "deleted_at"
    t.float "distance_scope"
    t.boolean "is_paid", default: false
    t.index ["deleted_at"], name: "index_help_requests_on_deleted_at"
    t.index ["status"], name: "index_help_requests_on_status"
    t.index ["user_id"], name: "index_help_requests_on_user_id"
  end

  create_table "helpee_request_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "helper_request_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "image_feedbacks", force: :cascade do |t|
    t.bigint "feedback_id", null: false
    t.string "image_type"
    t.string "image_path"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_image_feedbacks_on_deleted_at"
    t.index ["feedback_id"], name: "index_image_feedbacks_on_feedback_id"
  end

  create_table "image_help_requests", force: :cascade do |t|
    t.bigint "help_request_id", null: false
    t.text "image_type"
    t.text "image_path"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_image_help_requests_on_deleted_at"
    t.index ["help_request_id"], name: "index_image_help_requests_on_help_request_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.boolean "is_read", default: false
    t.bigint "help_request_id"
    t.bigint "offer_request_id"
    t.bigint "chat_room_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "chat_id"
    t.datetime "deleted_at"
    t.bigint "rate_id"
    t.boolean "is_offer_rejected", default: false
    t.index ["chat_id"], name: "index_notifications_on_chat_id"
    t.index ["chat_room_id"], name: "index_notifications_on_chat_room_id"
    t.index ["deleted_at"], name: "index_notifications_on_deleted_at"
    t.index ["help_request_id"], name: "index_notifications_on_help_request_id"
    t.index ["offer_request_id"], name: "index_notifications_on_offer_request_id"
    t.index ["rate_id"], name: "index_notifications_on_rate_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "offer_requests", force: :cascade do |t|
    t.text "description"
    t.bigint "help_request_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "helpee_request_status_id", default: 1
    t.bigint "helper_request_status_id", default: 1
    t.float "latitude"
    t.float "longitude"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_offer_requests_on_deleted_at"
    t.index ["help_request_id"], name: "index_offer_requests_on_help_request_id"
    t.index ["helpee_request_status_id"], name: "index_offer_requests_on_helpee_request_status_id"
    t.index ["helper_request_status_id"], name: "index_offer_requests_on_helper_request_status_id"
    t.index ["user_id"], name: "index_offer_requests_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "order_id"
    t.bigint "help_request_id", null: false
    t.integer "amount"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["help_request_id"], name: "index_payments_on_help_request_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "professions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.float "score"
    t.text "comment"
    t.bigint "offer_request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["offer_request_id"], name: "index_rates_on_offer_request_id"
    t.index ["user_id"], name: "index_rates_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "help_request_id", null: false
    t.bigint "offer_request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "comment"
    t.integer "type_id"
    t.index ["help_request_id"], name: "index_reports_on_help_request_id"
    t.index ["offer_request_id"], name: "index_reports_on_offer_request_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "telephone", null: false
    t.string "username", null: false
    t.text "image_type"
    t.text "image_path"
    t.string "auth_token"
    t.bigint "profession_id"
    t.datetime "deleted_at"
    t.string "user_device_id"
    t.boolean "notification_status", default: true
    t.float "green_distance_scope", default: 30.0
    t.float "yellow_distance_scope", default: 30.0
    t.float "red_distance_scope", default: 30.0
    t.boolean "notification_status_green", default: true
    t.boolean "notification_status_yellow", default: true
    t.boolean "notification_status_red", default: true
    t.float "latitude"
    t.float "longitude"
    t.index ["auth_token"], name: "index_users_on_auth_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["profession_id"], name: "index_users_on_profession_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["telephone"], name: "index_users_on_telephone", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_rooms", "help_requests"
  add_foreign_key "chat_rooms", "offer_requests"
  add_foreign_key "chats", "chat_rooms"
  add_foreign_key "chats", "users"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "help_request_views", "help_requests"
  add_foreign_key "help_request_views", "users"
  add_foreign_key "help_requests", "users"
  add_foreign_key "image_feedbacks", "feedbacks"
  add_foreign_key "image_help_requests", "help_requests"
  add_foreign_key "notifications", "chat_rooms"
  add_foreign_key "notifications", "chats"
  add_foreign_key "notifications", "help_requests"
  add_foreign_key "notifications", "offer_requests"
  add_foreign_key "notifications", "rates"
  add_foreign_key "notifications", "users"
  add_foreign_key "offer_requests", "help_requests"
  add_foreign_key "offer_requests", "helpee_request_statuses"
  add_foreign_key "offer_requests", "helper_request_statuses"
  add_foreign_key "offer_requests", "users"
  add_foreign_key "payments", "help_requests"
  add_foreign_key "payments", "users"
  add_foreign_key "rates", "offer_requests"
  add_foreign_key "rates", "users"
  add_foreign_key "reports", "help_requests"
  add_foreign_key "reports", "offer_requests"
  add_foreign_key "users", "professions"
end
