class ChangeHoursUnitToHourUnitInCoursesTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :courses, :hours_label, :hour_label
  end
end
