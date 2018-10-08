class RemoveDiscourseAttributesFromHomePageAndCourseModule < ActiveRecord::Migration
  def change
    remove_column :home_pages, :discourse_ids, :string
    remove_column :course_modules, :discourse_topic_id, :integer
  end
end
