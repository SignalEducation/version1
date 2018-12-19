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

ActiveRecord::Schema.define(version: 20181214200008) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.text     "properties"
    t.datetime "time"
  end

  add_index "ahoy_events", ["time"], name: "index_ahoy_events_on_time", using: :btree
  add_index "ahoy_events", ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
  add_index "ahoy_events", ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree

  create_table "blazer_audits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "query_id"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "query_id"
    t.string   "state"
    t.string   "schedule"
    t.text     "emails"
    t.string   "check_type"
    t.text     "message"
    t.datetime "last_run_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.integer  "dashboard_id"
    t.integer  "query_id"
    t.integer  "position"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.integer  "creator_id"
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.text     "description"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "blog_posts", force: :cascade do |t|
    t.integer  "home_page_id"
    t.integer  "sorting_order"
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "blog_posts", ["home_page_id"], name: "index_blog_posts_on_home_page_id", using: :btree

  create_table "charges", force: :cascade do |t|
    t.integer  "subscription_id"
    t.integer  "invoice_id"
    t.integer  "user_id"
    t.integer  "subscription_payment_card_id"
    t.integer  "currency_id"
    t.integer  "coupon_id"
    t.integer  "stripe_api_event_id"
    t.string   "stripe_guid"
    t.integer  "amount"
    t.integer  "amount_refunded"
    t.string   "failure_code"
    t.text     "failure_message"
    t.string   "stripe_customer_id"
    t.string   "stripe_invoice_id"
    t.boolean  "livemode",                     default: false
    t.string   "stripe_order_id"
    t.boolean  "paid",                         default: false
    t.boolean  "refunded",                     default: false
    t.text     "stripe_refunds_data"
    t.string   "status"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.text     "original_event_data"
  end

  add_index "charges", ["coupon_id"], name: "index_charges_on_coupon_id", using: :btree
  add_index "charges", ["currency_id"], name: "index_charges_on_currency_id", using: :btree
  add_index "charges", ["invoice_id"], name: "index_charges_on_invoice_id", using: :btree
  add_index "charges", ["paid"], name: "index_charges_on_paid", using: :btree
  add_index "charges", ["refunded"], name: "index_charges_on_refunded", using: :btree
  add_index "charges", ["status"], name: "index_charges_on_status", using: :btree
  add_index "charges", ["stripe_api_event_id"], name: "index_charges_on_stripe_api_event_id", using: :btree
  add_index "charges", ["subscription_id"], name: "index_charges_on_subscription_id", using: :btree
  add_index "charges", ["subscription_payment_card_id"], name: "index_charges_on_subscription_payment_card_id", using: :btree
  add_index "charges", ["user_id"], name: "index_charges_on_user_id", using: :btree

  create_table "constructed_response_attempts", force: :cascade do |t|
    t.integer  "constructed_response_id"
    t.integer  "scenario_id"
    t.integer  "course_module_element_id"
    t.integer  "course_module_element_user_log_id"
    t.integer  "user_id"
    t.text     "original_scenario_text_content"
    t.text     "user_edited_scenario_text_content"
    t.string   "status"
    t.boolean  "flagged_for_review",                default: false
    t.integer  "time_in_seconds"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "guid"
    t.text     "scratch_pad_text"
  end

  add_index "constructed_response_attempts", ["constructed_response_id"], name: "index_constructed_response_attempts_on_constructed_response_id", using: :btree
  add_index "constructed_response_attempts", ["course_module_element_id"], name: "index_constructed_response_attempts_on_course_module_element_id", using: :btree
  add_index "constructed_response_attempts", ["flagged_for_review"], name: "index_constructed_response_attempts_on_flagged_for_review", using: :btree
  add_index "constructed_response_attempts", ["scenario_id"], name: "index_constructed_response_attempts_on_scenario_id", using: :btree
  add_index "constructed_response_attempts", ["user_id"], name: "index_constructed_response_attempts_on_user_id", using: :btree

  create_table "constructed_responses", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "time_allowed"
    t.datetime "destroyed_at"
  end

  add_index "constructed_responses", ["course_module_element_id"], name: "index_constructed_responses_on_course_module_element_id", using: :btree

  create_table "content_page_sections", force: :cascade do |t|
    t.integer  "content_page_id"
    t.text     "text_content"
    t.string   "panel_colour"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "subject_course_id"
    t.integer  "sorting_order"
  end

  create_table "content_pages", force: :cascade do |t|
    t.string   "name"
    t.string   "public_url"
    t.string   "seo_title"
    t.text     "seo_description"
    t.text     "text_content"
    t.string   "h1_text"
    t.string   "h1_subtext"
    t.string   "nav_type"
    t.boolean  "footer_link",     default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "active",          default: false
  end

  add_index "content_pages", ["footer_link"], name: "index_content_pages_on_footer_link", using: :btree
  add_index "content_pages", ["name"], name: "index_content_pages_on_name", using: :btree
  add_index "content_pages", ["public_url"], name: "index_content_pages_on_public_url", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.string   "iso_code"
    t.string   "country_tld"
    t.integer  "sorting_order"
    t.boolean  "in_the_eu",     default: false, null: false
    t.integer  "currency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "continent"
  end

  add_index "countries", ["currency_id"], name: "index_countries_on_currency_id", using: :btree
  add_index "countries", ["in_the_eu"], name: "index_countries_on_in_the_eu", using: :btree
  add_index "countries", ["name"], name: "index_countries_on_name", using: :btree
  add_index "countries", ["sorting_order"], name: "index_countries_on_sorting_order", using: :btree

  create_table "coupons", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "currency_id"
    t.boolean  "livemode",           default: false
    t.boolean  "active",             default: false
    t.integer  "amount_off"
    t.string   "duration"
    t.integer  "duration_in_months"
    t.integer  "max_redemptions"
    t.integer  "percent_off"
    t.datetime "redeem_by"
    t.integer  "times_redeemed"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "stripe_coupon_data"
  end

  add_index "coupons", ["active"], name: "index_coupons_on_active", using: :btree
  add_index "coupons", ["code"], name: "index_coupons_on_code", using: :btree
  add_index "coupons", ["name"], name: "index_coupons_on_name", using: :btree

  create_table "course_module_element_quizzes", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.integer  "number_of_questions"
    t.string   "question_selection_strategy"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  add_index "course_module_element_quizzes", ["course_module_element_id"], name: "cme_quiz_cme_id", using: :btree

  create_table "course_module_element_resources", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.string   "name"
    t.string   "web_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "destroyed_at"
  end

  add_index "course_module_element_resources", ["course_module_element_id"], name: "cme_resources_cme_id", using: :btree

  create_table "course_module_element_user_logs", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.integer  "user_id"
    t.string   "session_guid"
    t.boolean  "element_completed",          default: false, null: false
    t.integer  "time_taken_in_seconds"
    t.integer  "quiz_score_actual"
    t.integer  "quiz_score_potential"
    t.boolean  "is_video",                   default: false, null: false
    t.boolean  "is_quiz",                    default: false, null: false
    t.integer  "course_module_id"
    t.boolean  "latest_attempt",             default: true,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seconds_watched",            default: 0
    t.integer  "count_of_questions_taken"
    t.integer  "count_of_questions_correct"
    t.integer  "subject_course_id"
    t.integer  "student_exam_track_id"
    t.integer  "subject_course_user_log_id"
    t.boolean  "is_constructed_response",    default: false
    t.boolean  "preview_mode",               default: false
  end

  add_index "course_module_element_user_logs", ["course_module_element_id"], name: "cme_user_logs_cme_id", using: :btree
  add_index "course_module_element_user_logs", ["course_module_id"], name: "index_course_module_element_user_logs_on_course_module_id", using: :btree
  add_index "course_module_element_user_logs", ["user_id"], name: "index_course_module_element_user_logs_on_user_id", using: :btree

  create_table "course_module_element_videos", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.string   "video_id"
    t.float    "duration"
    t.string   "vimeo_guid"
  end

  add_index "course_module_element_videos", ["course_module_element_id"], name: "index_course_module_element_videos_on_course_module_element_id", using: :btree

  create_table "course_module_elements", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.text     "description"
    t.integer  "estimated_time_in_seconds"
    t.integer  "course_module_id"
    t.integer  "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_video",                  default: false, null: false
    t.boolean  "is_quiz",                   default: false, null: false
    t.boolean  "active",                    default: true,  null: false
    t.string   "seo_description"
    t.boolean  "seo_no_index",              default: false
    t.datetime "destroyed_at"
    t.integer  "number_of_questions",       default: 0
    t.float    "duration",                  default: 0.0
    t.string   "temporary_label"
    t.boolean  "is_constructed_response",   default: false, null: false
  end

  add_index "course_module_elements", ["course_module_id"], name: "index_course_module_elements_on_course_module_id", using: :btree
  add_index "course_module_elements", ["name_url"], name: "index_course_module_elements_on_name_url", using: :btree

  create_table "course_modules", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.text     "description"
    t.integer  "sorting_order"
    t.integer  "estimated_time_in_seconds"
    t.boolean  "active",                    default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cme_count",                 default: 0
    t.string   "seo_description"
    t.boolean  "seo_no_index",              default: false
    t.datetime "destroyed_at"
    t.integer  "number_of_questions",       default: 0
    t.integer  "subject_course_id"
    t.float    "video_duration",            default: 0.0
    t.integer  "video_count",               default: 0
    t.integer  "quiz_count",                default: 0
    t.string   "highlight_colour"
    t.boolean  "tuition",                   default: false
    t.boolean  "test",                      default: false
    t.boolean  "revision",                  default: false
  end

  add_index "course_modules", ["name_url"], name: "index_course_modules_on_name_url", using: :btree
  add_index "course_modules", ["sorting_order"], name: "index_course_modules_on_sorting_order", using: :btree

  create_table "course_tutor_details", force: :cascade do |t|
    t.integer  "subject_course_id"
    t.integer  "user_id"
    t.integer  "sorting_order"
    t.string   "title"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "course_tutor_details", ["subject_course_id"], name: "index_course_tutor_details_on_subject_course_id", using: :btree
  add_index "course_tutor_details", ["user_id"], name: "index_course_tutor_details_on_user_id", using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string   "iso_code"
    t.string   "name"
    t.string   "leading_symbol"
    t.string   "trailing_symbol"
    t.boolean  "active",          default: false, null: false
    t.integer  "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["active"], name: "index_currencies_on_active", using: :btree
  add_index "currencies", ["iso_code"], name: "index_currencies_on_iso_code", using: :btree
  add_index "currencies", ["sorting_order"], name: "index_currencies_on_sorting_order", using: :btree

  create_table "enrollments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "subject_course_id"
    t.integer  "subject_course_user_log_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "active",                     default: false
    t.integer  "exam_body_id"
    t.date     "exam_date"
    t.boolean  "expired",                    default: false
    t.boolean  "paused",                     default: false
    t.boolean  "notifications",              default: true
    t.integer  "exam_sitting_id"
    t.boolean  "computer_based_exam",        default: false
    t.integer  "percentage_complete",        default: 0
  end

  create_table "exam_bodies", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "modal_heading"
    t.text     "modal_text"
  end

  add_index "exam_bodies", ["name"], name: "index_exam_bodies_on_name", using: :btree

  create_table "exam_sittings", force: :cascade do |t|
    t.string   "name"
    t.integer  "subject_course_id"
    t.date     "date"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "exam_body_id"
    t.boolean  "active",            default: true
    t.boolean  "computer_based",    default: false
  end

  add_index "exam_sittings", ["date"], name: "index_exam_sittings_on_date", using: :btree
  add_index "exam_sittings", ["name"], name: "index_exam_sittings_on_name", using: :btree
  add_index "exam_sittings", ["subject_course_id"], name: "index_exam_sittings_on_subject_course_id", using: :btree

  create_table "external_banners", force: :cascade do |t|
    t.string   "name"
    t.integer  "sorting_order"
    t.boolean  "active",             default: false
    t.string   "background_colour"
    t.text     "text_content"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "user_sessions",      default: false
    t.boolean  "library",            default: false
    t.boolean  "subscription_plans", default: false
    t.boolean  "footer_pages",       default: false
    t.boolean  "student_sign_ups",   default: false
    t.integer  "home_page_id"
    t.integer  "content_page_id"
  end

  add_index "external_banners", ["active"], name: "index_external_banners_on_active", using: :btree
  add_index "external_banners", ["name"], name: "index_external_banners_on_name", using: :btree

  create_table "faq_sections", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.text     "description"
    t.boolean  "active",        default: true
    t.integer  "sorting_order"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "faq_sections", ["active"], name: "index_faq_sections_on_active", using: :btree
  add_index "faq_sections", ["name"], name: "index_faq_sections_on_name", using: :btree
  add_index "faq_sections", ["name_url"], name: "index_faq_sections_on_name_url", using: :btree
  add_index "faq_sections", ["sorting_order"], name: "index_faq_sections_on_sorting_order", using: :btree

  create_table "faqs", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.boolean  "active",          default: true
    t.integer  "sorting_order"
    t.integer  "faq_section_id"
    t.text     "question_text"
    t.text     "answer_text"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "pre_answer_text"
  end

  add_index "faqs", ["active"], name: "index_faqs_on_active", using: :btree
  add_index "faqs", ["faq_section_id"], name: "index_faqs_on_faq_section_id", using: :btree
  add_index "faqs", ["name"], name: "index_faqs_on_name", using: :btree
  add_index "faqs", ["name_url"], name: "index_faqs_on_name_url", using: :btree
  add_index "faqs", ["question_text"], name: "index_faqs_on_question_text", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.boolean  "active",                        default: false, null: false
    t.integer  "sorting_order"
    t.text     "description"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.datetime "destroyed_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "background_image_file_name"
    t.string   "background_image_content_type"
    t.integer  "background_image_file_size"
    t.datetime "background_image_updated_at"
  end

  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree

  create_table "groups_subject_courses", id: false, force: :cascade do |t|
    t.integer "group_id",          null: false
    t.integer "subject_course_id", null: false
  end

  add_index "groups_subject_courses", ["group_id"], name: "index_groups_subject_courses_on_group_id", using: :btree
  add_index "groups_subject_courses", ["subject_course_id"], name: "index_groups_subject_courses_on_subject_course_id", using: :btree

  create_table "home_pages", force: :cascade do |t|
    t.string   "seo_title"
    t.string   "seo_description"
    t.integer  "subscription_plan_category_id"
    t.string   "public_url"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "subject_course_id"
    t.string   "custom_file_name"
    t.integer  "group_id"
    t.string   "name"
    t.boolean  "home",                          default: false
    t.string   "header_heading"
    t.text     "header_paragraph"
    t.string   "header_button_text"
    t.string   "background_image"
    t.string   "header_button_link"
    t.string   "header_button_subtext"
    t.boolean  "footer_link",                   default: false
    t.string   "mailchimp_list_guid"
    t.string   "mailchimp_section_heading"
    t.string   "mailchimp_section_subheading"
    t.boolean  "mailchimp_subscribe_section",   default: false
  end

  add_index "home_pages", ["public_url"], name: "index_home_pages_on_public_url", using: :btree
  add_index "home_pages", ["subscription_plan_category_id"], name: "index_home_pages_on_subscription_plan_category_id", using: :btree

  create_table "import_trackers", force: :cascade do |t|
    t.string   "old_model_name"
    t.integer  "old_model_id"
    t.string   "new_model_name"
    t.integer  "new_model_id"
    t.datetime "imported_at"
    t.text     "original_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "import_trackers", ["imported_at"], name: "index_import_trackers_on_imported_at", using: :btree
  add_index "import_trackers", ["new_model_id"], name: "index_import_trackers_on_new_model_id", using: :btree
  add_index "import_trackers", ["new_model_name"], name: "index_import_trackers_on_new_model_name", using: :btree
  add_index "import_trackers", ["old_model_id"], name: "index_import_trackers_on_old_model_id", using: :btree
  add_index "import_trackers", ["old_model_name"], name: "index_import_trackers_on_old_model_name", using: :btree

  create_table "invoice_line_items", force: :cascade do |t|
    t.integer  "invoice_id"
    t.decimal  "amount"
    t.integer  "currency_id"
    t.boolean  "prorated"
    t.datetime "period_start_at"
    t.datetime "period_end_at"
    t.integer  "subscription_id"
    t.integer  "subscription_plan_id"
    t.text     "original_stripe_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoice_line_items", ["currency_id"], name: "index_invoice_line_items_on_currency_id", using: :btree
  add_index "invoice_line_items", ["invoice_id"], name: "index_invoice_line_items_on_invoice_id", using: :btree
  add_index "invoice_line_items", ["period_end_at"], name: "index_invoice_line_items_on_period_end_at", using: :btree
  add_index "invoice_line_items", ["period_start_at"], name: "index_invoice_line_items_on_period_start_at", using: :btree
  add_index "invoice_line_items", ["subscription_id"], name: "index_invoice_line_items_on_subscription_id", using: :btree
  add_index "invoice_line_items", ["subscription_plan_id"], name: "index_invoice_line_items_on_subscription_plan_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "subscription_transaction_id"
    t.integer  "subscription_id"
    t.integer  "number_of_users"
    t.integer  "currency_id"
    t.integer  "vat_rate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "issued_at"
    t.string   "stripe_guid"
    t.decimal  "sub_total",                   default: 0.0
    t.decimal  "total",                       default: 0.0
    t.decimal  "total_tax",                   default: 0.0
    t.string   "stripe_customer_guid"
    t.string   "object_type",                 default: "invoice"
    t.boolean  "payment_attempted",           default: false
    t.boolean  "payment_closed",              default: false
    t.boolean  "forgiven",                    default: false
    t.boolean  "paid",                        default: false
    t.boolean  "livemode",                    default: false
    t.integer  "attempt_count",               default: 0
    t.decimal  "amount_due",                  default: 0.0
    t.datetime "next_payment_attempt_at"
    t.datetime "webhooks_delivered_at"
    t.string   "charge_guid"
    t.string   "subscription_guid"
    t.decimal  "tax_percent"
    t.decimal  "tax"
    t.text     "original_stripe_data"
    t.string   "paypal_payment_guid"
  end

  add_index "invoices", ["currency_id"], name: "index_invoices_on_currency_id", using: :btree
  add_index "invoices", ["subscription_id"], name: "index_invoices_on_subscription_id", using: :btree
  add_index "invoices", ["subscription_transaction_id"], name: "index_invoices_on_subscription_transaction_id", using: :btree
  add_index "invoices", ["user_id"], name: "index_invoices_on_user_id", using: :btree
  add_index "invoices", ["vat_rate_id"], name: "index_invoices_on_vat_rate_id", using: :btree

  create_table "ip_addresses", force: :cascade do |t|
    t.string   "ip_address"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "country_id"
    t.integer  "alert_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ip_addresses", ["country_id"], name: "index_ip_addresses_on_country_id", using: :btree
  add_index "ip_addresses", ["ip_address"], name: "index_ip_addresses_on_ip_address", using: :btree
  add_index "ip_addresses", ["latitude"], name: "index_ip_addresses_on_latitude", using: :btree
  add_index "ip_addresses", ["longitude"], name: "index_ip_addresses_on_longitude", using: :btree

  create_table "mock_exams", force: :cascade do |t|
    t.integer  "subject_course_id"
    t.integer  "product_id"
    t.string   "name"
    t.integer  "sorting_order"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "cover_image_file_name"
    t.string   "cover_image_content_type"
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
  end

  add_index "mock_exams", ["name"], name: "index_mock_exams_on_name", using: :btree
  add_index "mock_exams", ["product_id"], name: "index_mock_exams_on_product_id", using: :btree
  add_index "mock_exams", ["subject_course_id"], name: "index_mock_exams_on_subject_course_id", using: :btree

  create_table "order_transactions", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.integer  "product_id"
    t.string   "stripe_order_id"
    t.string   "stripe_charge_id"
    t.boolean  "live_mode",        default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "order_transactions", ["order_id"], name: "index_order_transactions_on_order_id", using: :btree
  add_index "order_transactions", ["product_id"], name: "index_order_transactions_on_product_id", using: :btree
  add_index "order_transactions", ["stripe_charge_id"], name: "index_order_transactions_on_stripe_charge_id", using: :btree
  add_index "order_transactions", ["stripe_order_id"], name: "index_order_transactions_on_stripe_order_id", using: :btree
  add_index "order_transactions", ["user_id"], name: "index_order_transactions_on_user_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "subject_course_id"
    t.integer  "user_id"
    t.string   "stripe_guid"
    t.string   "stripe_customer_id"
    t.boolean  "live_mode",                 default: false
    t.string   "stripe_status"
    t.string   "coupon_code"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "stripe_order_payment_data"
    t.integer  "mock_exam_id"
    t.boolean  "terms_and_conditions",      default: false
    t.string   "reference_guid"
    t.string   "paypal_guid"
    t.string   "paypal_status"
  end

  add_index "orders", ["product_id"], name: "index_orders_on_product_id", using: :btree
  add_index "orders", ["stripe_customer_id"], name: "index_orders_on_stripe_customer_id", using: :btree
  add_index "orders", ["stripe_guid"], name: "index_orders_on_stripe_guid", using: :btree
  add_index "orders", ["subject_course_id"], name: "index_orders_on_subject_course_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "paypal_webhooks", force: :cascade do |t|
    t.string   "guid"
    t.string   "event_type"
    t.text     "payload"
    t.datetime "processed_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "verified",     default: true
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "mock_exam_id"
    t.string   "stripe_guid"
    t.boolean  "live_mode",         default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "active",            default: false
    t.integer  "currency_id"
    t.decimal  "price"
    t.string   "stripe_sku_guid"
    t.integer  "subject_course_id"
    t.integer  "sorting_order"
  end

  add_index "products", ["mock_exam_id"], name: "index_products_on_mock_exam_id", using: :btree
  add_index "products", ["name"], name: "index_products_on_name", using: :btree
  add_index "products", ["stripe_guid"], name: "index_products_on_stripe_guid", using: :btree

  create_table "quiz_answers", force: :cascade do |t|
    t.integer  "quiz_question_id"
    t.boolean  "correct",             default: false, null: false
    t.string   "degree_of_wrongness"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  add_index "quiz_answers", ["degree_of_wrongness"], name: "index_quiz_answers_on_degree_of_wrongness", using: :btree
  add_index "quiz_answers", ["quiz_question_id"], name: "index_quiz_answers_on_quiz_question_id", using: :btree

  create_table "quiz_attempts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "quiz_question_id"
    t.integer  "quiz_answer_id"
    t.boolean  "correct",                           default: false, null: false
    t.integer  "course_module_element_user_log_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score",                             default: 0
    t.string   "answer_array"
  end

  add_index "quiz_attempts", ["course_module_element_user_log_id"], name: "index_quiz_attempts_on_course_module_element_user_log_id", using: :btree
  add_index "quiz_attempts", ["quiz_answer_id"], name: "index_quiz_attempts_on_quiz_answer_id", using: :btree
  add_index "quiz_attempts", ["quiz_question_id"], name: "index_quiz_attempts_on_quiz_question_id", using: :btree
  add_index "quiz_attempts", ["user_id"], name: "index_quiz_attempts_on_user_id", using: :btree

  create_table "quiz_contents", force: :cascade do |t|
    t.integer  "quiz_question_id"
    t.integer  "quiz_answer_id"
    t.text     "text_content"
    t.integer  "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "quiz_solution_id"
    t.datetime "destroyed_at"
  end

  add_index "quiz_contents", ["quiz_answer_id"], name: "index_quiz_contents_on_quiz_answer_id", using: :btree
  add_index "quiz_contents", ["quiz_question_id"], name: "index_quiz_contents_on_quiz_question_id", using: :btree

  create_table "quiz_questions", force: :cascade do |t|
    t.integer  "course_module_element_quiz_id"
    t.integer  "course_module_element_id"
    t.string   "difficulty_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.integer  "subject_course_id"
    t.integer  "sorting_order"
    t.boolean  "custom_styles",                 default: false
  end

  add_index "quiz_questions", ["course_module_element_id"], name: "index_quiz_questions_on_course_module_element_id", using: :btree
  add_index "quiz_questions", ["course_module_element_quiz_id"], name: "index_quiz_questions_on_course_module_element_quiz_id", using: :btree
  add_index "quiz_questions", ["difficulty_level"], name: "index_quiz_questions_on_difficulty_level", using: :btree

  create_table "referral_codes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "code",       limit: 7
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "referral_codes", ["user_id"], name: "index_referral_codes_on_user_id", using: :btree

  create_table "referred_signups", force: :cascade do |t|
    t.integer  "referral_code_id"
    t.integer  "user_id"
    t.string   "referrer_url",     limit: 2048
    t.integer  "subscription_id"
    t.datetime "maturing_on"
    t.datetime "payed_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "referred_signups", ["referral_code_id"], name: "index_referred_signups_on_referral_code_id", using: :btree
  add_index "referred_signups", ["subscription_id"], name: "index_referred_signups_on_subscription_id", using: :btree
  add_index "referred_signups", ["user_id"], name: "index_referred_signups_on_user_id", using: :btree

  create_table "refunds", force: :cascade do |t|
    t.string   "stripe_guid"
    t.integer  "charge_id"
    t.string   "stripe_charge_guid"
    t.integer  "invoice_id"
    t.integer  "subscription_id"
    t.integer  "user_id"
    t.integer  "manager_id"
    t.integer  "amount"
    t.text     "reason"
    t.string   "status"
    t.boolean  "livemode",           default: true
    t.text     "stripe_refund_data"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "refunds", ["charge_id"], name: "index_refunds_on_charge_id", using: :btree
  add_index "refunds", ["invoice_id"], name: "index_refunds_on_invoice_id", using: :btree
  add_index "refunds", ["manager_id"], name: "index_refunds_on_manager_id", using: :btree
  add_index "refunds", ["status"], name: "index_refunds_on_status", using: :btree
  add_index "refunds", ["subscription_id"], name: "index_refunds_on_subscription_id", using: :btree
  add_index "refunds", ["user_id"], name: "index_refunds_on_user_id", using: :btree

  create_table "scenario_answer_attempts", force: :cascade do |t|
    t.integer  "scenario_question_attempt_id"
    t.integer  "user_id"
    t.integer  "scenario_answer_template_id"
    t.text     "original_answer_template_text"
    t.text     "user_edited_answer_template_text"
    t.string   "editor_type"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "sorting_order"
  end

  create_table "scenario_answer_templates", force: :cascade do |t|
    t.integer  "scenario_question_id"
    t.integer  "sorting_order"
    t.string   "editor_type"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "destroyed_at"
    t.text     "text_editor_content"
    t.text     "spreadsheet_editor_content"
  end

  add_index "scenario_answer_templates", ["scenario_question_id"], name: "index_scenario_answer_templates_on_scenario_question_id", using: :btree

  create_table "scenario_question_attempts", force: :cascade do |t|
    t.integer  "constructed_response_attempt_id"
    t.integer  "user_id"
    t.integer  "scenario_question_id"
    t.string   "status"
    t.boolean  "flagged_for_review",                 default: false
    t.text     "original_scenario_question_text"
    t.text     "user_edited_scenario_question_text"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "sorting_order"
  end

  add_index "scenario_question_attempts", ["flagged_for_review"], name: "index_scenario_question_attempts_on_flagged_for_review", using: :btree
  add_index "scenario_question_attempts", ["scenario_question_id"], name: "index_scenario_question_attempts_on_scenario_question_id", using: :btree

  create_table "scenario_questions", force: :cascade do |t|
    t.integer  "scenario_id"
    t.integer  "sorting_order"
    t.text     "text_content"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "destroyed_at"
  end

  add_index "scenario_questions", ["scenario_id"], name: "index_scenario_questions_on_scenario_id", using: :btree

  create_table "scenarios", force: :cascade do |t|
    t.integer  "constructed_response_id"
    t.integer  "sorting_order"
    t.text     "text_content"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "destroyed_at"
  end

  add_index "scenarios", ["constructed_response_id"], name: "index_scenarios_on_constructed_response_id", using: :btree

  create_table "stripe_api_events", force: :cascade do |t|
    t.string   "guid"
    t.string   "api_version"
    t.text     "payload"
    t.boolean  "processed",     default: false, null: false
    t.datetime "processed_at"
    t.boolean  "error",         default: false, null: false
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stripe_api_events", ["api_version"], name: "index_stripe_api_events_on_api_version", using: :btree
  add_index "stripe_api_events", ["error"], name: "index_stripe_api_events_on_error", using: :btree
  add_index "stripe_api_events", ["guid"], name: "index_stripe_api_events_on_guid", using: :btree
  add_index "stripe_api_events", ["processed"], name: "index_stripe_api_events_on_processed", using: :btree
  add_index "stripe_api_events", ["processed_at"], name: "index_stripe_api_events_on_processed_at", using: :btree

  create_table "student_accesses", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "trial_started_date"
    t.datetime "trial_ending_at_date"
    t.datetime "trial_ended_date"
    t.integer  "trial_seconds_limit"
    t.integer  "trial_days_limit"
    t.integer  "content_seconds_consumed", default: 0
    t.integer  "subscription_id"
    t.string   "account_type"
    t.boolean  "content_access",           default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "student_accesses", ["account_type"], name: "index_student_accesses_on_account_type", using: :btree
  add_index "student_accesses", ["content_access"], name: "index_student_accesses_on_content_access", using: :btree
  add_index "student_accesses", ["content_seconds_consumed"], name: "index_student_accesses_on_content_seconds_consumed", using: :btree
  add_index "student_accesses", ["subscription_id"], name: "index_student_accesses_on_subscription_id", using: :btree
  add_index "student_accesses", ["trial_days_limit"], name: "index_student_accesses_on_trial_days_limit", using: :btree
  add_index "student_accesses", ["trial_seconds_limit"], name: "index_student_accesses_on_trial_seconds_limit", using: :btree

  create_table "student_exam_tracks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "latest_course_module_element_id"
    t.integer  "exam_schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_guid"
    t.integer  "course_module_id"
    t.float    "percentage_complete",                  default: 0.0
    t.integer  "count_of_cmes_completed",              default: 0
    t.integer  "subject_course_id"
    t.integer  "count_of_questions_taken"
    t.integer  "count_of_questions_correct"
    t.integer  "count_of_quizzes_taken"
    t.integer  "count_of_videos_taken"
    t.integer  "subject_course_user_log_id"
    t.integer  "count_of_constructed_responses_taken"
  end

  add_index "student_exam_tracks", ["exam_schedule_id"], name: "index_student_exam_tracks_on_exam_schedule_id", using: :btree
  add_index "student_exam_tracks", ["latest_course_module_element_id"], name: "index_student_exam_tracks_on_latest_course_module_element_id", using: :btree
  add_index "student_exam_tracks", ["user_id"], name: "index_student_exam_tracks_on_user_id", using: :btree

  create_table "subject_course_resources", force: :cascade do |t|
    t.string   "name"
    t.integer  "subject_course_id"
    t.text     "description"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "file_upload_file_name"
    t.string   "file_upload_content_type"
    t.integer  "file_upload_file_size"
    t.datetime "file_upload_updated_at"
    t.string   "external_url"
    t.boolean  "active",                   default: false
    t.integer  "sorting_order"
  end

  add_index "subject_course_resources", ["name"], name: "index_subject_course_resources_on_name", using: :btree
  add_index "subject_course_resources", ["subject_course_id"], name: "index_subject_course_resources_on_subject_course_id", using: :btree

  create_table "subject_course_user_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "session_guid"
    t.integer  "subject_course_id"
    t.integer  "percentage_complete",                  default: 0
    t.integer  "count_of_cmes_completed",              default: 0
    t.integer  "latest_course_module_element_id"
    t.boolean  "completed",                            default: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "count_of_questions_correct"
    t.integer  "count_of_questions_taken"
    t.integer  "count_of_videos_taken"
    t.integer  "count_of_quizzes_taken"
    t.datetime "completed_at"
    t.integer  "count_of_constructed_responses_taken"
  end

  add_index "subject_course_user_logs", ["session_guid"], name: "index_subject_course_user_logs_on_session_guid", using: :btree
  add_index "subject_course_user_logs", ["subject_course_id"], name: "index_subject_course_user_logs_on_subject_course_id", using: :btree
  add_index "subject_course_user_logs", ["user_id"], name: "index_subject_course_user_logs_on_user_id", using: :btree

  create_table "subject_courses", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.integer  "sorting_order"
    t.boolean  "active",                                  default: false,     null: false
    t.integer  "cme_count"
    t.integer  "video_count"
    t.integer  "quiz_count"
    t.integer  "question_count"
    t.text     "description"
    t.string   "short_description"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.float    "best_possible_first_attempt_score"
    t.integer  "default_number_of_possible_exam_answers"
    t.float    "total_video_duration",                    default: 0.0
    t.datetime "destroyed_at"
    t.text     "email_content"
    t.string   "external_url_name"
    t.string   "external_url"
    t.integer  "exam_body_id"
    t.string   "survey_url"
    t.integer  "group_id"
    t.integer  "quiz_pass_rate"
    t.integer  "total_estimated_time_in_seconds"
    t.string   "background_image_file_name"
    t.string   "background_image_content_type"
    t.integer  "background_image_file_size"
    t.datetime "background_image_updated_at"
    t.boolean  "preview",                                 default: false
    t.boolean  "computer_based",                          default: false
    t.string   "highlight_colour",                        default: "#ef475d"
    t.string   "category_label"
    t.string   "additional_text_label"
  end

  add_index "subject_courses", ["name"], name: "index_subject_courses_on_name", using: :btree

  create_table "subscription_payment_cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_card_guid"
    t.string   "status"
    t.string   "brand"
    t.string   "last_4"
    t.integer  "expiry_month"
    t.integer  "expiry_year"
    t.string   "address_line1"
    t.string   "account_country"
    t.integer  "account_country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_object_name"
    t.string   "funding"
    t.string   "cardholder_name"
    t.string   "fingerprint"
    t.string   "cvc_checked"
    t.string   "address_line1_check"
    t.string   "address_zip_check"
    t.string   "dynamic_last4"
    t.string   "customer_guid"
    t.boolean  "is_default_card",     default: false
    t.string   "address_line2"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "address_country"
  end

  add_index "subscription_payment_cards", ["account_country_id"], name: "index_subscription_payment_cards_on_account_country_id", using: :btree
  add_index "subscription_payment_cards", ["stripe_card_guid"], name: "index_subscription_payment_cards_on_stripe_card_guid", using: :btree
  add_index "subscription_payment_cards", ["user_id"], name: "index_subscription_payment_cards_on_user_id", using: :btree

  create_table "subscription_plan_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "available_from"
    t.datetime "available_to"
    t.string   "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trial_period_in_days"
  end

  add_index "subscription_plan_categories", ["available_from"], name: "index_subscription_plan_categories_on_available_from", using: :btree
  add_index "subscription_plan_categories", ["available_to"], name: "index_subscription_plan_categories_on_available_to", using: :btree
  add_index "subscription_plan_categories", ["guid"], name: "index_subscription_plan_categories_on_guid", using: :btree
  add_index "subscription_plan_categories", ["name"], name: "index_subscription_plan_categories_on_name", using: :btree

  create_table "subscription_plans", force: :cascade do |t|
    t.boolean  "available_to_students",         default: false, null: false
    t.boolean  "all_you_can_eat",               default: true,  null: false
    t.integer  "payment_frequency_in_months",   default: 1
    t.integer  "currency_id"
    t.decimal  "price"
    t.date     "available_from"
    t.date     "available_to"
    t.string   "stripe_guid"
    t.integer  "trial_period_in_days",          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "subscription_plan_category_id"
    t.boolean  "livemode",                      default: false
    t.string   "paypal_guid"
    t.string   "paypal_state"
    t.integer  "monthly_percentage_off"
  end

  add_index "subscription_plans", ["available_from"], name: "index_subscription_plans_on_available_from", using: :btree
  add_index "subscription_plans", ["available_to"], name: "index_subscription_plans_on_available_to", using: :btree
  add_index "subscription_plans", ["available_to_students"], name: "index_subscription_plans_on_available_to_students", using: :btree
  add_index "subscription_plans", ["currency_id"], name: "index_subscription_plans_on_currency_id", using: :btree
  add_index "subscription_plans", ["payment_frequency_in_months"], name: "index_subscription_plans_on_payment_frequency_in_months", using: :btree

  create_table "subscription_transactions", force: :cascade do |t|
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

  add_index "subscription_transactions", ["alarm"], name: "index_subscription_transactions_on_alarm", using: :btree
  add_index "subscription_transactions", ["currency_id"], name: "index_subscription_transactions_on_currency_id", using: :btree
  add_index "subscription_transactions", ["live_mode"], name: "index_subscription_transactions_on_live_mode", using: :btree
  add_index "subscription_transactions", ["stripe_transaction_guid"], name: "index_subscription_transactions_on_stripe_transaction_guid", using: :btree
  add_index "subscription_transactions", ["subscription_id"], name: "index_subscription_transactions_on_subscription_id", using: :btree
  add_index "subscription_transactions", ["transaction_type"], name: "index_subscription_transactions_on_transaction_type", using: :btree
  add_index "subscription_transactions", ["user_id"], name: "index_subscription_transactions_on_user_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "subscription_plan_id"
    t.string   "stripe_guid"
    t.date     "next_renewal_date"
    t.boolean  "complimentary",            default: false, null: false
    t.string   "stripe_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_customer_id"
    t.text     "stripe_customer_data"
    t.boolean  "livemode",                 default: false
    t.boolean  "active",                   default: false
    t.boolean  "terms_and_conditions",     default: false
    t.integer  "coupon_id"
    t.string   "paypal_subscription_guid"
    t.string   "paypal_token"
    t.string   "paypal_status"
    t.string   "state"
  end

  add_index "subscriptions", ["next_renewal_date"], name: "index_subscriptions_on_next_renewal_date", using: :btree
  add_index "subscriptions", ["stripe_status"], name: "index_subscriptions_on_stripe_status", using: :btree
  add_index "subscriptions", ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "user_groups", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "tutor",                        default: false, null: false
    t.boolean  "site_admin",                   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "system_requirements_access",   default: false
    t.boolean  "content_management_access",    default: false
    t.boolean  "stripe_management_access",     default: false
    t.boolean  "user_management_access",       default: false
    t.boolean  "developer_access",             default: false
    t.boolean  "user_group_management_access", default: false
    t.boolean  "student_user",                 default: false
    t.boolean  "trial_or_sub_required",        default: false
    t.boolean  "blocked_user",                 default: false
    t.boolean  "marketing_resources_access",   default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "address"
    t.integer  "country_id"
    t.string   "crypted_password",                limit: 128, default: "",    null: false
    t.string   "password_salt",                   limit: 128, default: "",    null: false
    t.string   "persistence_token"
    t.string   "perishable_token",                limit: 128
    t.string   "single_access_token"
    t.integer  "login_count",                                 default: 0
    t.integer  "failed_login_count",                          default: 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "account_activation_code"
    t.datetime "account_activated_at"
    t.boolean  "active",                                      default: false, null: false
    t.integer  "user_group_id"
    t.datetime "password_reset_requested_at"
    t.string   "password_reset_token"
    t.datetime "password_reset_at"
    t.string   "stripe_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale"
    t.string   "guid"
    t.integer  "subscription_plan_category_id"
    t.boolean  "password_change_required"
    t.string   "session_key"
    t.string   "name_url"
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type"
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.string   "email_verification_code"
    t.datetime "email_verified_at"
    t.boolean  "email_verified",                              default: false, null: false
    t.integer  "stripe_account_balance",                      default: 0
    t.boolean  "free_trial",                                  default: false
    t.boolean  "terms_and_conditions",                        default: false
    t.date     "date_of_birth"
    t.text     "description"
    t.string   "analytics_guid"
    t.string   "student_number"
    t.boolean  "unsubscribed_from_emails",                    default: false
    t.boolean  "communication_approval",                      default: false
    t.datetime "communication_approval_datetime"
  end

  add_index "users", ["account_activation_code"], name: "index_users_on_account_activation_code", using: :btree
  add_index "users", ["country_id"], name: "index_users_on_country_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", using: :btree
  add_index "users", ["persistence_token"], name: "index_users_on_persistence_token", using: :btree
  add_index "users", ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", using: :btree
  add_index "users", ["subscription_plan_category_id"], name: "index_users_on_subscription_plan_category_id", using: :btree
  add_index "users", ["user_group_id"], name: "index_users_on_user_group_id", using: :btree

  create_table "vat_codes", force: :cascade do |t|
    t.integer  "country_id"
    t.string   "name"
    t.string   "label"
    t.string   "wiki_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vat_codes", ["country_id"], name: "index_vat_codes_on_country_id", using: :btree

  create_table "vat_rates", force: :cascade do |t|
    t.integer  "vat_code_id"
    t.float    "percentage_rate"
    t.date     "effective_from"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vat_rates", ["vat_code_id"], name: "index_vat_rates_on_vat_code_id", using: :btree

  create_table "video_resources", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.text     "question"
    t.text     "answer"
    t.text     "notes"
    t.datetime "destroyed_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "transcript"
  end

  add_index "video_resources", ["course_module_element_id"], name: "index_video_resources_on_course_module_element_id", using: :btree

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree

  create_table "white_paper_requests", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "number"
    t.string   "company_name"
    t.integer  "white_paper_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "white_paper_requests", ["company_name"], name: "index_white_paper_requests_on_company_name", using: :btree
  add_index "white_paper_requests", ["email"], name: "index_white_paper_requests_on_email", using: :btree
  add_index "white_paper_requests", ["name"], name: "index_white_paper_requests_on_name", using: :btree
  add_index "white_paper_requests", ["number"], name: "index_white_paper_requests_on_number", using: :btree
  add_index "white_paper_requests", ["white_paper_id"], name: "index_white_paper_requests_on_white_paper_id", using: :btree

  create_table "white_papers", force: :cascade do |t|
    t.text     "description"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "sorting_order"
    t.string   "cover_image_file_name"
    t.string   "cover_image_content_type"
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
    t.string   "name_url"
    t.string   "name"
    t.integer  "subject_course_id"
  end

end
