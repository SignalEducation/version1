class ChangeSubjectCourseToCourse < ActiveRecord::Migration[5.2]
  def change
    rename_table :subject_courses, :courses
    rename_table :subject_course_user_logs, :course_logs
    rename_table :subject_course_resources, :course_resources
    rename_table :course_sections, :course_sections
    rename_table :course_section_user_logs, :course_section_logs
    rename_table :course_modules, :course_lessons
    rename_table :student_exam_tracks, :course_lesson_logs
    rename_table :course_module_elements, :course_steps
    rename_table :course_module_element_user_logs, :course_step_logs
    rename_table :groups_subject_courses, :groups_courses
    rename_table :course_tutor_details, :tutor_details

    rename_column :cbes, :subject_course_id, :course_id
    rename_column :content_page_sections, :subject_course_id, :course_id
    rename_column :module_logs, :subject_course_id, :course_id
    rename_column :module_logs, :subject_course_user_log_id, :course_log_id
    rename_column :lessons, :subject_course_id, :course_id
    rename_column :section_logs, :subject_course_id, :course_id
    rename_column :course_sections, :subject_course_id, :course_id
    rename_column :tutor_details, :subject_course_id, :course_id
    rename_column :enrollments, :subject_course_id, :course_id
    rename_column :enrollments, :subject_course_user_log_id, :course_log_id
    rename_column :exam_sittings, :subject_course_id, :course_id
    rename_column :groups_courses, :subject_course_id, :course_id
    rename_column :home_pages, :subject_course_id, :course_id
    rename_column :mock_exams, :subject_course_id, :course_id
    rename_column :orders, :subject_course_id, :course_id
    rename_column :products, :subject_course_id, :course_id
    rename_column :quiz_questions, :subject_course_id, :course_id
    rename_column :student_exam_tracks, :subject_course_id, :course_id
    rename_column :student_exam_tracks, :subject_course_user_log_id, :course_log_id
    rename_column :course_resources, :subject_course_id, :course_id
    rename_column :course_logs, :subject_course_id, :course_id
    rename_column :section_logs, :subject_course_user_log_id, :course_log_id


    rename_index :module_logs, 'index_cme_user_logs_on_subject_course_id', 'index_module_logs_on_course_id'
    rename_index :module_logs, 'index_cme_user_logs_on_subject_course_user_log_id', 'index_module_logs_on_course_log_id'
  end
end
