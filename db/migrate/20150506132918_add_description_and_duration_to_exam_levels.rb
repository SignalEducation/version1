class AddDescriptionAndDurationToExamLevels < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_levels, :description, :text
    add_column :exam_levels, :duration, :integer
  end
end
