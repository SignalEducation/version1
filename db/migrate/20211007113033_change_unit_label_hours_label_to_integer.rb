class ChangeUnitLabelHoursLabelToInteger < ActiveRecord::Migration[5.2]
  def self.up
    add_column :courses, :api_unit_label, :integer
    change_column :courses, :hours_label, 'integer USING CAST(hours_label AS integer)'

    Course.all.each do |course|
      if course.unit_label.present?
        course.update(api_unit_label: course.unit_label.tr('^0-9', ''))
      end
    end
  end

  def self.down
    remove_column :courses, :api_unit_label, :string
    change_column :courses, :hours_label, :string
  end
end
