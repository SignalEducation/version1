class AddLiveToExamLevels < ActiveRecord::Migration
  def change
    add_column :exam_levels, :live, :boolean, index: true, default: false, null: false
  end
end
