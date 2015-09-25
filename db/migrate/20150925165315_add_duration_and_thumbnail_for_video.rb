class AddDurationAndThumbnailForVideo < ActiveRecord::Migration
  def change
    add_column :course_module_element_videos, :duration, :float
    add_column :course_module_element_videos, :thumbnail, :text
    add_column :subject_courses, :restricted, :boolean, default: false, null: false, index: true
    add_column :subject_courses, :corporate_customer_id, :integer, index: true
  end
end
