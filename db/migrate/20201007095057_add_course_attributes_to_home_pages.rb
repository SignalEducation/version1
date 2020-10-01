class AddCourseAttributesToHomePages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :course_description, :text
    add_column :home_pages, :header_description, :text
  end
end
