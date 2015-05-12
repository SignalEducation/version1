class AddDescriptionAndDurationToExamLevels < ActiveRecord::Migration
  def change
    add_column :exam_levels, :description, :text
    add_column :exam_levels, :duration, :integer
  end
end
