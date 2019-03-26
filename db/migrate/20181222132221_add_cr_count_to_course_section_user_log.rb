class AddCrCountToCourseSectionUserLog < ActiveRecord::Migration[4.2]
  def change
    add_column :course_section_user_logs, :count_of_constructed_responses_taken, :integer
    remove_column :student_exam_tracks, :exam_schedule_id, :integer
  end
end
