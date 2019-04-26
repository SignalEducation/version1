class AddLiveToExamLevels < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_levels, :live, :boolean, index: true, default: false, null: false
  end
end
