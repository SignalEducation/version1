class CourseTablesChanges < ActiveRecord::Migration[5.2]
  def change
    rename_table :course_modules, :course_lessons
    rename_table :course_module_elements, :course_steps
    rename_table :course_module_element_quizzes, :course_quizzes
    rename_table :course_module_element_resources, :course_notes
    rename_table :course_module_element_videos, :course_videos
    rename_table :course_module_element_user_logs, :course_step_logs
    rename_table :course_section_user_logs, :course_section_logs
    rename_table :course_tutor_details, :course_tutors
    rename_table :groups_subject_courses, :groups_courses
    rename_table :student_exam_tracks, :course_lesson_logs
    rename_table :subject_courses, :courses
    rename_table :subject_course_resources, :course_resources
    rename_table :subject_course_user_logs, :course_logs

    rename_column :cbes, :subject_course_id, :course_id
    rename_column :content_page_sections, :subject_course_id, :course_id
    rename_column :constructed_responses, :course_module_element_id, :course_step_id
    rename_column :constructed_response_attempts, :course_module_element_id, :course_step_id
    rename_column :constructed_response_attempts, :course_module_element_user_log_id, :course_step_log_id
    rename_column :course_lessons, :subject_course_id, :course_id
    rename_column :course_lesson_logs, :subject_course_id, :course_id
    rename_column :course_lesson_logs, :subject_course_user_log_id, :course_log_id
    rename_column :course_lesson_logs, :course_section_user_log_id, :course_section_log_id
    rename_column :course_lesson_logs, :latest_course_module_element_id, :latest_course_step_id
    rename_column :course_logs, :subject_course_id, :course_id
    rename_column :course_logs, :latest_course_module_element_id, :latest_course_step_id
    rename_column :course_notes, :course_module_element_id, :course_step_id
    rename_column :course_quizzes, :course_module_element_id, :course_step_id
    rename_column :course_resources, :subject_course_id, :course_id
    rename_column :course_section_logs, :subject_course_id, :course_id
    rename_column :course_section_logs, :subject_course_user_log_id, :course_log_id
    rename_column :course_section_logs, :latest_course_module_element_id, :latest_course_step_id
    rename_column :course_sections, :subject_course_id, :course_id
    rename_column :course_steps, :related_course_module_element_id, :related_course_step_id
    rename_column :course_steps, :course_module_id, :course_lesson_id
    rename_column :course_lesson_logs, :course_module_id, :course_lesson_id
    rename_column :course_step_logs, :course_module_id, :course_lesson_id

    rename_column :course_step_logs, :subject_course_id, :course_id
    rename_column :course_step_logs, :subject_course_user_log_id, :course_log_id
    rename_column :course_step_logs, :course_section_user_log_id, :course_section_log_id
    rename_column :course_step_logs, :student_exam_track_id, :course_lesson_log_id
    rename_column :course_step_logs, :course_module_element_id, :course_step_id
    rename_column :course_tutors, :subject_course_id, :course_id
    rename_column :course_videos, :course_module_element_id, :course_step_id
    rename_column :enrollments, :subject_course_id, :course_id
    rename_column :enrollments, :subject_course_user_log_id, :course_log_id
    rename_column :exam_sittings, :subject_course_id, :course_id
    rename_column :groups_courses, :subject_course_id, :course_id
    rename_column :home_pages, :subject_course_id, :course_id
    rename_column :mock_exams, :subject_course_id, :course_id
    rename_column :orders, :subject_course_id, :course_id
    rename_column :products, :subject_course_id, :course_id
    rename_column :quiz_questions, :subject_course_id, :course_id
    rename_column :quiz_questions, :course_module_element_id, :course_step_id
    rename_column :quiz_questions, :course_module_element_quiz_id, :course_quiz_id
    rename_column :quiz_attempts, :course_module_element_user_log_id, :course_step_log_id
    rename_column :video_resources, :course_module_element_id, :course_step_id

    rename_index :constructed_response_attempts, 'index_attempts_on_course_module_element_user_log_id', 'index_attempts_on_course_step_log_id'
    rename_index :course_notes, 'index_cme_resources_on_course_module_element_id', 'index_course_notes_on_course_step_id'
    rename_index :course_step_logs, 'index_cme_user_logs_on_subject_course_id', 'index_course_step_logs_on_course_id'
    rename_index :course_step_logs, 'index_cme_user_logs_on_subject_course_user_log_id', 'index_course_step_logs_on_course_log_id'
    rename_index :course_step_logs, 'index_cme_user_logs_on_course_section_id', 'index_course_step_logs_on_course_section_id'
    rename_index :course_step_logs, 'index_cme_user_logs_on_course_section_user_log_id', 'index_course_step_logs_on_course_section_log_id'
    rename_index :course_step_logs, 'index_cme_logs_on_course_module_element_id', 'index_course_step_logs_on_course_step_id'
    rename_index :course_step_logs, 'index_cme_user_logs_on_student_exam_track_id', 'index_course_step_logs_on_course_lesson_log_id'
    rename_index :course_step_logs, 'index_cme_user_logs_on_course_module_id', 'index_course_step_logs_on_course_lesson_id'
    rename_index :course_steps, 'index_cme_on_course_module_element_id', 'index_course_steps_on_related_course_step_id'
    rename_index :course_steps, 'index_scu_logs_on_latest_course_module_element_id', 'index_scu_logs_on_latest_course_step_id'
    rename_index :course_videos, 'index_cme_videos_on_course_module_element_id', 'index_course_videos_on_course_step_id'
  end
end
