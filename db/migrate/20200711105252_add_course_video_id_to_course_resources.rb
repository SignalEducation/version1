class AddCourseVideoIdToCourseResources < ActiveRecord::Migration[5.2]
  def change
    add_column :course_resources, :course_step_id, :integer
  end
end
