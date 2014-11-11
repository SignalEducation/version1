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

ActiveRecord::Schema.define(version: 20141110180747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "course_module_element_quizzes", force: true do |t|
    t.integer  "course_module_element_id"
    t.string   "name"
    t.text     "preamble"
    t.integer  "expected_time_in_seconds"
    t.integer  "time_limit_seconds"
    t.integer  "number_of_questions"
    t.string   "question_selection_strategy"
    t.integer  "best_possible_score_first_attempt"
    t.integer  "best_possible_score_retry"
    t.integer  "course_module_jumbo_quiz_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_module_element_resources", force: true do |t|
    t.integer  "course_module_element_id"
    t.string   "name"
    t.text     "description"
    t.string   "web_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_module_element_user_logs", force: true do |t|
    t.integer  "course_module_element_id"
    t.integer  "user_id"
    t.string   "session_guid"
    t.boolean  "element_completed",        default: false, null: false
    t.integer  "time_taken_in_seconds"
    t.integer  "quiz_score_actual"
    t.integer  "quiz_score_potential"
    t.boolean  "is_video",                 default: false, null: false
    t.boolean  "is_quiz",                  default: false, null: false
    t.integer  "course_module_id"
    t.boolean  "latest_attempt",           default: true,  null: false
    t.integer  "corporate_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_module_element_videos", force: true do |t|
    t.integer  "course_module_element_id"
    t.integer  "raw_video_file_id"
    t.string   "name"
    t.integer  "run_time_in_seconds"
    t.integer  "tutor_id"
    t.text     "description"
    t.string   "tags"
    t.string   "difficulty_level"
    t.integer  "estimated_study_time_seconds"
    t.text     "transcript"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_module_elements", force: true do |t|
    t.string   "name"
    t.string   "name_url"
    t.text     "description"
    t.integer  "estimated_time_in_seconds"
    t.integer  "course_module_id"
    t.integer  "course_module_element_video_id"
    t.integer  "course_module_element_quiz_id"
    t.integer  "sorting_order"
    t.integer  "forum_topic_id"
    t.integer  "tutor_id"
    t.integer  "related_quiz_id"
    t.integer  "related_video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_module_jumbo_quizzes", force: true do |t|
    t.integer  "course_module_id"
    t.string   "name"
    t.integer  "minimum_question_count_per_quiz"
    t.integer  "maximum_question_count_per_quiz"
    t.integer  "total_number_of_questions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_modules", force: true do |t|
    t.integer  "institution_id"
    t.integer  "qualification_id"
    t.integer  "exam_level_id"
    t.integer  "exam_section_id"
    t.string   "name"
    t.string   "name_url"
    t.text     "description"
    t.integer  "tutor_id"
    t.integer  "sorting_order"
    t.integer  "estimated_time_in_seconds"
    t.boolean  "compulsory",                default: false, null: false
    t.boolean  "active",                    default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currencies", force: true do |t|
    t.string   "iso_code"
    t.string   "name"
    t.string   "leading_symbol"
    t.string   "trailing_symbol"
    t.boolean  "active",          default: false, null: false
    t.integer  "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "exam_sections", force: true do |t|
    t.string   "name"
    t.string   "name_url"
    t.integer  "exam_level_id"
    t.boolean  "active",                            default: false, null: false
    t.integer  "sorting_order"
    t.float    "best_possible_first_attempt_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "institution_users", force: true do |t|
    t.integer  "institution_id"
    t.integer  "user_id"
    t.string   "student_registration_number"
    t.boolean  "student",                     default: false, null: false
    t.boolean  "qualified",                   default: false, null: false
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

  create_table "qualifications", force: true do |t|
    t.integer  "institution_id"
    t.string   "name"
    t.string   "name_url"
    t.integer  "sorting_order"
    t.boolean  "active",                      default: false, null: false
    t.integer  "cpd_hours_required_per_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quiz_answers", force: true do |t|
    t.integer  "quiz_question_id"
    t.boolean  "correct",                       default: false, null: false
    t.string   "degree_of_wrongness"
    t.text     "wrong_answer_explanation_text"
    t.integer  "wrong_answer_video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quiz_attempts", force: true do |t|
    t.integer  "user_id"
    t.integer  "quiz_question_id"
    t.integer  "quiz_answer_id"
    t.boolean  "correct",                           default: false, null: false
    t.integer  "course_module_element_user_log_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quiz_contents", force: true do |t|
    t.integer  "quiz_question_id"
    t.integer  "quiz_answer_id"
    t.text     "text_content"
    t.boolean  "contains_mathjax", null: false
    t.boolean  "contains_image",   null: false
    t.integer  "sorting_order"
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

  create_table "subscription_payment_cards", force: true do |t|
    t.integer  "user_id"
    t.string   "stripe_card_guid"
    t.string   "status"
    t.string   "brand"
    t.string   "last_4"
    t.integer  "expiry_month"
    t.integer  "expiry_year"
    t.string   "billing_address"
    t.string   "billing_country"
    t.integer  "billing_country_id"
    t.string   "account_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_plans", force: true do |t|
    t.boolean  "available_to_students",       default: false, null: false
    t.boolean  "available_to_corporates",     default: false, null: false
    t.boolean  "all_you_can_eat",             default: true,  null: false
    t.integer  "payment_frequency_in_months", default: 1
    t.integer  "currency_id"
    t.decimal  "price"
    t.date     "available_from"
    t.date     "available_to"
    t.string   "stripe_guid"
    t.integer  "trial_period_in_days",        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_transactions", force: true do |t|
    t.integer  "user_id"
    t.integer  "subscription_id"
    t.string   "stripe_transaction_guid"
    t.string   "transaction_type"
    t.decimal  "amount"
    t.integer  "currency_id"
    t.boolean  "alarm",                        default: false, null: false
    t.boolean  "live_mode",                    default: false, null: false
    t.text     "original_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subscription_payment_card_id"
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id"
    t.integer  "corporate_customer_id"
    t.integer  "subscription_plan_id"
    t.string   "stripe_guid"
    t.date     "next_renewal_date"
    t.boolean  "complementary",         default: false, null: false
    t.string   "current_status"
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
