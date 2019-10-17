class RemoveInitalSettingFromCbe < ActiveRecord::Migration[5.2]
  def change
    remove_column :cbes, :exam_time, :float
    remove_column :cbes, :hard_time_limit, :float
    remove_column :cbes, :number_of_pauses_allowed, :integer
    remove_column :cbes, :length_of_pauses, :integer
  end
end
