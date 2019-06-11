class RemoveIsCompulsoryFromCourseModules < ActiveRecord::Migration[4.2]
  def up
    remove_column :course_modules, :compulsory
  end
  def down
    add_column :course_modules, :compulsory, :boolean
  end
end
