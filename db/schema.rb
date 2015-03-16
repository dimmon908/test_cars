# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140520061212) do

  create_table "action_types", :force => true do |t|
    t.string   "internal_name"
    t.integer  "scope"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "activate_data", :force => true do |t|
    t.string   "token"
    t.string   "code",          :limit => 30
    t.datetime "expire"
    t.integer  "user_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "activate_type", :limit => 10
  end

  add_index "activate_data", ["token"], :name => "index_activate_data_on_token"

  create_table "address_books", :force => true do |t|
    t.integer  "user_id"
    t.string   "public_name"
    t.string   "address"
    t.integer  "sort_order"
    t.boolean  "show"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "address_books", ["user_id"], :name => "index_address_books_on_user_id"

  create_table "apn_bases", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "apn_devices", :force => true do |t|
    t.string   "token",              :default => "", :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "last_registered_at"
  end

  add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token", :unique => true

  create_table "apn_notifications", :force => true do |t|
    t.integer  "device_id",                        :null => false
    t.integer  "errors_nb",         :default => 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "sent_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  create_table "articles", :force => true do |t|
    t.string   "url"
    t.string   "headers"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "token_secret"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "business_infos", :force => true do |t|
    t.string   "name"
    t.string   "type_name",          :limit => 20
    t.integer  "year_in_business"
    t.string   "duns_number"
    t.string   "company_address"
    t.string   "billing_address"
    t.string   "email"
    t.string   "phone",              :limit => 50
    t.integer  "requests_per_month"
    t.integer  "employees"
    t.decimal  "credit_line",                       :precision => 15, :scale => 10
    t.integer  "choose_payment"
    t.boolean  "approve_terms"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.string   "suite",              :limit => 20
    t.string   "zip_code",           :limit => 10
    t.string   "city",               :limit => 100
    t.float    "credit_limit"
    t.float    "credit"
    t.integer  "terms"
  end

  create_table "car_photos", :force => true do |t|
    t.integer  "car_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "car_photos", ["car_id"], :name => "index_car_photos_on_car_id"

  create_table "cars", :force => true do |t|
    t.string   "place_number",       :limit => 100
    t.string   "manufacturer",       :limit => 50
    t.string   "model_name",         :limit => 50
    t.integer  "model_year"
    t.string   "color",              :limit => 50
    t.integer  "passenger_capacity"
    t.string   "fuel_type",          :limit => 30
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "status",             :limit => 30
    t.integer  "vehicle_id"
  end

  add_index "cars", ["place_number"], :name => "index_cars_on_place_number", :unique => true
  add_index "cars", ["vehicle_id"], :name => "index_cars_on_vehicles_id"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.string   "code",       :limit => 5
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "cities", ["country_id"], :name => "index_cities_on_country_id"

  create_table "client_activity_histories", :force => true do |t|
    t.integer  "user_id"
    t.datetime "date"
    t.string   "user_type",     :limit => 10
    t.string   "action",        :limit => 20
    t.text     "request"
    t.text     "response"
    t.string   "device_id"
    t.string   "device_system", :limit => 15
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "client_activity_histories", ["action"], :name => "index_client_activity_histories_on_action"
  add_index "client_activity_histories", ["device_id", "device_system"], :name => "index_client_activity_histories_on_device_id_and_device_system"
  add_index "client_activity_histories", ["user_id"], :name => "index_client_activity_histories_on_user_id"
  add_index "client_activity_histories", ["user_type"], :name => "index_client_activity_histories_on_user_type"

  create_table "config_groups", :force => true do |t|
    t.string   "internal_name", :limit => 50
    t.string   "public_name"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "desc"
  end

  create_table "configurations", :force => true do |t|
    t.string   "internal_name"
    t.string   "key",              :limit => 50
    t.binary   "value"
    t.integer  "config_groups_id"
    t.integer  "scope"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "configurations", ["config_groups_id"], :name => "index_configurations_on_config_groups_id"
  add_index "configurations", ["internal_name"], :name => "index_configurations_on_internal_name"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.string   "c"
    t.string   "code",       :limit => 5
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "credit_card_info", :force => true do |t|
    t.string   "card_number",     :limit => 50,  :default => "0",   :null => false
    t.datetime "card_expire",                                       :null => false
    t.string   "cvv",                            :default => "",    :null => false
    t.datetime "checked",                                           :null => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "postal_code"
    t.string   "type_name",       :limit => 50
    t.string   "owner",           :limit => 100
    t.integer  "user_id"
    t.string   "card_hash",       :limit => 50
    t.boolean  "encrypted",                      :default => false
    t.binary   "enc_card_number"
    t.binary   "enc_cvv"
  end

  add_index "credit_card_info", ["user_id"], :name => "index_credit_card_info_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "driver_activity_histories", :force => true do |t|
    t.integer  "driver_id"
    t.string   "status",     :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "driver_activity_histories", ["driver_id"], :name => "index_driver_activity_histories_on_driver_id"

  create_table "driver_car_histories", :force => true do |t|
    t.integer  "driver_id"
    t.integer  "car_id"
    t.string   "status",     :limit => 30
    t.string   "comment"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "driver_car_histories", ["car_id"], :name => "index_driver_car_histories_on_car_id"
  add_index "driver_car_histories", ["driver_id"], :name => "index_driver_car_histories_on_driver_id"

  create_table "driver_request_histories", :force => true do |t|
    t.integer  "request_id"
    t.integer  "driver_id"
    t.string   "status",     :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "driver_request_histories", ["driver_id"], :name => "index_driver_request_histories_on_driver_id"
  add_index "driver_request_histories", ["request_id"], :name => "index_driver_request_histories_on_request_id"

  create_table "drivers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "car_id"
    t.string   "license_number", :limit => 50
    t.datetime "license_expore"
    t.string   "gender",         :limit => 10
    t.string   "age_group",      :limit => 15
    t.string   "second_lang",    :limit => 30
    t.string   "temp_password",  :limit => 50
    t.string   "status",         :limit => 30
    t.boolean  "enabled"
    t.datetime "status_changed"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.float    "rate"
    t.float    "exp"
    t.string   "alt_phone",      :limit => 30
    t.datetime "birthdate"
    t.string   "device_id"
    t.boolean  "online"
    t.string   "device",         :limit => 15
    t.boolean  "lock"
    t.datetime "last_access"
  end

  add_index "drivers", ["car_id"], :name => "index_drivers_on_car_id"
  add_index "drivers", ["online", "status"], :name => "index_drivers_on_online_and_status"
  add_index "drivers", ["online"], :name => "index_drivers_on_online"
  add_index "drivers", ["user_id"], :name => "index_drivers_on_user_id"

  create_table "emails", :force => true do |t|
    t.string   "internal_name"
    t.string   "title"
    t.text     "body_template"
    t.integer  "sort_order"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "body_type",     :limit => 15
    t.text     "desc"
  end

  add_index "emails", ["internal_name"], :name => "index_emails_on_internal_name", :unique => true

  create_table "emails_pulls", :force => true do |t|
    t.integer  "email_id"
    t.integer  "user_id"
    t.text     "params"
    t.string   "status",        :limit => 15,  :default => "new"
    t.datetime "fail_stamp"
    t.datetime "success_stamp"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "to_email",      :limit => 100
  end

  add_index "emails_pulls", ["email_id"], :name => "index_emails_pulls_on_email_id"
  add_index "emails_pulls", ["user_id"], :name => "index_emails_pulls_on_user_id"

  create_table "fares", :force => true do |t|
    t.decimal  "fare",                     :precision => 15, :scale => 10
    t.string   "fare_type",  :limit => 30
    t.boolean  "enabled"
    t.datetime "from"
    t.datetime "to"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.integer  "user_id"
  end

  add_index "fares", ["enabled", "fare_type"], :name => "index_fares_on_enabled_and_fare_type"
  add_index "fares", ["enabled"], :name => "index_fares_on_enabled"
  add_index "fares", ["user_id"], :name => "index_fares_on_user_id"

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "sort_order"
    t.boolean  "enabled"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "street",     :limit => 100
    t.string   "city",       :limit => 100
    t.binary   "additional"
    t.string   "name",       :limit => 100
  end

  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"

  create_table "gcm_devices", :force => true do |t|
    t.string   "registration_id",    :null => false
    t.datetime "last_registered_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "gcm_devices", ["registration_id"], :name => "index_gcm_devices_on_registration_id", :unique => true

  create_table "gcm_notifications", :force => true do |t|
    t.integer  "device_id",        :null => false
    t.string   "collapse_key"
    t.text     "data"
    t.boolean  "delay_while_idle"
    t.datetime "sent_at"
    t.integer  "time_to_live"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "gcm_notifications", ["device_id"], :name => "index_gcm_notifications_on_device_id"

  create_table "locations", :force => true do |t|
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "log_types", :force => true do |t|
    t.integer  "type"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "logs", :force => true do |t|
    t.integer  "user_id"
    t.text     "data"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "log_type",    :limit => 15
    t.string   "title",       :limit => 100
    t.string   "request"
    t.text     "session"
    t.text     "params"
    t.string   "request_url", :limit => 50
  end

  add_index "logs", ["user_id"], :name => "index_logs_on_user_id"

  create_table "notification_pulls", :force => true do |t|
    t.integer  "notification_id"
    t.integer  "user_id"
    t.text     "params"
    t.string   "status",          :limit => 15, :default => "new"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "text_field"
  end

  add_index "notification_pulls", ["notification_id"], :name => "index_notification_pulls_on_notification_id"
  add_index "notification_pulls", ["user_id"], :name => "index_notification_pulls_on_user_id"

  create_table "notifications", :force => true do |t|
    t.string   "internal_name"
    t.text     "body_template"
    t.string   "title"
    t.integer  "scope"
    t.integer  "react"
    t.integer  "lifetime"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.text     "desc"
    t.string   "body_type",     :limit => 15
  end

  add_index "notifications", ["internal_name"], :name => "index_notifications_on_internal_name", :unique => true

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "admin_id"
    t.decimal  "value",                    :precision => 12, :scale => 2
    t.datetime "date"
    t.string   "paid_via",   :limit => 30
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "payments", ["admin_id"], :name => "index_payments_on_admin_id"
  add_index "payments", ["user_id"], :name => "index_payments_on_user_id"

  create_table "promo_code_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "promo_code_id"
    t.integer  "request_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "promo_code_histories", ["promo_code_id"], :name => "index_promo_code_histories_on_promo_code_id"
  add_index "promo_code_histories", ["request_id"], :name => "index_promo_code_histories_on_request_id"
  add_index "promo_code_histories", ["user_id"], :name => "index_promo_code_histories_on_user_id"

  create_table "promo_codes", :force => true do |t|
    t.datetime "from"
    t.datetime "until"
    t.string   "name"
    t.integer  "order_over"
    t.integer  "promo_type"
    t.integer  "value"
    t.integer  "per_user"
    t.integer  "uses_count"
    t.string   "max_uses_number", :limit => 30
    t.boolean  "enabled"
    t.integer  "single"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "code",            :limit => 30
    t.string   "orders_type",     :limit => 15
    t.float    "over_value"
  end

  add_index "promo_codes", ["code"], :name => "index_promo_codes_on_code", :unique => true
  add_index "promo_codes", ["name"], :name => "index_promo_codes_on_name", :unique => true

  create_table "referrers", :force => true do |t|
    t.integer  "user_id"
    t.string   "email",      :limit => 100
    t.string   "provider",   :limit => 30
    t.datetime "sended"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "token"
  end

  add_index "referrers", ["token"], :name => "index_referrers_on_token"
  add_index "referrers", ["user_id"], :name => "index_referrers_on_user_id"

  create_table "reminders", :force => true do |t|
    t.datetime "date"
    t.integer  "user_id"
    t.string   "name",       :limit => 30
    t.string   "rm_hash",    :limit => 50
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "reminders", ["name"], :name => "index_reminders_on_name"
  add_index "reminders", ["user_id"], :name => "index_reminders_on_user_id"

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.datetime "date"
    t.binary   "params"
    t.binary   "results"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "reports", ["name"], :name => "index_reports_on_name"

  create_table "request_cancel_reasons", :force => true do |t|
    t.string   "reason",     :limit => 30
    t.string   "comment"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "request_cancel_reasons", ["reason"], :name => "index_request_cancel_reasons_on_reason", :unique => true

  create_table "requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "driver_id"
    t.integer  "vehicle_id"
    t.string   "status",            :limit => 30
    t.string   "from"
    t.binary   "to"
    t.datetime "date"
    t.decimal  "rate",                             :precision => 12, :scale => 2
    t.integer  "passengers"
    t.float    "luggage"
    t.string   "comment"
    t.string   "reserve_number"
    t.integer  "promo_code_id"
    t.binary   "params"
    t.float    "time"
    t.string   "payment_options",   :limit => 100
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.float    "distance"
    t.binary   "route"
    t.datetime "eta"
    t.datetime "booked"
    t.datetime "start"
    t.datetime "end"
    t.datetime "accepted"
    t.datetime "cancelled"
    t.float    "real_time"
    t.integer  "partner_id"
    t.integer  "cancelled_user_id"
    t.float    "real_distance"
    t.string   "phone",             :limit => 50
    t.integer  "car_id"
    t.boolean  "future_flag"
  end

  add_index "requests", ["cancelled_user_id"], :name => "index_requests_on_cancelled_user_id"
  add_index "requests", ["car_id"], :name => "index_requests_on_car_id"
  add_index "requests", ["driver_id"], :name => "index_requests_on_driver_id"
  add_index "requests", ["partner_id"], :name => "index_requests_on_partner_id"
  add_index "requests", ["phone"], :name => "index_requests_on_phone"
  add_index "requests", ["promo_code_id"], :name => "index_requests_on_promo_code_id"
  add_index "requests", ["status"], :name => "index_requests_on_status"
  add_index "requests", ["user_id"], :name => "index_requests_on_user_id"
  add_index "requests", ["vehicle_id"], :name => "index_requests_on_vehicle_id"

  create_table "roles", :force => true do |t|
    t.string   "internal_name"
    t.text     "description"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["internal_name"], :name => "index_roles_on_internal_name", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sms_messages", :force => true do |t|
    t.string   "internal_name"
    t.string   "title"
    t.text     "body_template"
    t.integer  "sort_order"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.text     "desc"
    t.string   "body_type",     :limit => 15
  end

  add_index "sms_messages", ["internal_name"], :name => "index_sms_messages_on_internal_name", :unique => true

  create_table "sms_messages_pulls", :force => true do |t|
    t.integer  "sms_message_id"
    t.integer  "user_id"
    t.text     "params"
    t.string   "status",         :limit => 15, :default => "new"
    t.datetime "fail_stamp"
    t.datetime "success_stamp"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "to_phone",       :limit => 50
    t.string   "to",             :limit => 49
  end

  add_index "sms_messages_pulls", ["sms_message_id"], :name => "index_sms_messages_pulls_on_sms_message_id"
  add_index "sms_messages_pulls", ["user_id"], :name => "index_sms_messages_pulls_on_user_id"

  create_table "swipe_card", :force => true do |t|
    t.string   "track_1",        :default => "", :null => false
    t.string   "track_2",        :default => "", :null => false
    t.string   "track_3",        :default => "", :null => false
    t.string   "track_1_ds",     :default => "", :null => false
    t.string   "track_2_ds",     :default => "", :null => false
    t.string   "track_3_ds",     :default => "", :null => false
    t.string   "track_1_masked", :default => "", :null => false
    t.string   "track_2_masked", :default => "", :null => false
    t.string   "track_3_masked", :default => "", :null => false
    t.string   "masked_tracks",  :default => "", :null => false
    t.string   "sdk_version",    :default => "", :null => false
    t.string   "encode_type",    :default => "", :null => false
    t.string   "magne_print",    :default => "", :null => false
    t.string   "device_serial",  :default => "", :null => false
    t.string   "session_id",     :default => "", :null => false
    t.string   "nap",            :default => "", :null => false
    t.string   "exp_date",       :default => "", :null => false
    t.string   "first_name",     :default => "", :null => false
    t.string   "middle_name",    :default => "", :null => false
    t.string   "last_name",      :default => "", :null => false
    t.string   "ksn",            :default => "", :null => false
    t.integer  "partner_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "terms_applications", :force => true do |t|
    t.integer  "user_id"
    t.datetime "received"
    t.datetime "approved"
    t.integer  "admin_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone_code"
    t.string   "phone"
    t.string   "job_title"
  end

  add_index "terms_applications", ["admin_id"], :name => "index_terms_applications_on_admin_id"
  add_index "terms_applications", ["user_id"], :name => "index_terms_applications_on_user_id"

  create_table "transactions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "request_id"
    t.string   "payment",            :limit => 30
    t.integer  "status"
    t.decimal  "base",                             :precision => 15, :scale => 10
    t.decimal  "tax",                              :precision => 15, :scale => 10
    t.decimal  "penalty",                          :precision => 15, :scale => 10
    t.decimal  "summ",                             :precision => 15, :scale => 10
    t.decimal  "gratuity",                         :precision => 15, :scale => 10
    t.decimal  "total",                            :precision => 15, :scale => 10
    t.decimal  "paid",                             :precision => 15, :scale => 10
    t.datetime "paid_stamp"
    t.string   "comment"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "ext_id",             :limit => 8
    t.integer  "partner_id"
    t.string   "authorization_code", :limit => 30
    t.decimal  "promo",                            :precision => 12, :scale => 2
    t.decimal  "spec_gratuity",                    :precision => 12, :scale => 2
    t.decimal  "refund",                           :precision => 12, :scale => 2
    t.datetime "refund_stamp"
    t.decimal  "charged",                          :precision => 12, :scale => 2
  end

  add_index "transactions", ["ext_id"], :name => "index_transactions_on_ext_id"
  add_index "transactions", ["payment"], :name => "index_transactions_on_payment"
  add_index "transactions", ["request_id"], :name => "index_transactions_on_request_id"
  add_index "transactions", ["user_id"], :name => "index_transactions_on_user_id"

  create_table "user_activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "action_type_id"
    t.string   "params"
    t.integer  "status"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "user_activities", ["action_type_id"], :name => "index_user_activities_on_action_type_id"
  add_index "user_activities", ["user_id"], :name => "index_user_activities_on_user_id"

  create_table "user_profile", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "zip_code",           :limit => 10
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "phone_code",         :limit => 60
    t.string   "gender",             :limit => 15
    t.integer  "age"
    t.string   "comments"
    t.binary   "params"
    t.float    "credit_limit"
    t.string   "device_id"
    t.datetime "birth_date"
    t.string   "country",            :limit => 50
    t.string   "payment",            :limit => 30
    t.string   "device",             :limit => 15
    t.boolean  "online"
    t.decimal  "credit",                           :precision => 12, :scale => 2
    t.datetime "last_access"
  end

  add_index "user_profile", ["device_id"], :name => "index_user_profile_on_device_id"

  create_table "user_securities", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count"
    t.datetime "current_sign_in"
    t.datetime "last_sign_in"
    t.datetime "expire_date"
    t.datetime "expire_token"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "user_securities", ["user_id"], :name => "index_user_securities_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",   :null => false
    t.string   "encrypted_password",                   :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0,    :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "username"
    t.string   "phone"
    t.integer  "status"
    t.boolean  "can_receive_request"
    t.string   "old_data"
    t.integer  "card_id"
    t.integer  "role_id"
    t.integer  "business_info_id"
    t.boolean  "approve"
    t.integer  "partner_id"
    t.string   "api_token",              :limit => 50
    t.datetime "token_expire"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "confirmation_token"
    t.string   "unconfirmed_email",      :limit => 50
    t.boolean  "show",                                 :default => true
    t.integer  "swipe_card_id"
  end

  add_index "users", ["business_info_id"], :name => "index_users_on_business_info_id"
  add_index "users", ["card_id"], :name => "index_users_on_card_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["partner_id"], :name => "index_users_on_partner_id"
  add_index "users", ["phone"], :name => "index_users_on_phone", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["role_id"], :name => "index_users_on_role_id"
  add_index "users", ["swipe_card_id"], :name => "index_users_on_swipe_card_id"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "vehicles", :force => true do |t|
    t.string   "photo"
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "sort_order"
    t.float    "rate"
    t.integer  "passengers"
    t.string   "internal_name",   :limit => 20
    t.float    "per_mile",                      :default => 30.0
    t.float    "per_minute",                    :default => 2.0
    t.float    "per_wait_minute",               :default => 0.35
  end

  add_index "vehicles", ["internal_name"], :name => "index_vehicles_on_internal_name"

end
