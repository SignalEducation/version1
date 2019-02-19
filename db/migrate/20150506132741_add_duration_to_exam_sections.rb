class AddDurationToExamSections < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_sections, :duration, :integer
  end
end
