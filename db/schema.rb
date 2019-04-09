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

ActiveRecord::Schema.define(version: 2019_04_09_131900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visit_id"
    t.integer "user_id"
    t.string "name"
    t.text "properties"
    t.datetime "time"
    t.index ["time"], name: "index_ahoy_events_on_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "blazer_audits", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
  end

  create_table "blazer_checks", id: :serial, force: :cascade do |t|
    t.integer "creator_id"
    t.integer "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blazer_dashboard_queries", id: :serial, force: :cascade do |t|
    t.integer "dashboard_id"
    t.integer "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blazer_dashboards", id: :serial, force: :cascade do |t|
    t.integer "creator_id"
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blazer_queries", id: :serial, force: :cascade do |t|
    t.integer "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blog_posts", id: :serial, force: :cascade do |t|
    t.integer "home_page_id"
    t.integer "sorting_order"
    t.string "title"
    t.text "description"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.index ["home_page_id"], name: "index_blog_posts_on_home_page_id"
  end

  create_table "charges", id: :serial, force: :cascade do |t|
    t.integer "subscription_id"
    t.integer "invoice_id"
    t.integer "user_id"
    t.integer "subscription_payment_card_id"
    t.integer "currency_id"
    t.integer "coupon_id"
    t.integer "stripe_api_event_id"
    t.string "stripe_guid"
    t.integer "amount"
    t.integer "amount_refunded"
    t.string "failure_code"
    t.text "failure_message"
    t.string "stripe_customer_id"
    t.string "stripe_invoice_id"
    t.boolean "livemode", default: false
    t.string "stripe_order_id"
    t.boolean "paid", default: false
    t.boolean "refunded", default: false
    t.text "stripe_refunds_data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "original_event_data"
    t.index ["coupon_id"], name: "index_charges_on_coupon_id"
    t.index ["currency_id"], name: "index_charges_on_currency_id"
    t.index ["invoice_id"], name: "index_charges_on_invoice_id"
    t.index ["paid"], name: "index_charges_on_paid"
    t.index ["refunded"], name: "index_charges_on_refunded"
    t.index ["status"], name: "index_charges_on_status"
    t.index ["stripe_api_event_id"], name: "index_charges_on_stripe_api_event_id"
    t.index ["subscription_id"], name: "index_charges_on_subscription_id"
    t.index ["subscription_payment_card_id"], name: "index_charges_on_subscription_payment_card_id"
    t.index ["user_id"], name: "index_charges_on_user_id"
  end

  create_table "constructed_response_attempts", id: :serial, force: :cascade do |t|
    t.integer "constructed_response_id"
    t.integer "scenario_id"
    t.integer "course_module_element_id"
    t.integer "course_module_element_user_log_id"
    t.integer "user_id"
    t.text "original_scenario_text_content"
    t.text "user_edited_scenario_text_content"
    t.string "status"
    t.boolean "flagged_for_review", default: false
    t.integer "time_in_seconds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "guid"
    t.text "scratch_pad_text"
    t.index ["constructed_response_id"], name: "index_constructed_response_attempts_on_constructed_response_id"
    t.index ["course_module_element_id"], name: "index_constructed_response_attempts_on_course_module_element_id"
    t.index ["flagged_for_review"], name: "index_constructed_response_attempts_on_flagged_for_review"
    t.index ["scenario_id"], name: "index_constructed_response_attempts_on_scenario_id"
    t.index ["user_id"], name: "index_constructed_response_attempts_on_user_id"
  end

  create_table "constructed_responses", id: :serial, force: :cascade do |t|
    t.integer "course_module_element_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time_allowed"
    t.datetime "destroyed_at"
    t.index ["course_module_element_id"], name: "index_constructed_responses_on_course_module_element_id"
  end

  create_table "content_page_sections", id: :serial, force: :cascade do |t|
    t.integer "content_page_id"
    t.text "text_content"
    t.string "panel_colour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_course_id"
    t.integer "sorting_order"
  end

  create_table "content_pages", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "public_url"
    t.string "seo_title"
    t.text "seo_description"
    t.text "text_content"
    t.string "h1_text"
    t.string "h1_subtext"
    t.string "nav_type"
    t.boolean "footer_link", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.index ["footer_link"], name: "index_content_pages_on_footer_link"
    t.index ["name"], name: "index_content_pages_on_name"
    t.index ["public_url"], name: "index_content_pages_on_public_url"
  end

  create_table "countries", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "iso_code"
    t.string "country_tld"
    t.integer "sorting_order"
    t.boolean "in_the_eu", default: false, null: false
    t.integer "currency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "continent"
    t.index ["currency_id"], name: "index_countries_on_currency_id"
    t.index ["in_the_eu"], name: "index_countries_on_in_the_eu"
    t.index ["name"], name: "index_countries_on_name"
    t.index ["sorting_order"], name: "index_countries_on_sorting_order"
  end

  create_table "coupons", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "currency_id"
    t.boolean "livemode", default: false
    t.boolean "active", default: false
    t.integer "amount_off"
    t.string "duration"
    t.integer "duration_in_months"
    t.integer "max_redemptions"
    t.integer "percent_off"
    t.datetime "redeem_by"
    t.integer "times_redeemed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "stripe_coupon_data"
    t.index ["active"], name: "index_coupons_on_active"
    t.index ["code"], name: "index_coupons_on_code"
    t.index ["name"], name: "index_coupons_on_name"
  end

  create_table "course_module_element_quizzes", id: :serial, force: :cascade do |t|
    t.integer "course_module_element_id"
    t.integer "number_of_questions"
    t.string "question_selection_strategy"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.index ["course_module_element_id"], name: "cme_quiz_cme_id"
  end

  create_table "course_module_element_resources", id: :serial, force: :cascade do |t|
    t.integer "course_module_element_id"
    t.string "name"
    t.string "web_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "upload_file_name"
    t.string "upload_content_type"
    t.integer "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "destroyed_at"
    t.index ["course_module_element_id"], name: "cme_resources_cme_id"
  end

  create_table "course_module_element_user_logs", id: :serial, force: :cascade do |t|
    t.integer "course_module_element_id"
    t.integer "user_id"
    t.string "session_guid"
    t.boolean "element_completed", default: false, null: false
    t.integer "time_taken_in_seconds"
    t.integer "quiz_score_actual"
    t.integer "quiz_score_potential"
    t.boolean "is_video", default: false, null: false
    t.boolean "is_quiz", default: false, null: false
    t.integer "course_module_id"
    t.boolean "latest_attempt", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "seconds_watched", default: 0
    t.integer "count_of_questions_taken"
    t.integer "count_of_questions_correct"
    t.integer "subject_course_id"
    t.integer "student_exam_track_id"
    t.integer "subject_course_user_log_id"
    t.boolean "is_constructed_response", default: false
    t.boolean "preview_mode", default: false
    t.integer "course_section_id"
    t.integer "course_section_user_log_id"
    t.index ["course_module_element_id"], name: "cme_user_logs_cme_id"
    t.index ["course_module_id"], name: "index_course_module_element_user_logs_on_course_module_id"
    t.index ["user_id"], name: "index_course_module_element_user_logs_on_user_id"
  end

  create_table "course_module_element_videos", id: :serial, force: :cascade do |t|
    t.integer "course_module_element_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.string "video_id"
    t.float "duration"
    t.string "vimeo_guid"
    t.index ["course_module_element_id"], name: "index_course_module_element_videos_on_course_module_element_id"
  end

  create_table "course_module_elements", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_url"
    t.text "description"
    t.integer "estimated_time_in_seconds"
    t.integer "course_module_id"
    t.integer "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_video", default: false, null: false
    t.boolean "is_quiz", default: false, null: false
    t.boolean "active", default: true, null: false
    t.string "seo_description"
    t.boolean "seo_no_index", default: false
    t.datetime "destroyed_at"
    t.integer "number_of_questions", default: 0
    t.float "duration", default: 0.0
    t.string "temporary_label"
    t.boolean "is_constructed_response", default: false, null: false
    t.boolean "available_on_trial", default: false
    t.integer "related_course_module_element_id"
    t.index ["course_module_id"], name: "index_course_module_elements_on_course_module_id"
    t.index ["name_url"], name: "index_course_module_elements_on_name_url"
  end

  create_table "course_modules", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_url"
    t.text "description"
    t.integer "sorting_order"
    t.integer "estimated_time_in_seconds"
    t.boolean "active", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "cme_count", default: 0
    t.string "seo_description"
    t.boolean "seo_no_index", default: false
    t.datetime "destroyed_at"
    t.integer "number_of_questions", default: 0
    t.integer "subject_course_id"
    t.float "video_duration", default: 0.0
    t.integer "video_count", default: 0
    t.integer "quiz_count", default: 0
    t.string "highlight_colour"
    t.boolean "tuition", default: false
    t.boolean "test", default: false
    t.boolean "revision", default: false
    t.integer "course_section_id"
    t.integer "constructed_response_count", default: 0
    t.index ["name_url"], name: "index_course_modules_on_name_url"
    t.index ["sorting_order"], name: "index_course_modules_on_sorting_order"
  end

  create_table "course_section_user_logs", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "course_section_id"
    t.integer "subject_course_user_log_id"
    t.integer "latest_course_module_element_id"
    t.float "percentage_complete"
    t.integer "count_of_cmes_completed"
    t.integer "count_of_quizzes_taken"
    t.integer "count_of_videos_taken"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_course_id"
    t.integer "count_of_constructed_responses_taken"
    t.index ["course_section_id"], name: "index_course_section_user_logs_on_course_section_id"
    t.index ["subject_course_user_log_id"], name: "index_course_section_user_logs_on_subject_course_user_log_id"
    t.index ["user_id"], name: "index_course_section_user_logs_on_user_id"
  end

  create_table "course_sections", id: :serial, force: :cascade do |t|
    t.integer "subject_course_id"
    t.string "name"
    t.string "name_url"
    t.integer "sorting_order"
    t.boolean "active", default: false
    t.boolean "counts_towards_completion", default: false
    t.boolean "assumed_knowledge", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cme_count", default: 0
    t.integer "video_count", default: 0
    t.integer "quiz_count", default: 0
    t.datetime "destroyed_at"
    t.integer "constructed_response_count", default: 0
    t.index ["name"], name: "index_course_sections_on_name"
    t.index ["subject_course_id"], name: "index_course_sections_on_subject_course_id"
  end

  create_table "course_tutor_details", id: :serial, force: :cascade do |t|
    t.integer "subject_course_id"
    t.integer "user_id"
    t.integer "sorting_order"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_course_id"], name: "index_course_tutor_details_on_subject_course_id"
    t.index ["user_id"], name: "index_course_tutor_details_on_user_id"
  end

  create_table "currencies", id: :serial, force: :cascade do |t|
    t.string "iso_code"
    t.string "name"
    t.string "leading_symbol"
    t.string "trailing_symbol"
    t.boolean "active", default: false, null: false
    t.integer "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["active"], name: "index_currencies_on_active"
    t.index ["iso_code"], name: "index_currencies_on_iso_code"
    t.index ["sorting_order"], name: "index_currencies_on_sorting_order"
  end

  create_table "enrollments", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "subject_course_id"
    t.integer "subject_course_user_log_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.integer "exam_body_id"
    t.date "exam_date"
    t.boolean "expired", default: false
    t.boolean "paused", default: false
    t.boolean "notifications", default: true
    t.integer "exam_sitting_id"
    t.boolean "computer_based_exam", default: false
    t.integer "percentage_complete", default: 0
  end

  create_table "exam_bodies", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false, null: false
    t.boolean "has_sittings", default: false, null: false
    t.integer "preferred_payment_frequency"
    t.index ["name"], name: "index_exam_bodies_on_name"
  end

  create_table "exam_body_user_details", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "exam_body_id"
    t.string "student_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_body_id"], name: "index_exam_body_user_details_on_exam_body_id"
    t.index ["user_id"], name: "index_exam_body_user_details_on_user_id"
  end

  create_table "exam_sittings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "subject_course_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exam_body_id"
    t.boolean "active", default: true
    t.boolean "computer_based", default: false
    t.index ["date"], name: "index_exam_sittings_on_date"
    t.index ["name"], name: "index_exam_sittings_on_name"
    t.index ["subject_course_id"], name: "index_exam_sittings_on_subject_course_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.bigint "product_id"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "corrector_id"
    t.string "submission_file_name"
    t.string "submission_content_type"
    t.bigint "submission_file_size"
    t.datetime "submission_updated_at"
    t.string "correction_file_name"
    t.string "correction_content_type"
    t.bigint "correction_file_size"
    t.datetime "correction_updated_at"
    t.datetime "submitted_on"
    t.index ["corrector_id"], name: "index_exercises_on_corrector_id"
    t.index ["product_id"], name: "index_exercises_on_product_id"
    t.index ["user_id"], name: "index_exercises_on_user_id"
  end

  create_table "external_banners", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "sorting_order"
    t.boolean "active", default: false
    t.string "background_colour"
    t.text "text_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "user_sessions", default: false
    t.boolean "library", default: false
    t.boolean "subscription_plans", default: false
    t.boolean "footer_pages", default: false
    t.boolean "student_sign_ups", default: false
    t.integer "home_page_id"
    t.integer "content_page_id"
    t.index ["active"], name: "index_external_banners_on_active"
    t.index ["name"], name: "index_external_banners_on_name"
  end

  create_table "faq_sections", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_url"
    t.text "description"
    t.boolean "active", default: true
    t.integer "sorting_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_faq_sections_on_active"
    t.index ["name"], name: "index_faq_sections_on_name"
    t.index ["name_url"], name: "index_faq_sections_on_name_url"
    t.index ["sorting_order"], name: "index_faq_sections_on_sorting_order"
  end

  create_table "faqs", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_url"
    t.boolean "active", default: true
    t.integer "sorting_order"
    t.integer "faq_section_id"
    t.text "question_text"
    t.text "answer_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "pre_answer_text"
    t.index ["active"], name: "index_faqs_on_active"
    t.index ["faq_section_id"], name: "index_faqs_on_faq_section_id"
    t.index ["name"], name: "index_faqs_on_name"
    t.index ["name_url"], name: "index_faqs_on_name_url"
    t.index ["question_text"], name: "index_faqs_on_question_text"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_url"
    t.boolean "active", default: false, null: false
    t.integer "sorting_order"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "destroyed_at"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.string "background_image_file_name"
    t.string "background_image_content_type"
    t.integer "background_image_file_size"
    t.datetime "background_image_updated_at"
    t.string "background_colour"
    t.bigint "exam_body_id"
    t.string "seo_title"
    t.string "seo_description"
    t.string "short_description"
    t.index ["exam_body_id"], name: "index_groups_on_exam_body_id"
    t.index ["name"], name: "index_groups_on_name"
  end

  create_table "groups_subject_courses", id: false, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "subject_course_id", null: false
    t.index ["group_id"], name: "index_groups_subject_courses_on_group_id"
    t.index ["subject_course_id"], name: "index_groups_subject_courses_on_subject_course_id"
  end

  create_table "home_pages", id: :serial, force: :cascade do |t|
    t.string "seo_title"
    t.string "seo_description"
    t.integer "subscription_plan_category_id"
    t.string "public_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_course_id"
    t.string "custom_file_name"
    t.integer "group_id"
    t.string "name"
    t.boolean "home", default: false
    t.string "logo_image"
    t.boolean "footer_link", default: false
    t.string "mailchimp_list_guid"
    t.boolean "form_section", default: false, null: false
    t.boolean "pricing_section", default: false, null: false
    t.boolean "seo_no_index", default: false, null: false
    t.index ["public_url"], name: "index_home_pages_on_public_url"
    t.index ["subscription_plan_category_id"], name: "index_home_pages_on_subscription_plan_category_id"
  end

  create_table "import_trackers", id: :serial, force: :cascade do |t|
    t.string "old_model_name"
    t.integer "old_model_id"
    t.string "new_model_name"
    t.integer "new_model_id"
    t.datetime "imported_at"
    t.text "original_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["imported_at"], name: "index_import_trackers_on_imported_at"
    t.index ["new_model_id"], name: "index_import_trackers_on_new_model_id"
    t.index ["new_model_name"], name: "index_import_trackers_on_new_model_name"
    t.index ["old_model_id"], name: "index_import_trackers_on_old_model_id"
    t.index ["old_model_name"], name: "index_import_trackers_on_old_model_name"
  end

  create_table "invoice_line_items", id: :serial, force: :cascade do |t|
    t.integer "invoice_id"
    t.decimal "amount"
    t.integer "currency_id"
    t.boolean "prorated"
    t.datetime "period_start_at"
    t.datetime "period_end_at"
    t.integer "subscription_id"
    t.integer "subscription_plan_id"
    t.text "original_stripe_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["currency_id"], name: "index_invoice_line_items_on_currency_id"
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
    t.index ["period_end_at"], name: "index_invoice_line_items_on_period_end_at"
    t.index ["period_start_at"], name: "index_invoice_line_items_on_period_start_at"
    t.index ["subscription_id"], name: "index_invoice_line_items_on_subscription_id"
    t.index ["subscription_plan_id"], name: "index_invoice_line_items_on_subscription_plan_id"
  end

  create_table "invoices", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "subscription_transaction_id"
    t.integer "subscription_id"
    t.integer "number_of_users"
    t.integer "currency_id"
    t.integer "vat_rate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "issued_at"
    t.string "stripe_guid"
    t.decimal "sub_total", default: "0.0"
    t.decimal "total", default: "0.0"
    t.decimal "total_tax", default: "0.0"
    t.string "stripe_customer_guid"
    t.string "object_type", default: "invoice"
    t.boolean "payment_attempted", default: false
    t.boolean "payment_closed", default: false
    t.boolean "forgiven", default: false
    t.boolean "paid", default: false
    t.boolean "livemode", default: false
    t.integer "attempt_count", default: 0
    t.decimal "amount_due", default: "0.0"
    t.datetime "next_payment_attempt_at"
    t.datetime "webhooks_delivered_at"
    t.string "charge_guid"
    t.string "subscription_guid"
    t.decimal "tax_percent"
    t.decimal "tax"
    t.text "original_stripe_data"
    t.string "paypal_payment_guid"
    t.index ["currency_id"], name: "index_invoices_on_currency_id"
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
    t.index ["subscription_transaction_id"], name: "index_invoices_on_subscription_transaction_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
    t.index ["vat_rate_id"], name: "index_invoices_on_vat_rate_id"
  end

  create_table "ip_addresses", id: :serial, force: :cascade do |t|
    t.string "ip_address"
    t.float "latitude"
    t.float "longitude"
    t.integer "country_id"
    t.integer "alert_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["country_id"], name: "index_ip_addresses_on_country_id"
    t.index ["ip_address"], name: "index_ip_addresses_on_ip_address"
    t.index ["latitude"], name: "index_ip_addresses_on_latitude"
    t.index ["longitude"], name: "index_ip_addresses_on_longitude"
  end

  create_table "mock_exams", id: :serial, force: :cascade do |t|
    t.integer "subject_course_id"
    t.integer "product_id"
    t.string "name"
    t.integer "sorting_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.string "cover_image_file_name"
    t.string "cover_image_content_type"
    t.integer "cover_image_file_size"
    t.datetime "cover_image_updated_at"
    t.index ["name"], name: "index_mock_exams_on_name"
    t.index ["product_id"], name: "index_mock_exams_on_product_id"
    t.index ["subject_course_id"], name: "index_mock_exams_on_subject_course_id"
  end

  create_table "order_transactions", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "user_id"
    t.integer "product_id"
    t.string "stripe_order_id"
    t.string "stripe_charge_id"
    t.boolean "live_mode", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_transactions_on_order_id"
    t.index ["product_id"], name: "index_order_transactions_on_product_id"
    t.index ["stripe_charge_id"], name: "index_order_transactions_on_stripe_charge_id"
    t.index ["stripe_order_id"], name: "index_order_transactions_on_stripe_order_id"
    t.index ["user_id"], name: "index_order_transactions_on_user_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "subject_course_id"
    t.integer "user_id"
    t.string "stripe_guid"
    t.string "stripe_customer_id"
    t.boolean "live_mode", default: false
    t.string "stripe_status"
    t.string "coupon_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "stripe_order_payment_data"
    t.integer "mock_exam_id"
    t.boolean "terms_and_conditions", default: false
    t.string "reference_guid"
    t.string "paypal_guid"
    t.string "paypal_status"
    t.string "state"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["stripe_customer_id"], name: "index_orders_on_stripe_customer_id"
    t.index ["stripe_guid"], name: "index_orders_on_stripe_guid"
    t.index ["subject_course_id"], name: "index_orders_on_subject_course_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "paypal_webhooks", id: :serial, force: :cascade do |t|
    t.string "guid"
    t.string "event_type"
    t.text "payload"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: true
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "mock_exam_id"
    t.string "stripe_guid"
    t.boolean "live_mode", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.integer "currency_id"
    t.decimal "price"
    t.string "stripe_sku_guid"
    t.integer "subject_course_id"
    t.integer "sorting_order"
    t.integer "product_type", default: 0
    t.integer "correction_pack_count"
    t.index ["mock_exam_id"], name: "index_products_on_mock_exam_id"
    t.index ["name"], name: "index_products_on_name"
    t.index ["stripe_guid"], name: "index_products_on_stripe_guid"
  end

  create_table "quiz_answers", id: :serial, force: :cascade do |t|
    t.integer "quiz_question_id"
    t.boolean "correct", default: false, null: false
    t.string "degree_of_wrongness"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.index ["degree_of_wrongness"], name: "index_quiz_answers_on_degree_of_wrongness"
    t.index ["quiz_question_id"], name: "index_quiz_answers_on_quiz_question_id"
  end

  create_table "quiz_attempts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "quiz_question_id"
    t.integer "quiz_answer_id"
    t.boolean "correct", default: false, null: false
    t.integer "course_module_element_user_log_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "score", default: 0
    t.string "answer_array"
    t.index ["course_module_element_user_log_id"], name: "index_quiz_attempts_on_course_module_element_user_log_id"
    t.index ["quiz_answer_id"], name: "index_quiz_attempts_on_quiz_answer_id"
    t.index ["quiz_question_id"], name: "index_quiz_attempts_on_quiz_question_id"
    t.index ["user_id"], name: "index_quiz_attempts_on_user_id"
  end

  create_table "quiz_contents", id: :serial, force: :cascade do |t|
    t.integer "quiz_question_id"
    t.integer "quiz_answer_id"
    t.text "text_content"
    t.integer "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "quiz_solution_id"
    t.datetime "destroyed_at"
    t.index ["quiz_answer_id"], name: "index_quiz_contents_on_quiz_answer_id"
    t.index ["quiz_question_id"], name: "index_quiz_contents_on_quiz_question_id"
  end

  create_table "quiz_questions", id: :serial, force: :cascade do |t|
    t.integer "course_module_element_quiz_id"
    t.integer "course_module_element_id"
    t.string "difficulty_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
    t.integer "subject_course_id"
    t.integer "sorting_order"
    t.boolean "custom_styles", default: false
    t.index ["course_module_element_id"], name: "index_quiz_questions_on_course_module_element_id"
    t.index ["course_module_element_quiz_id"], name: "index_quiz_questions_on_course_module_element_quiz_id"
    t.index ["difficulty_level"], name: "index_quiz_questions_on_difficulty_level"
  end

  create_table "referral_codes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "code", limit: 7
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_referral_codes_on_user_id"
  end

  create_table "referred_signups", id: :serial, force: :cascade do |t|
    t.integer "referral_code_id"
    t.integer "user_id"
    t.string "referrer_url", limit: 2048
    t.integer "subscription_id"
    t.datetime "maturing_on"
    t.datetime "payed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referral_code_id"], name: "index_referred_signups_on_referral_code_id"
    t.index ["subscription_id"], name: "index_referred_signups_on_subscription_id"
    t.index ["user_id"], name: "index_referred_signups_on_user_id"
  end

  create_table "refunds", id: :serial, force: :cascade do |t|
    t.string "stripe_guid"
    t.integer "charge_id"
    t.string "stripe_charge_guid"
    t.integer "invoice_id"
    t.integer "subscription_id"
    t.integer "user_id"
    t.integer "manager_id"
    t.integer "amount"
    t.text "reason"
    t.string "status"
    t.boolean "livemode", default: true
    t.text "stripe_refund_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["charge_id"], name: "index_refunds_on_charge_id"
    t.index ["invoice_id"], name: "index_refunds_on_invoice_id"
    t.index ["manager_id"], name: "index_refunds_on_manager_id"
    t.index ["status"], name: "index_refunds_on_status"
    t.index ["subscription_id"], name: "index_refunds_on_subscription_id"
    t.index ["user_id"], name: "index_refunds_on_user_id"
  end

  create_table "scenario_answer_attempts", id: :serial, force: :cascade do |t|
    t.integer "scenario_question_attempt_id"
    t.integer "user_id"
    t.integer "scenario_answer_template_id"
    t.text "original_answer_template_text"
    t.text "user_edited_answer_template_text"
    t.string "editor_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sorting_order"
  end

  create_table "scenario_answer_templates", id: :serial, force: :cascade do |t|
    t.integer "scenario_question_id"
    t.integer "sorting_order"
    t.string "editor_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "destroyed_at"
    t.text "text_editor_content"
    t.text "spreadsheet_editor_content"
    t.index ["scenario_question_id"], name: "index_scenario_answer_templates_on_scenario_question_id"
  end

  create_table "scenario_question_attempts", id: :serial, force: :cascade do |t|
    t.integer "constructed_response_attempt_id"
    t.integer "user_id"
    t.integer "scenario_question_id"
    t.string "status"
    t.boolean "flagged_for_review", default: false
    t.text "original_scenario_question_text"
    t.text "user_edited_scenario_question_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sorting_order"
    t.index ["flagged_for_review"], name: "index_scenario_question_attempts_on_flagged_for_review"
    t.index ["scenario_question_id"], name: "index_scenario_question_attempts_on_scenario_question_id"
  end

  create_table "scenario_questions", id: :serial, force: :cascade do |t|
    t.integer "scenario_id"
    t.integer "sorting_order"
    t.text "text_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "destroyed_at"
    t.index ["scenario_id"], name: "index_scenario_questions_on_scenario_id"
  end

  create_table "scenarios", id: :serial, force: :cascade do |t|
    t.integer "constructed_response_id"
    t.integer "sorting_order"
    t.text "text_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "destroyed_at"
    t.index ["constructed_response_id"], name: "index_scenarios_on_constructed_response_id"
  end

  create_table "stripe_api_events", id: :serial, force: :cascade do |t|
    t.string "guid"
    t.string "api_version"
    t.text "payload"
    t.boolean "processed", default: false, null: false
    t.datetime "processed_at"
    t.boolean "error", default: false, null: false
    t.string "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["api_version"], name: "index_stripe_api_events_on_api_version"
    t.index ["error"], name: "index_stripe_api_events_on_error"
    t.index ["guid"], name: "index_stripe_api_events_on_guid"
    t.index ["processed"], name: "index_stripe_api_events_on_processed"
    t.index ["processed_at"], name: "index_stripe_api_events_on_processed_at"
  end

  create_table "student_accesses", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "trial_started_date"
    t.datetime "trial_ending_at_date"
    t.datetime "trial_ended_date"
    t.integer "trial_seconds_limit"
    t.integer "trial_days_limit"
    t.integer "content_seconds_consumed", default: 0
    t.integer "subscription_id"
    t.string "account_type"
    t.boolean "content_access", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_type"], name: "index_student_accesses_on_account_type"
    t.index ["content_access"], name: "index_student_accesses_on_content_access"
    t.index ["content_seconds_consumed"], name: "index_student_accesses_on_content_seconds_consumed"
    t.index ["subscription_id"], name: "index_student_accesses_on_subscription_id"
    t.index ["trial_days_limit"], name: "index_student_accesses_on_trial_days_limit"
    t.index ["trial_seconds_limit"], name: "index_student_accesses_on_trial_seconds_limit"
  end

  create_table "student_exam_tracks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "latest_course_module_element_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "session_guid"
    t.integer "course_module_id"
    t.float "percentage_complete", default: 0.0
    t.integer "count_of_cmes_completed", default: 0
    t.integer "subject_course_id"
    t.integer "count_of_questions_taken"
    t.integer "count_of_questions_correct"
    t.integer "count_of_quizzes_taken"
    t.integer "count_of_videos_taken"
    t.integer "subject_course_user_log_id"
    t.integer "count_of_constructed_responses_taken"
    t.integer "course_section_id"
    t.integer "course_section_user_log_id"
    t.index ["latest_course_module_element_id"], name: "index_student_exam_tracks_on_latest_course_module_element_id"
    t.index ["user_id"], name: "index_student_exam_tracks_on_user_id"
  end

  create_table "subject_course_resources", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "subject_course_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_upload_file_name"
    t.string "file_upload_content_type"
    t.integer "file_upload_file_size"
    t.datetime "file_upload_updated_at"
    t.string "external_url"
    t.boolean "active", default: false
    t.integer "sorting_order"
    t.boolean "available_on_trial", default: false
    t.index ["name"], name: "index_subject_course_resources_on_name"
    t.index ["subject_course_id"], name: "index_subject_course_resources_on_subject_course_id"
  end

  create_table "subject_course_user_logs", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "session_guid"
    t.integer "subject_course_id"
    t.integer "percentage_complete", default: 0
    t.integer "count_of_cmes_completed", default: 0
    t.integer "latest_course_module_element_id"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "count_of_questions_correct"
    t.integer "count_of_questions_taken"
    t.integer "count_of_videos_taken"
    t.integer "count_of_quizzes_taken"
    t.datetime "completed_at"
    t.integer "count_of_constructed_responses_taken"
    t.index ["session_guid"], name: "index_subject_course_user_logs_on_session_guid"
    t.index ["subject_course_id"], name: "index_subject_course_user_logs_on_subject_course_id"
    t.index ["user_id"], name: "index_subject_course_user_logs_on_user_id"
  end

  create_table "subject_courses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "name_url"
    t.integer "sorting_order"
    t.boolean "active", default: false, null: false
    t.integer "cme_count"
    t.integer "video_count"
    t.integer "quiz_count"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_number_of_possible_exam_answers"
    t.datetime "destroyed_at"
    t.integer "exam_body_id"
    t.string "survey_url"
    t.integer "group_id"
    t.integer "quiz_pass_rate"
    t.string "background_image_file_name"
    t.string "background_image_content_type"
    t.integer "background_image_file_size"
    t.datetime "background_image_updated_at"
    t.boolean "preview", default: false
    t.boolean "computer_based", default: false
    t.string "highlight_colour", default: "#ef475d"
    t.string "category_label"
    t.string "icon_label"
    t.integer "constructed_response_count", default: 0
    t.integer "completion_cme_count"
    t.date "release_date"
    t.index ["name"], name: "index_subject_courses_on_name"
  end

  create_table "subscription_payment_cards", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "stripe_card_guid"
    t.string "status"
    t.string "brand"
    t.string "last_4"
    t.integer "expiry_month"
    t.integer "expiry_year"
    t.string "address_line1"
    t.string "account_country"
    t.integer "account_country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "stripe_object_name"
    t.string "funding"
    t.string "cardholder_name"
    t.string "fingerprint"
    t.string "cvc_checked"
    t.string "address_line1_check"
    t.string "address_zip_check"
    t.string "dynamic_last4"
    t.string "customer_guid"
    t.boolean "is_default_card", default: false
    t.string "address_line2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zip"
    t.string "address_country"
    t.index ["account_country_id"], name: "index_subscription_payment_cards_on_account_country_id"
    t.index ["stripe_card_guid"], name: "index_subscription_payment_cards_on_stripe_card_guid"
    t.index ["user_id"], name: "index_subscription_payment_cards_on_user_id"
  end

  create_table "subscription_plan_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "available_from"
    t.datetime "available_to"
    t.string "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sub_heading_text"
    t.index ["available_from"], name: "index_subscription_plan_categories_on_available_from"
    t.index ["available_to"], name: "index_subscription_plan_categories_on_available_to"
    t.index ["guid"], name: "index_subscription_plan_categories_on_guid"
    t.index ["name"], name: "index_subscription_plan_categories_on_name"
  end

  create_table "subscription_plans", id: :serial, force: :cascade do |t|
    t.integer "payment_frequency_in_months", default: 1
    t.integer "currency_id"
    t.decimal "price"
    t.date "available_from"
    t.date "available_to"
    t.string "stripe_guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.integer "subscription_plan_category_id"
    t.boolean "livemode", default: false
    t.string "paypal_guid"
    t.string "paypal_state"
    t.integer "monthly_percentage_off"
    t.float "previous_plan_price"
    t.bigint "exam_body_id"
    t.string "guid"
    t.string "bullet_points_list"
    t.string "sub_heading_text"
    t.boolean "most_popular", default: false, null: false
    t.index ["available_from"], name: "index_subscription_plans_on_available_from"
    t.index ["available_to"], name: "index_subscription_plans_on_available_to"
    t.index ["currency_id"], name: "index_subscription_plans_on_currency_id"
    t.index ["exam_body_id"], name: "index_subscription_plans_on_exam_body_id"
    t.index ["payment_frequency_in_months"], name: "index_subscription_plans_on_payment_frequency_in_months"
  end

  create_table "subscription_transactions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "subscription_id"
    t.string "stripe_transaction_guid"
    t.string "transaction_type"
    t.decimal "amount"
    t.integer "currency_id"
    t.boolean "alarm", default: false, null: false
    t.boolean "live_mode", default: false, null: false
    t.text "original_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "subscription_payment_card_id"
    t.index ["alarm"], name: "index_subscription_transactions_on_alarm"
    t.index ["currency_id"], name: "index_subscription_transactions_on_currency_id"
    t.index ["live_mode"], name: "index_subscription_transactions_on_live_mode"
    t.index ["stripe_transaction_guid"], name: "index_subscription_transactions_on_stripe_transaction_guid"
    t.index ["subscription_id"], name: "index_subscription_transactions_on_subscription_id"
    t.index ["transaction_type"], name: "index_subscription_transactions_on_transaction_type"
    t.index ["user_id"], name: "index_subscription_transactions_on_user_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "subscription_plan_id"
    t.string "stripe_guid"
    t.date "next_renewal_date"
    t.boolean "complimentary", default: false, null: false
    t.string "stripe_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "stripe_customer_id"
    t.text "stripe_customer_data"
    t.boolean "livemode", default: false
    t.boolean "active", default: false
    t.boolean "terms_and_conditions", default: false
    t.integer "coupon_id"
    t.string "paypal_subscription_guid"
    t.string "paypal_token"
    t.string "paypal_status"
    t.string "state"
    t.datetime "cancelled_at"
    t.string "cancellation_reason"
    t.text "cancellation_note"
    t.index ["next_renewal_date"], name: "index_subscriptions_on_next_renewal_date"
    t.index ["stripe_status"], name: "index_subscriptions_on_stripe_status"
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "user_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "tutor", default: false, null: false
    t.boolean "site_admin", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "system_requirements_access", default: false
    t.boolean "content_management_access", default: false
    t.boolean "stripe_management_access", default: false
    t.boolean "user_management_access", default: false
    t.boolean "developer_access", default: false
    t.boolean "user_group_management_access", default: false
    t.boolean "student_user", default: false
    t.boolean "trial_or_sub_required", default: false
    t.boolean "blocked_user", default: false
    t.boolean "marketing_resources_access", default: false
    t.boolean "exercise_corrections_access", default: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.text "address"
    t.integer "country_id"
    t.string "crypted_password", limit: 128, default: "", null: false
    t.string "password_salt", limit: 128, default: "", null: false
    t.string "persistence_token"
    t.string "perishable_token", limit: 128
    t.string "single_access_token"
    t.integer "login_count", default: 0
    t.integer "failed_login_count", default: 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string "current_login_ip"
    t.string "last_login_ip"
    t.string "account_activation_code"
    t.datetime "account_activated_at"
    t.boolean "active", default: false, null: false
    t.integer "user_group_id"
    t.datetime "password_reset_requested_at"
    t.string "password_reset_token"
    t.datetime "password_reset_at"
    t.string "stripe_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "locale"
    t.string "guid"
    t.integer "subscription_plan_category_id"
    t.boolean "password_change_required"
    t.string "session_key"
    t.string "name_url"
    t.string "profile_image_file_name"
    t.string "profile_image_content_type"
    t.integer "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.string "email_verification_code"
    t.datetime "email_verified_at"
    t.boolean "email_verified", default: false, null: false
    t.integer "stripe_account_balance", default: 0
    t.boolean "free_trial", default: false
    t.boolean "terms_and_conditions", default: false
    t.date "date_of_birth"
    t.text "description"
    t.string "analytics_guid"
    t.string "student_number"
    t.boolean "unsubscribed_from_emails", default: false
    t.boolean "communication_approval", default: false
    t.datetime "communication_approval_datetime"
    t.bigint "preferred_exam_body_id"
    t.index ["account_activation_code"], name: "index_users_on_account_activation_code"
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token"
    t.index ["persistence_token"], name: "index_users_on_persistence_token"
    t.index ["preferred_exam_body_id"], name: "index_users_on_preferred_exam_body_id"
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id"
    t.index ["subscription_plan_category_id"], name: "index_users_on_subscription_plan_category_id"
    t.index ["user_group_id"], name: "index_users_on_user_group_id"
  end

  create_table "vat_codes", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.string "name"
    t.string "label"
    t.string "wiki_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["country_id"], name: "index_vat_codes_on_country_id"
  end

  create_table "vat_rates", id: :serial, force: :cascade do |t|
    t.integer "vat_code_id"
    t.float "percentage_rate"
    t.date "effective_from"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["vat_code_id"], name: "index_vat_rates_on_vat_code_id"
  end

  create_table "video_resources", id: :serial, force: :cascade do |t|
    t.integer "course_module_element_id"
    t.text "question"
    t.text "answer"
    t.text "notes"
    t.datetime "destroyed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "transcript"
    t.index ["course_module_element_id"], name: "index_video_resources_on_course_module_element_id"
  end

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid "visitor_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.text "landing_page"
    t.integer "user_id"
    t.string "referring_domain"
    t.string "search_keyword"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.integer "screen_height"
    t.integer "screen_width"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "exercises", "products"
  add_foreign_key "exercises", "users"
  add_foreign_key "exercises", "users", column: "corrector_id"
  add_foreign_key "groups", "exam_bodies"
  add_foreign_key "subscription_plans", "exam_bodies"
  add_foreign_key "users", "exam_bodies", column: "preferred_exam_body_id"
end
