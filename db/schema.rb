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

ActiveRecord::Schema.define(version: 20170110194019) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "completion_certificates", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "subject_course_user_log_id"
    t.string   "guid"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "completion_certificates", ["guid"], name: "index_completion_certificates_on_guid", using: :btree
  add_index "completion_certificates", ["subject_course_user_log_id"], name: "index_completion_certificates_on_subject_course_user_log_id", using: :btree
  add_index "completion_certificates", ["user_id"], name: "index_completion_certificates_on_user_id", using: :btree

  create_table "corporate_customers", force: :cascade do |t|
    t.string   "organisation_name"
    t.text     "address"
    t.integer  "country_id"
    t.boolean  "payments_by_card",     default: false,     null: false
    t.string   "stripe_customer_guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "subdomain"
    t.string   "user_name"
    t.string   "passcode"
    t.string   "external_url"
    t.string   "footer_border_colour", default: "#EFF3F6"
    t.string   "corporate_email"
    t.boolean  "external_logo_link",   default: false
  end

  add_index "corporate_customers", ["country_id"], name: "index_corporate_customers_on_country_id", using: :btree
  add_index "corporate_customers", ["stripe_customer_guid"], name: "index_corporate_customers_on_stripe_customer_guid", using: :btree

  create_table "corporate_group_grants", force: :cascade do |t|
    t.integer  "corporate_group_id"
    t.boolean  "compulsory"
    t.boolean  "restricted"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "subject_course_id"
    t.integer  "group_id"
  end

  add_index "corporate_group_grants", ["corporate_group_id"], name: "index_corporate_group_grants_on_corporate_group_id", using: :btree

  create_table "corporate_groups", force: :cascade do |t|
    t.integer  "corporate_customer_id"
    t.string   "name"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "corporate_manager_id"
  end

  add_index "corporate_groups", ["corporate_customer_id"], name: "index_corporate_groups_on_corporate_customer_id", using: :btree

  create_table "corporate_groups_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "corporate_group_id"
  end

  add_index "corporate_groups_users", ["corporate_group_id"], name: "index_corporate_groups_users_on_corporate_group_id", using: :btree
  add_index "corporate_groups_users", ["user_id"], name: "index_corporate_groups_users_on_user_id", using: :btree

  create_table "corporate_requests", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.string   "company"
    t.string   "email"
    t.string   "phone_number"
    t.string   "website"
    t.text     "personal_message"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "corporate_requests", ["company"], name: "index_corporate_requests_on_company", using: :btree
  add_index "corporate_requests", ["email"], name: "index_corporate_requests_on_email", using: :btree
  add_index "corporate_requests", ["name"], name: "index_corporate_requests_on_name", using: :btree
  add_index "corporate_requests", ["phone_number"], name: "index_corporate_requests_on_phone_number", using: :btree

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

  create_table "course_module_element_quizzes", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.integer  "number_of_questions"
    t.string   "question_selection_strategy"
    t.integer  "best_possible_score_first_attempt"
    t.integer  "best_possible_score_retry"
    t.integer  "course_module_jumbo_quiz_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.boolean  "is_final_quiz",                     default: false
  end

  add_index "course_module_element_quizzes", ["course_module_element_id"], name: "cme_quiz_cme_id", using: :btree
  add_index "course_module_element_quizzes", ["course_module_jumbo_quiz_id"], name: "cme_quiz_cme_jumbo_quiz_id", using: :btree

  create_table "course_module_element_resources", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.string   "name"
    t.text     "description"
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
    t.boolean  "element_completed",           default: false, null: false
    t.integer  "time_taken_in_seconds"
    t.integer  "quiz_score_actual"
    t.integer  "quiz_score_potential"
    t.boolean  "is_video",                    default: false, null: false
    t.boolean  "is_quiz",                     default: false, null: false
    t.integer  "course_module_id"
    t.boolean  "latest_attempt",              default: true,  null: false
    t.integer  "corporate_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "course_module_jumbo_quiz_id"
    t.boolean  "is_jumbo_quiz",               default: false, null: false
    t.integer  "seconds_watched",             default: 0
    t.boolean  "is_question_bank",            default: false, null: false
    t.integer  "question_bank_id"
    t.integer  "count_of_questions_taken"
    t.integer  "count_of_questions_correct"
  end

  add_index "course_module_element_user_logs", ["corporate_customer_id"], name: "cme_user_logs_corporate_customer_id", using: :btree
  add_index "course_module_element_user_logs", ["course_module_element_id"], name: "cme_user_logs_cme_id", using: :btree
  add_index "course_module_element_user_logs", ["course_module_id"], name: "index_course_module_element_user_logs_on_course_module_id", using: :btree
  add_index "course_module_element_user_logs", ["user_id"], name: "index_course_module_element_user_logs_on_user_id", using: :btree

  create_table "course_module_element_videos", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.string   "tags"
    t.string   "difficulty_level"
    t.integer  "estimated_study_time_seconds"
    t.text     "transcript"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.string   "video_id"
    t.float    "duration"
    t.text     "thumbnail"
  end

  add_index "course_module_element_videos", ["course_module_element_id"], name: "index_course_module_element_videos_on_course_module_element_id", using: :btree

  create_table "course_module_elements", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.text     "description"
    t.integer  "estimated_time_in_seconds"
    t.integer  "course_module_id"
    t.integer  "sorting_order"
    t.integer  "tutor_id"
    t.integer  "related_quiz_id"
    t.integer  "related_video_id"
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
  end

  add_index "course_module_elements", ["course_module_id"], name: "index_course_module_elements_on_course_module_id", using: :btree
  add_index "course_module_elements", ["name_url"], name: "index_course_module_elements_on_name_url", using: :btree
  add_index "course_module_elements", ["related_quiz_id"], name: "index_course_module_elements_on_related_quiz_id", using: :btree
  add_index "course_module_elements", ["related_video_id"], name: "index_course_module_elements_on_related_video_id", using: :btree
  add_index "course_module_elements", ["tutor_id"], name: "index_course_module_elements_on_tutor_id", using: :btree

  create_table "course_module_jumbo_quizzes", force: :cascade do |t|
    t.integer  "course_module_id"
    t.string   "name"
    t.integer  "minimum_question_count_per_quiz"
    t.integer  "maximum_question_count_per_quiz"
    t.integer  "total_number_of_questions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_url"
    t.integer  "best_possible_score_first_attempt", default: 0
    t.integer  "best_possible_score_retry",         default: 0
    t.datetime "destroyed_at"
    t.boolean  "active",                            default: false, null: false
  end

  add_index "course_module_jumbo_quizzes", ["course_module_id"], name: "index_course_module_jumbo_quizzes_on_course_module_id", using: :btree

  create_table "course_modules", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.text     "description"
    t.integer  "tutor_id"
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
    t.integer  "discourse_topic_id"
  end

  add_index "course_modules", ["name_url"], name: "index_course_modules_on_name_url", using: :btree
  add_index "course_modules", ["sorting_order"], name: "index_course_modules_on_sorting_order", using: :btree
  add_index "course_modules", ["tutor_id"], name: "index_course_modules_on_tutor_id", using: :btree

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
    t.string   "student_number"
    t.integer  "exam_body_id"
    t.date     "exam_date"
    t.boolean  "registered",                 default: false
  end

  create_table "exam_bodies", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "exam_bodies", ["name"], name: "index_exam_bodies_on_name", using: :btree

  create_table "exam_sittings", force: :cascade do |t|
    t.string   "name"
    t.integer  "subject_course_id"
    t.date     "date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "exam_body_id"
  end

  add_index "exam_sittings", ["date"], name: "index_exam_sittings_on_date", using: :btree
  add_index "exam_sittings", ["name"], name: "index_exam_sittings_on_name", using: :btree
  add_index "exam_sittings", ["subject_course_id"], name: "index_exam_sittings_on_subject_course_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.boolean  "active",                        default: false, null: false
    t.integer  "sorting_order"
    t.text     "description"
    t.integer  "subject_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "corporate_customer_id"
    t.datetime "destroyed_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "background_colour"
    t.string   "background_image_file_name"
    t.string   "background_image_content_type"
    t.integer  "background_image_file_size"
    t.datetime "background_image_updated_at"
  end

  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree
  add_index "groups", ["subject_id"], name: "index_groups_on_subject_id", using: :btree

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
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "group_id"
    t.integer  "subject_course_id"
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
    t.integer  "corporate_customer_id"
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
  end

  add_index "invoices", ["corporate_customer_id"], name: "index_invoices_on_corporate_customer_id", using: :btree
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
    t.string   "current_status"
    t.string   "coupon_code"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "stripe_order_payment_data"
    t.integer  "mock_exam_id"
  end

  add_index "orders", ["product_id"], name: "index_orders_on_product_id", using: :btree
  add_index "orders", ["stripe_customer_id"], name: "index_orders_on_stripe_customer_id", using: :btree
  add_index "orders", ["stripe_guid"], name: "index_orders_on_stripe_guid", using: :btree
  add_index "orders", ["subject_course_id"], name: "index_orders_on_subject_course_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "subject_course_id"
    t.integer  "mock_exam_id"
    t.string   "stripe_guid"
    t.boolean  "live_mode",         default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "active",            default: false
    t.integer  "currency_id"
    t.decimal  "price"
    t.string   "stripe_sku_guid"
  end

  add_index "products", ["mock_exam_id"], name: "index_products_on_mock_exam_id", using: :btree
  add_index "products", ["name"], name: "index_products_on_name", using: :btree
  add_index "products", ["stripe_guid"], name: "index_products_on_stripe_guid", using: :btree
  add_index "products", ["subject_course_id"], name: "index_products_on_subject_course_id", using: :btree

  create_table "question_banks", force: :cascade do |t|
    t.string   "question_selection_strategy"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "subject_course_id"
    t.integer  "number_of_questions"
    t.string   "name"
    t.boolean  "active",                      default: false
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.integer  "quiz_question_id"
    t.boolean  "correct",                       default: false, null: false
    t.string   "degree_of_wrongness"
    t.text     "wrong_answer_explanation_text"
    t.integer  "wrong_answer_video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  add_index "quiz_answers", ["degree_of_wrongness"], name: "index_quiz_answers_on_degree_of_wrongness", using: :btree
  add_index "quiz_answers", ["quiz_question_id"], name: "index_quiz_answers_on_quiz_question_id", using: :btree
  add_index "quiz_answers", ["wrong_answer_video_id"], name: "index_quiz_answers_on_wrong_answer_video_id", using: :btree

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
    t.boolean  "contains_mathjax",   default: false, null: false
    t.boolean  "contains_image",     default: false, null: false
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
    t.text     "hints"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.integer  "subject_course_id"
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

  create_table "student_exam_tracks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "latest_course_module_element_id"
    t.integer  "exam_schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_guid"
    t.integer  "course_module_id"
    t.boolean  "jumbo_quiz_taken",                default: false
    t.float    "percentage_complete",             default: 0.0
    t.integer  "count_of_cmes_completed",         default: 0
    t.integer  "subject_course_id"
    t.integer  "count_of_questions_taken"
    t.integer  "count_of_questions_correct"
    t.integer  "count_of_quizzes_taken"
    t.integer  "count_of_videos_taken"
  end

  add_index "student_exam_tracks", ["exam_schedule_id"], name: "index_student_exam_tracks_on_exam_schedule_id", using: :btree
  add_index "student_exam_tracks", ["latest_course_module_element_id"], name: "index_student_exam_tracks_on_latest_course_module_element_id", using: :btree
  add_index "student_exam_tracks", ["user_id"], name: "index_student_exam_tracks_on_user_id", using: :btree

  create_table "student_user_types", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "subscription",  default: false
    t.boolean  "product_order", default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "free_trial",    default: false
  end

  add_index "student_user_types", ["name"], name: "index_student_user_types_on_name", using: :btree
  add_index "student_user_types", ["product_order"], name: "index_student_user_types_on_product_order", using: :btree
  add_index "student_user_types", ["subscription"], name: "index_student_user_types_on_subscription", using: :btree

  create_table "subject_course_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "payment_type"
    t.boolean  "active",       default: false
    t.string   "subdomain"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "subject_course_categories", ["name"], name: "index_subject_course_categories_on_name", using: :btree
  add_index "subject_course_categories", ["subdomain"], name: "index_subject_course_categories_on_subdomain", using: :btree

  create_table "subject_course_user_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "session_guid"
    t.integer  "subject_course_id"
    t.integer  "percentage_complete",             default: 0
    t.integer  "count_of_cmes_completed",         default: 0
    t.integer  "latest_course_module_element_id"
    t.boolean  "completed",                       default: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "count_of_questions_correct"
    t.integer  "count_of_questions_taken"
    t.integer  "count_of_videos_taken"
    t.integer  "count_of_quizzes_taken"
  end

  add_index "subject_course_user_logs", ["session_guid"], name: "index_subject_course_user_logs_on_session_guid", using: :btree
  add_index "subject_course_user_logs", ["subject_course_id"], name: "index_subject_course_user_logs_on_subject_course_id", using: :btree
  add_index "subject_course_user_logs", ["user_id"], name: "index_subject_course_user_logs_on_user_id", using: :btree

  create_table "subject_courses", force: :cascade do |t|
    t.string   "name"
    t.string   "name_url"
    t.integer  "sorting_order"
    t.boolean  "active",                                  default: false, null: false
    t.boolean  "live",                                    default: false, null: false
    t.string   "wistia_guid"
    t.integer  "tutor_id"
    t.integer  "cme_count"
    t.integer  "video_count"
    t.integer  "quiz_count"
    t.integer  "question_count"
    t.text     "description"
    t.string   "short_description"
    t.string   "mailchimp_guid"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.float    "best_possible_first_attempt_score"
    t.integer  "default_number_of_possible_exam_answers"
    t.boolean  "restricted",                              default: false, null: false
    t.integer  "corporate_customer_id"
    t.float    "total_video_duration",                    default: 0.0
    t.datetime "destroyed_at"
    t.boolean  "is_cpd",                                  default: false
    t.float    "cpd_hours"
    t.integer  "cpd_pass_rate"
    t.datetime "live_date"
    t.boolean  "certificate",                             default: false, null: false
    t.string   "hotjar_guid"
    t.boolean  "enrollment_option",                       default: false
    t.integer  "subject_course_category_id"
    t.text     "email_content"
    t.string   "external_url_name"
    t.string   "external_url"
    t.integer  "exam_body_id"
  end

  add_index "subject_courses", ["name"], name: "index_subject_courses_on_name", using: :btree
  add_index "subject_courses", ["tutor_id"], name: "index_subject_courses_on_tutor_id", using: :btree
  add_index "subject_courses", ["wistia_guid"], name: "index_subject_courses_on_wistia_guid", using: :btree

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
    t.boolean  "available_to_corporates",       default: false, null: false
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
  end

  add_index "subscription_plans", ["available_from"], name: "index_subscription_plans_on_available_from", using: :btree
  add_index "subscription_plans", ["available_to"], name: "index_subscription_plans_on_available_to", using: :btree
  add_index "subscription_plans", ["available_to_corporates"], name: "index_subscription_plans_on_available_to_corporates", using: :btree
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
    t.integer  "corporate_customer_id"
    t.integer  "subscription_plan_id"
    t.string   "stripe_guid"
    t.date     "next_renewal_date"
    t.boolean  "complimentary",         default: false, null: false
    t.string   "current_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_customer_id"
    t.text     "stripe_customer_data"
    t.boolean  "livemode",              default: false
    t.boolean  "active",                default: false
  end

  add_index "subscriptions", ["corporate_customer_id"], name: "index_subscriptions_on_corporate_customer_id", using: :btree
  add_index "subscriptions", ["current_status"], name: "index_subscriptions_on_current_status", using: :btree
  add_index "subscriptions", ["next_renewal_date"], name: "index_subscriptions_on_next_renewal_date", using: :btree
  add_index "subscriptions", ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "system_defaults", force: :cascade do |t|
    t.integer  "individual_student_user_group_id"
    t.integer  "corporate_student_user_group_id"
    t.integer  "corporate_customer_user_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "system_defaults", ["corporate_customer_user_group_id"], name: "index_system_defaults_on_corporate_customer_user_group_id", using: :btree
  add_index "system_defaults", ["corporate_student_user_group_id"], name: "index_system_defaults_on_corporate_student_user_group_id", using: :btree
  add_index "system_defaults", ["individual_student_user_group_id"], name: "index_system_defaults_on_individual_student_user_group_id", using: :btree

  create_table "tutor_applications", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "info"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tutor_applications", ["email"], name: "index_tutor_applications_on_email", using: :btree

  create_table "user_exam_sittings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "exam_sitting_id"
    t.integer  "subject_course_id"
    t.date     "date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "user_exam_sittings", ["date"], name: "index_user_exam_sittings_on_date", using: :btree
  add_index "user_exam_sittings", ["exam_sitting_id"], name: "index_user_exam_sittings_on_exam_sitting_id", using: :btree
  add_index "user_exam_sittings", ["subject_course_id"], name: "index_user_exam_sittings_on_subject_course_id", using: :btree
  add_index "user_exam_sittings", ["user_id"], name: "index_user_exam_sittings_on_user_id", using: :btree

  create_table "user_groups", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "individual_student",                   default: false, null: false
    t.boolean  "corporate_student",                    default: false, null: false
    t.boolean  "tutor",                                default: false, null: false
    t.boolean  "content_manager",                      default: false, null: false
    t.boolean  "blogger",                              default: false, null: false
    t.boolean  "corporate_customer",                   default: false, null: false
    t.boolean  "site_admin",                           default: false, null: false
    t.boolean  "subscription_required_at_sign_up",     default: false, null: false
    t.boolean  "subscription_required_to_see_content", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complimentary",                        default: false
  end

  create_table "user_notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "subject_line"
    t.text     "content"
    t.boolean  "email_required", default: false, null: false
    t.datetime "email_sent_at"
    t.boolean  "unread",         default: true,  null: false
    t.datetime "destroyed_at"
    t.string   "message_type"
    t.integer  "tutor_id"
    t.boolean  "falling_behind",                 null: false
    t.integer  "blog_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_notifications", ["blog_post_id"], name: "index_user_notifications_on_blog_post_id", using: :btree
  add_index "user_notifications", ["message_type"], name: "index_user_notifications_on_message_type", using: :btree
  add_index "user_notifications", ["tutor_id"], name: "index_user_notifications_on_tutor_id", using: :btree
  add_index "user_notifications", ["user_id"], name: "index_user_notifications_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "address"
    t.integer  "country_id"
    t.string   "crypted_password",                 limit: 128, default: "",    null: false
    t.string   "password_salt",                    limit: 128, default: "",    null: false
    t.string   "persistence_token"
    t.string   "perishable_token",                 limit: 128
    t.string   "single_access_token"
    t.integer  "login_count",                                  default: 0
    t.integer  "failed_login_count",                           default: 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "account_activation_code"
    t.datetime "account_activated_at"
    t.boolean  "active",                                       default: false, null: false
    t.integer  "user_group_id"
    t.datetime "password_reset_requested_at"
    t.string   "password_reset_token"
    t.datetime "password_reset_at"
    t.string   "stripe_customer_id"
    t.integer  "corporate_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale"
    t.string   "guid"
    t.datetime "trial_ended_notification_sent_at"
    t.string   "crush_offers_session_id"
    t.integer  "subscription_plan_category_id"
    t.string   "employee_guid"
    t.boolean  "password_change_required"
    t.string   "session_key"
    t.text     "first_description"
    t.text     "second_description"
    t.text     "wistia_url"
    t.text     "personal_url"
    t.string   "name_url"
    t.text     "qualifications"
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type"
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.string   "phone_number"
    t.string   "topic_interest"
    t.string   "email_verification_code"
    t.datetime "email_verified_at"
    t.boolean  "email_verified",                               default: false, null: false
    t.integer  "stripe_account_balance",                       default: 0
    t.integer  "trial_limit_in_seconds",                       default: 0
    t.boolean  "free_trial",                                   default: false
    t.integer  "trial_limit_in_days",                          default: 0
    t.boolean  "terms_and_conditions",                         default: false
    t.integer  "student_user_type_id"
    t.boolean  "discourse_user",                               default: false
    t.date     "date_of_birth"
  end

  add_index "users", ["account_activation_code"], name: "index_users_on_account_activation_code", using: :btree
  add_index "users", ["corporate_customer_id"], name: "index_users_on_corporate_customer_id", using: :btree
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
