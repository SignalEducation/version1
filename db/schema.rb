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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141104092630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exam_levels", force: true do |t|
    t.integer  "qualification_id"
    t.string   "name"
    t.string   "name_url"
    t.boolean  "is_cpd",                            default: false, null: false
    t.integer  "sorting_order"
    t.boolean  "active",                            default: false, null: false
    t.float    "best_possible_first_attempt_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "institutions", force: true do |t|
    t.string   "name"
    t.string   "short_name"
    t.string   "name_url"
    t.text     "description"
    t.string   "feedback_url"
    t.string   "help_desk_url"
    t.integer  "subject_area_id"
    t.integer  "sorting_order"
    t.boolean  "active",          default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subject_areas", force: true do |t|
    t.string   "name"
    t.string   "name_url"
    t.integer  "sorting_order"
    t.boolean  "active",        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_groups", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "individual_student",                   default: false, null: false
    t.boolean  "corporate_student",                    default: false, null: false
    t.boolean  "tutor",                                default: false, null: false
    t.boolean  "content_manager",                      default: false, null: false
    t.boolean  "blogger",                              default: false, null: false
    t.boolean  "corporate_customer",                   default: false, null: false
    t.boolean  "site_admin",                           default: false, null: false
    t.boolean  "forum_manager",                        default: false, null: false
    t.boolean  "subscription_required_at_sign_up",     default: false, null: false
    t.boolean  "subscription_required_to_see_content", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "address"
    t.integer  "country_id"
    t.string   "crypted_password",                         limit: 128, default: "",    null: false
    t.string   "password_salt",                            limit: 128, default: "",    null: false
    t.string   "persistence_token"
    t.string   "perishable_token",                         limit: 128
    t.string   "single_access_token"
    t.integer  "login_count",                                          default: 0
    t.integer  "failed_login_count",                                   default: 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "account_activation_code"
    t.datetime "account_activated_at"
    t.boolean  "active",                                               default: false, null: false
    t.integer  "user_group_id"
    t.datetime "password_reset_requested_at"
    t.string   "password_reset_token"
    t.datetime "password_reset_at"
    t.string   "stripe_customer_id"
    t.integer  "corporate_customer_id"
    t.integer  "corporate_customer_user_group_id"
    t.string   "operational_email_frequency"
    t.string   "study_plan_notifications_email_frequency"
    t.string   "falling_behind_email_alert_frequency"
    t.string   "marketing_email_frequency"
    t.datetime "marketing_email_permission_given_at"
    t.string   "blog_notification_email_frequency"
    t.string   "forum_notification_email_frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
