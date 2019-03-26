class AddConstructedResponseCountToCourseModels < ActiveRecord::Migration
  def change
    add_column :course_modules, :constructed_response_count, :integer, default: 0
    add_column :course_sections, :constructed_response_count, :integer, default: 0
    add_column :subject_courses, :constructed_response_count, :integer, default: 0
  end
end
