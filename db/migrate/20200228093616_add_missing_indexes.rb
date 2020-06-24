class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :constructed_response_attempts, :course_module_element_user_log_id, name: 'index_attempts_on_course_module_element_user_log_id'
    add_index :content_page_sections, :content_page_id
    add_index :content_page_sections, :subject_course_id
    add_index :countries, :currency_id
    add_index :coupons, :currency_id
    add_index :coupons, :exam_body_id
    add_index :course_module_element_quizzes, :course_module_element_id
    add_index :course_module_element_resources, :course_module_element_id, name: 'index_cme_resources_on_course_module_element_id'
    add_index :course_module_element_user_logs, :course_module_element_id, name: 'index_cme_logs_on_course_module_element_id'
    add_index :course_module_element_user_logs, :course_module_id, name: 'index_cme_user_logs_on_course_module_id'
    add_index :course_module_element_user_logs, :course_section_id, name: 'index_cme_user_logs_on_course_section_id'
    add_index :course_module_element_user_logs, :course_section_user_log_id, name: 'index_cme_user_logs_on_course_section_user_log_id'
    add_index :course_module_element_user_logs, :student_exam_track_id, name: 'index_cme_user_logs_on_student_exam_track_id'
    add_index :course_module_element_user_logs, :subject_course_id, name: 'index_cme_user_logs_on_subject_course_id'
    add_index :course_module_element_user_logs, :subject_course_user_log_id, name: 'index_cme_user_logs_on_subject_course_user_log_id'
    add_index :course_module_element_user_logs, :user_id, name: 'index_cme_user_logs_on_user_id'
    add_index :course_module_element_videos, :course_module_element_id, name: 'index_cme_videos_on_course_module_element_id'
    add_index :course_module_elements, :course_module_id
    add_index :course_module_elements, :related_course_module_element_id, name: 'index_cme_on_course_module_element_id'
    add_index :course_modules, :course_section_id
    add_index :course_modules, :subject_course_id
    add_index :course_section_user_logs, :subject_course_id
    add_index :enrollments, :exam_body_id
    add_index :enrollments, :exam_sitting_id
    add_index :enrollments, :subject_course_id
    add_index :enrollments, :subject_course_user_log_id
    add_index :enrollments, :user_id
    add_index :exam_sittings, :exam_body_id
    add_index :external_banners, :content_page_id
    add_index :external_banners, :home_page_id
    add_index :home_pages, :group_id
    add_index :home_pages, :subject_course_id
    add_index :invoice_line_items, :currency_id
    add_index :invoice_line_items, :invoice_id
    add_index :invoice_line_items, :subscription_id
    add_index :invoice_line_items, :subscription_plan_id
    add_index :invoices, :currency_id
    add_index :invoices, :subscription_id
    add_index :invoices, :user_id
    add_index :invoices, :vat_rate_id
    add_index :ip_addresses, :country_id
    add_index :orders, :ahoy_visit_id
    add_index :orders, :mock_exam_id
    add_index :products, :currency_id
    add_index :products, :group_id
    add_index :scenario_answer_attempts, :scenario_answer_template_id
    add_index :scenario_answer_attempts, :scenario_question_attempt_id
    add_index :scenario_answer_attempts, :user_id
    add_index :scenario_question_attempts, :constructed_response_attempt_id, name: 'index_sq_attempts_on_constructed_response_attempt_id'
    add_index :scenario_question_attempts, :user_id
    add_index :student_accesses, :user_id
    add_index :student_exam_tracks, :course_module_id
    add_index :student_exam_tracks, :course_section_id
    add_index :student_exam_tracks, :course_section_user_log_id
    add_index :student_exam_tracks, :latest_course_module_element_id
    add_index :student_exam_tracks, :subject_course_id
    add_index :student_exam_tracks, :subject_course_user_log_id
    add_index :student_exam_tracks, :user_id
    add_index :subject_course_user_logs, :latest_course_module_element_id, name: 'index_scu_logs_on_latest_course_module_element_id'
    add_index :subject_courses, :exam_body_id
    add_index :subject_courses, :group_id
    add_index :subject_courses, :level_id
    add_index :subscription_payment_cards, :account_country_id
    add_index :subscription_payment_cards, :user_id
    add_index :subscription_plans, :currency_id
    add_index :subscription_plans, :subscription_plan_category_id
    add_index :subscriptions, :ahoy_visit_id
    add_index :subscriptions, :coupon_id
    add_index :subscriptions, :subscription_plan_id
    add_index :subscriptions, :user_id
    add_index :users, :country_id
    add_index :users, :user_group_id
    add_index :vat_codes, :country_id
    add_index :vat_rates, :vat_code_id
  end
end
