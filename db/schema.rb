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

ActiveRecord::Schema.define(version: 20150514094454) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blog_categories", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "name_url",      limit: 255
    t.integer  "sorting_order"
    t.boolean  "active",                    default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string   "title",            limit: 255
    t.string   "name_url",         limit: 255
    t.text     "content"
    t.string   "excerpt",          limit: 255
    t.boolean  "active",                       default: false, null: false
    t.text     "tags"
    t.integer  "blog_category_id"
    t.integer  "author_id"
    t.integer  "old_blog_id"
    t.string   "seo_title",        limit: 255
    t.string   "seo_description",  limit: 255
    t.datetime "publish_from"
    t.datetime "publish_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_image_galleries", force: :cascade do |t|
    t.integer  "bootsy_resource_id"
    t.string   "bootsy_resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: :cascade do |t|
    t.string   "image_file",       limit: 255
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "corporate_customers", force: :cascade do |t|
    t.string   "organisation_name",    limit: 255
    t.text     "address"
    t.integer  "country_id"
    t.boolean  "payments_by_card",                 default: false, null: false
    t.boolean  "is_university",                    default: false, null: false
    t.integer  "owner_id"
    t.string   "stripe_customer_guid", limit: 255
    t.boolean  "can_restrict_content",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "iso_code",      limit: 255
    t.string   "country_tld",   limit: 255
    t.integer  "sorting_order"
    t.boolean  "in_the_eu",                 default: false, null: false
    t.integer  "currency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "continent",     limit: 255
  end

  create_table "course_module_element_flash_card_packs", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.string   "background_color",         limit: 255
    t.string   "foreground_color",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  create_table "course_module_element_quizzes", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.integer  "number_of_questions"
    t.string   "question_selection_strategy",       limit: 255
    t.integer  "best_possible_score_first_attempt"
    t.integer  "best_possible_score_retry"
    t.integer  "course_module_jumbo_quiz_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  create_table "course_module_element_resources", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.string   "name",                     limit: 255
    t.text     "description"
    t.string   "web_url",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name",         limit: 255
    t.string   "upload_content_type",      limit: 255
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "destroyed_at"
  end

  create_table "course_module_element_user_logs", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.integer  "user_id"
    t.string   "session_guid",                limit: 255
    t.boolean  "element_completed",                       default: false, null: false
    t.integer  "time_taken_in_seconds"
    t.integer  "quiz_score_actual"
    t.integer  "quiz_score_potential"
    t.boolean  "is_video",                                default: false, null: false
    t.boolean  "is_quiz",                                 default: false, null: false
    t.integer  "course_module_id"
    t.boolean  "latest_attempt",                          default: true,  null: false
    t.integer  "corporate_customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "course_module_jumbo_quiz_id"
    t.boolean  "is_jumbo_quiz",                           default: false, null: false
  end

  create_table "course_module_element_videos", force: :cascade do |t|
    t.integer  "course_module_element_id"
    t.integer  "raw_video_file_id"
    t.string   "tags",                         limit: 255
    t.string   "difficulty_level",             limit: 255
    t.integer  "estimated_study_time_seconds"
    t.text     "transcript"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  create_table "course_module_elements", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.string   "name_url",                  limit: 255
    t.text     "description"
    t.integer  "estimated_time_in_seconds"
    t.integer  "course_module_id"
    t.integer  "sorting_order"
    t.integer  "forum_topic_id"
    t.integer  "tutor_id"
    t.integer  "related_quiz_id"
    t.integer  "related_video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_video",                              default: false, null: false
    t.boolean  "is_quiz",                               default: false, null: false
    t.boolean  "active",                                default: true,  null: false
    t.boolean  "is_cme_flash_card_pack",                default: false, null: false
    t.string   "seo_description",           limit: 255
    t.boolean  "seo_no_index",                          default: false
    t.datetime "destroyed_at"
  end

  create_table "course_module_jumbo_quizzes", force: :cascade do |t|
    t.integer  "course_module_id"
    t.string   "name",                              limit: 255
    t.integer  "minimum_question_count_per_quiz"
    t.integer  "maximum_question_count_per_quiz"
    t.integer  "total_number_of_questions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_url",                          limit: 255
    t.integer  "best_possible_score_first_attempt",             default: 0
    t.integer  "best_possible_score_retry",                     default: 0
    t.datetime "destroyed_at"
  end

  create_table "course_modules", force: :cascade do |t|
    t.integer  "institution_id"
    t.integer  "qualification_id"
    t.integer  "exam_level_id"
    t.integer  "exam_section_id"
    t.string   "name",                      limit: 255
    t.string   "name_url",                  limit: 255
    t.text     "description"
    t.integer  "tutor_id"
    t.integer  "sorting_order"
    t.integer  "estimated_time_in_seconds"
    t.boolean  "active",                                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cme_count",                             default: 0
    t.string   "seo_description",           limit: 255
    t.boolean  "seo_no_index",                          default: false
    t.datetime "destroyed_at"
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "iso_code",        limit: 255
    t.string   "name",            limit: 255
    t.string   "leading_symbol",  limit: 255
    t.string   "trailing_symbol", limit: 255
    t.boolean  "active",                      default: false, null: false
    t.integer  "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exam_levels", force: :cascade do |t|
    t.integer  "qualification_id"
    t.string   "name",                                    limit: 255
    t.string   "name_url",                                limit: 255
    t.boolean  "is_cpd",                                              default: false, null: false
    t.integer  "sorting_order"
    t.boolean  "active",                                              default: false, null: false
    t.float    "best_possible_first_attempt_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "default_number_of_possible_exam_answers",             default: 4
    t.boolean  "enable_exam_sections",                                default: true,  null: false
    t.integer  "cme_count",                                           default: 0
    t.string   "seo_description",                         limit: 255
    t.boolean  "seo_no_index",                                        default: false
    t.text     "description"
    t.integer  "duration"
  end

  create_table "exam_sections", force: :cascade do |t|
    t.string   "name",                              limit: 255
    t.string   "name_url",                          limit: 255
    t.integer  "exam_level_id"
    t.boolean  "active",                                        default: false, null: false
    t.integer  "sorting_order"
    t.float    "best_possible_first_attempt_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cme_count",                                     default: 0
    t.string   "seo_description",                   limit: 255
    t.boolean  "seo_no_index",                                  default: false
    t.integer  "duration"
  end

  create_table "flash_card_stacks", force: :cascade do |t|
    t.integer  "course_module_element_flash_card_pack_id"
    t.string   "name",                                     limit: 255
    t.integer  "sorting_order"
    t.string   "final_button_label",                       limit: 255
    t.string   "content_type",                             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  create_table "flash_cards", force: :cascade do |t|
    t.integer  "flash_card_stack_id"
    t.integer  "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  create_table "flash_quizzes", force: :cascade do |t|
    t.integer  "flash_card_stack_id"
    t.string   "background_color",    limit: 255
    t.string   "foreground_color",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  create_table "forum_post_concerns", force: :cascade do |t|
    t.integer  "forum_post_id"
    t.integer  "user_id"
    t.string   "reason",        limit: 255
    t.boolean  "live",                      default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forum_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "content"
    t.integer  "forum_topic_id"
    t.boolean  "blocked",                   default: false, null: false
    t.integer  "response_to_forum_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forum_topic_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "forum_topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forum_topics", force: :cascade do |t|
    t.integer  "forum_topic_id"
    t.integer  "course_module_element_id"
    t.string   "heading",                  limit: 255
    t.text     "description"
    t.boolean  "active",                               default: true, null: false
    t.datetime "publish_from"
    t.datetime "publish_until"
    t.integer  "reviewed_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
  end

  create_table "import_trackers", force: :cascade do |t|
    t.string   "old_model_name", limit: 255
    t.integer  "old_model_id"
    t.string   "new_model_name", limit: 255
    t.integer  "new_model_id"
    t.datetime "imported_at"
    t.text     "original_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "institution_users", force: :cascade do |t|
    t.integer  "institution_id"
    t.integer  "user_id"
    t.string   "student_registration_number", limit: 255
    t.boolean  "student",                                 default: false, null: false
    t.boolean  "qualified",                               default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "exam_number",                 limit: 255
    t.string   "membership_number",           limit: 255
  end

  create_table "institutions", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "short_name",             limit: 255
    t.string   "name_url",               limit: 255
    t.text     "description"
    t.string   "feedback_url",           limit: 255
    t.string   "help_desk_url",          limit: 255
    t.integer  "subject_area_id"
    t.integer  "sorting_order"
    t.boolean  "active",                             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_colour_code", limit: 255
    t.string   "seo_description",        limit: 255
    t.boolean  "seo_no_index",                       default: false
  end

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
    t.string   "stripe_guid",                 limit: 255
    t.decimal  "sub_total",                               default: 0.0
    t.decimal  "total",                                   default: 0.0
    t.decimal  "total_tax",                               default: 0.0
    t.string   "stripe_customer_guid",        limit: 255
    t.string   "object_type",                 limit: 255, default: "invoice"
    t.boolean  "payment_attempted",                       default: false
    t.boolean  "payment_closed",                          default: false
    t.boolean  "forgiven",                                default: false
    t.boolean  "paid",                                    default: false
    t.boolean  "livemode",                                default: false
    t.integer  "attempt_count",                           default: 0
    t.decimal  "amount_due",                              default: 0.0
    t.datetime "next_payment_attempt_at"
    t.datetime "webhooks_delivered_at"
    t.string   "charge_guid",                 limit: 255
    t.string   "subscription_guid",           limit: 255
    t.decimal  "tax_percent"
    t.decimal  "tax"
    t.text     "original_stripe_data"
  end

  create_table "ip_addresses", force: :cascade do |t|
    t.string   "ip_address",  limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "country_id"
    t.integer  "alert_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "marketing_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "marketing_tokens", force: :cascade do |t|
    t.string   "code"
    t.integer  "marketing_category_id"
    t.boolean  "is_hard",               default: false, null: false
    t.boolean  "is_direct",             default: false, null: false
    t.boolean  "is_seo",                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "marketing_tokens", ["marketing_category_id"], name: "index_marketing_tokens_on_marketing_category_id", using: :btree

  create_table "qualifications", force: :cascade do |t|
    t.integer  "institution_id"
    t.string   "name",                        limit: 255
    t.string   "name_url",                    limit: 255
    t.integer  "sorting_order"
    t.boolean  "active",                                  default: false, null: false
    t.integer  "cpd_hours_required_per_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "seo_description",             limit: 255
    t.boolean  "seo_no_index",                            default: false
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.integer  "quiz_question_id"
    t.boolean  "correct",                                   default: false, null: false
    t.string   "degree_of_wrongness",           limit: 255
    t.text     "wrong_answer_explanation_text"
    t.integer  "wrong_answer_video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "destroyed_at"
  end

  create_table "quiz_attempts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "quiz_question_id"
    t.integer  "quiz_answer_id"
    t.boolean  "correct",                                       default: false, null: false
    t.integer  "course_module_element_user_log_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score",                                         default: 0
    t.string   "answer_array",                      limit: 255
  end

  create_table "quiz_contents", force: :cascade do |t|
    t.integer  "quiz_question_id"
    t.integer  "quiz_answer_id"
    t.text     "text_content"
    t.boolean  "contains_mathjax",               default: false, null: false
    t.boolean  "contains_image",                 default: false, null: false
    t.integer  "sorting_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "quiz_solution_id"
    t.integer  "flash_card_id"
    t.datetime "destroyed_at"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.integer  "course_module_element_quiz_id"
    t.integer  "course_module_element_id"
    t.string   "difficulty_level",              limit: 255
    t.text     "hints"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flash_quiz_id"
    t.datetime "destroyed_at"
  end

  create_table "raw_video_files", force: :cascade do |t|
    t.string   "file_name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "transcode_requested_at"
    t.string   "transcode_request_guid", limit: 255
    t.string   "transcode_result",       limit: 255
    t.datetime "transcode_completed_at"
    t.datetime "raw_file_modified_at"
    t.string   "aws_etag",               limit: 255
    t.integer  "duration_in_seconds",                default: 0
    t.string   "guid_prefix",            limit: 255
  end

  create_table "static_page_uploads", force: :cascade do |t|
    t.string   "description",         limit: 255
    t.integer  "static_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
  end

  create_table "static_pages", force: :cascade do |t|
    t.string   "name",                          limit: 255
    t.datetime "publish_from"
    t.datetime "publish_to"
    t.boolean  "allow_multiples",                           default: false, null: false
    t.string   "public_url",                    limit: 255
    t.boolean  "use_standard_page_template",                default: false, null: false
    t.text     "head_content"
    t.text     "body_content"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.boolean  "add_to_navbar",                             default: false, null: false
    t.boolean  "add_to_footer",                             default: false, null: false
    t.string   "menu_label",                    limit: 255
    t.string   "tooltip_text",                  limit: 255
    t.string   "language",                      limit: 255
    t.boolean  "mark_as_noindex",                           default: false, null: false
    t.boolean  "mark_as_nofollow",                          default: false, null: false
    t.string   "seo_title",                     limit: 255
    t.string   "seo_description",               limit: 255
    t.text     "approved_country_ids"
    t.boolean  "default_page_for_this_url",                 default: false, null: false
    t.boolean  "make_this_page_sticky",                     default: false, null: false
    t.boolean  "logged_in_required",                        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_standard_footer",                      default: true
    t.string   "post_sign_up_redirect_url",     limit: 255
    t.integer  "subscription_plan_category_id"
    t.string   "student_sign_up_h1",            limit: 255
    t.string   "student_sign_up_sub_head",      limit: 255
  end

  create_table "stripe_api_events", force: :cascade do |t|
    t.string   "guid",          limit: 255
    t.string   "api_version",   limit: 255
    t.text     "payload"
    t.boolean  "processed",                 default: false, null: false
    t.datetime "processed_at"
    t.boolean  "error",                     default: false, null: false
    t.string   "error_message", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stripe_developer_calls", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "params_received"
    t.boolean  "prevent_delete",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "student_exam_tracks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "exam_level_id"
    t.integer  "exam_section_id"
    t.integer  "latest_course_module_element_id"
    t.integer  "exam_schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_guid",                    limit: 255
    t.integer  "course_module_id"
    t.boolean  "jumbo_quiz_taken",                            default: false
    t.float    "percentage_complete",                         default: 0.0
    t.integer  "count_of_cmes_completed",                     default: 0
  end

  create_table "subject_areas", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "name_url",        limit: 255
    t.integer  "sorting_order"
    t.boolean  "active",                      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "seo_description", limit: 255
    t.boolean  "seo_no_index",                default: false
  end

  create_table "subscription_payment_cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_card_guid",    limit: 255
    t.string   "status",              limit: 255
    t.string   "brand",               limit: 255
    t.string   "last_4",              limit: 255
    t.integer  "expiry_month"
    t.integer  "expiry_year"
    t.string   "address_line1",       limit: 255
    t.string   "account_country",     limit: 255
    t.integer  "account_country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_object_name",  limit: 255
    t.string   "funding",             limit: 255
    t.string   "cardholder_name",     limit: 255
    t.string   "fingerprint",         limit: 255
    t.string   "cvc_checked",         limit: 255
    t.string   "address_line1_check", limit: 255
    t.string   "address_zip_check",   limit: 255
    t.string   "dynamic_last4",       limit: 255
    t.string   "customer_guid",       limit: 255
    t.boolean  "is_default_card",                 default: false
    t.string   "address_line2",       limit: 255
    t.string   "address_city",        limit: 255
    t.string   "address_state",       limit: 255
    t.string   "address_zip",         limit: 255
    t.string   "address_country",     limit: 255
  end

  create_table "subscription_plan_categories", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "available_from"
    t.datetime "available_to"
    t.string   "guid",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.boolean  "available_to_students",                     default: false, null: false
    t.boolean  "available_to_corporates",                   default: false, null: false
    t.boolean  "all_you_can_eat",                           default: true,  null: false
    t.integer  "payment_frequency_in_months",               default: 1
    t.integer  "currency_id"
    t.decimal  "price"
    t.date     "available_from"
    t.date     "available_to"
    t.string   "stripe_guid",                   limit: 255
    t.integer  "trial_period_in_days",                      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                          limit: 255
    t.integer  "subscription_plan_category_id"
    t.boolean  "livemode",                                  default: false
  end

  create_table "subscription_transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "subscription_id"
    t.string   "stripe_transaction_guid",      limit: 255
    t.string   "transaction_type",             limit: 255
    t.decimal  "amount"
    t.integer  "currency_id"
    t.boolean  "alarm",                                    default: false, null: false
    t.boolean  "live_mode",                                default: false, null: false
    t.text     "original_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subscription_payment_card_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "corporate_customer_id"
    t.integer  "subscription_plan_id"
    t.string   "stripe_guid",           limit: 255
    t.date     "next_renewal_date"
    t.boolean  "complimentary",                     default: false, null: false
    t.string   "current_status",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_customer_id",    limit: 255
    t.text     "stripe_customer_data"
    t.boolean  "livemode",                          default: false
  end

  create_table "system_defaults", force: :cascade do |t|
    t.integer  "individual_student_user_group_id"
    t.integer  "corporate_student_user_group_id"
    t.integer  "corporate_customer_user_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "user_activity_logs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "session_guid",                     limit: 255
    t.boolean  "signed_in",                                    default: false, null: false
    t.text     "original_uri"
    t.string   "controller_name",                  limit: 255
    t.string   "action_name",                      limit: 255
    t.text     "params"
    t.integer  "alert_level",                                  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address",                       limit: 255
    t.string   "browser",                          limit: 255
    t.string   "operating_system",                 limit: 255
    t.boolean  "phone",                                        default: false, null: false
    t.boolean  "tablet",                                       default: false, null: false
    t.boolean  "computer",                                     default: false, null: false
    t.string   "guid",                             limit: 255
    t.integer  "ip_address_id"
    t.string   "browser_version",                  limit: 255
    t.string   "raw_user_agent",                   limit: 255
    t.text     "first_session_landing_page"
    t.text     "latest_session_landing_page"
    t.string   "post_sign_up_redirect_url",        limit: 255
    t.integer  "marketing_token_id"
    t.datetime "marketing_token_cookie_issued_at"
  end

  create_table "user_exam_levels", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "exam_level_id"
    t.integer  "exam_schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_groups", force: :cascade do |t|
    t.string   "name",                                 limit: 255
    t.text     "description"
    t.boolean  "individual_student",                               default: false, null: false
    t.boolean  "corporate_student",                                default: false, null: false
    t.boolean  "tutor",                                            default: false, null: false
    t.boolean  "content_manager",                                  default: false, null: false
    t.boolean  "blogger",                                          default: false, null: false
    t.boolean  "corporate_customer",                               default: false, null: false
    t.boolean  "site_admin",                                       default: false, null: false
    t.boolean  "forum_manager",                                    default: false, null: false
    t.boolean  "subscription_required_at_sign_up",                 default: false, null: false
    t.boolean  "subscription_required_to_see_content",             default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_likes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "likeable_type", limit: 255
    t.integer  "likeable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "subject_line",   limit: 255
    t.text     "content"
    t.boolean  "email_required",             default: false, null: false
    t.datetime "email_sent_at"
    t.boolean  "unread",                     default: true,  null: false
    t.datetime "destroyed_at"
    t.string   "message_type",   limit: 255
    t.integer  "forum_topic_id"
    t.integer  "forum_post_id"
    t.integer  "tutor_id"
    t.boolean  "falling_behind",                             null: false
    t.integer  "blog_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                    limit: 255
    t.string   "first_name",                               limit: 255
    t.string   "last_name",                                limit: 255
    t.text     "address"
    t.integer  "country_id"
    t.string   "crypted_password",                         limit: 128, default: "",    null: false
    t.string   "password_salt",                            limit: 128, default: "",    null: false
    t.string   "persistence_token",                        limit: 255
    t.string   "perishable_token",                         limit: 128
    t.string   "single_access_token",                      limit: 255
    t.integer  "login_count",                                          default: 0
    t.integer  "failed_login_count",                                   default: 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",                         limit: 255
    t.string   "last_login_ip",                            limit: 255
    t.string   "account_activation_code",                  limit: 255
    t.datetime "account_activated_at"
    t.boolean  "active",                                               default: false, null: false
    t.integer  "user_group_id"
    t.datetime "password_reset_requested_at"
    t.string   "password_reset_token",                     limit: 255
    t.datetime "password_reset_at"
    t.string   "stripe_customer_id",                       limit: 255
    t.integer  "corporate_customer_id"
    t.integer  "corporate_customer_user_group_id"
    t.string   "operational_email_frequency",              limit: 255
    t.string   "study_plan_notifications_email_frequency", limit: 255
    t.string   "falling_behind_email_alert_frequency",     limit: 255
    t.string   "marketing_email_frequency",                limit: 255
    t.datetime "marketing_email_permission_given_at"
    t.string   "blog_notification_email_frequency",        limit: 255
    t.string   "forum_notification_email_frequency",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale",                                   limit: 255
    t.string   "guid",                                     limit: 255
  end

  create_table "vat_codes", force: :cascade do |t|
    t.integer  "country_id"
    t.string   "name",       limit: 255
    t.string   "label",      limit: 255
    t.string   "wiki_url",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vat_rates", force: :cascade do |t|
    t.integer  "vat_code_id"
    t.float    "percentage_rate"
    t.date     "effective_from"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
