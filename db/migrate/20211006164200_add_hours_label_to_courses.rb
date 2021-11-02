class AddHoursLabelToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :hours_label, :string
  end
end
