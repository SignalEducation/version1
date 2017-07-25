class AddCountFieldToSubjectCourse < ActiveRecord::Migration
  def change
    add_column :subject_courses, :total_estimated_time_in_seconds, :integer
    remove_column :course_module_element_videos, :estimated_study_time_seconds, :integer
    remove_column :course_module_element_resources, :description, :text
  end
end
