class AddCountAttributesToCourseSection < ActiveRecord::Migration[4.2]
  def change
    add_column :course_sections, :cme_count, :integer, default: 0
    add_column :course_sections, :video_count, :integer, default: 0
    add_column :course_sections, :quiz_count, :integer, default: 0
    add_column :course_sections, :destroyed_at, :datetime
  end
end
