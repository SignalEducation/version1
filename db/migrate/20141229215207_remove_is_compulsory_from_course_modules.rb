class RemoveIsCompulsoryFromCourseModules < ActiveRecord::Migration
  def up
    remove_column :course_modules, :compulsory
  end
  def down
    add_column :course_modules, :compulsory, :boolean
  end
end
