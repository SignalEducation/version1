class AddProgressFieldsToCourseHierarchyModels < ActiveRecord::Migration
  def change
    add_column :subject_courses, :total_video_duration, :float, default: 0
    add_column :course_modules, :video_duration, :float, default: 0
    add_column :course_modules, :video_count, :integer, default: 0
    add_column :course_modules, :quiz_count, :integer, default: 0
    add_column :course_module_elements, :duration, :float, default: 0
  end
end
