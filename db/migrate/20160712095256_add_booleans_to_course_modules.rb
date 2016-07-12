class AddBooleansToCourseModules < ActiveRecord::Migration
  def change
    add_column :course_modules, :tuition, :boolean, default: false, index: true
    add_column :course_modules, :test, :boolean, default: false, index: true
    add_column :course_modules, :revision, :boolean, default: false, index: true
    remove_column :course_modules, :is_past_paper, :boolean
  end
end
