class MergeUnitHoursInCourse < ActiveRecord::Migration[5.2]
  def change
    rename_column :courses, :api_unit_label, :unit_hour_label
  end
end
