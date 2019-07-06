class AddTemporaryLabelToCourseModules < ActiveRecord::Migration[5.2]
  def change
    add_column :course_modules, :temporary_label, :string
  end
end
