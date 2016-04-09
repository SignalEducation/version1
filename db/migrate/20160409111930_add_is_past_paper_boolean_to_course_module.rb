class AddIsPastPaperBooleanToCourseModule < ActiveRecord::Migration
  def change
    add_column :course_modules, :is_past_paper, :boolean, default: false, null: false, index: true
    add_column :course_modules, :highlight_colour, :string
  end
end
