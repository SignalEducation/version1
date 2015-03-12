class AddCmeCountToCourseModule < ActiveRecord::Migration
  def change
    add_column :course_modules, :cme_count, :integer, index: true, default: 0
  end
end
