class AddDurationToExamSections < ActiveRecord::Migration
  def change
    add_column :exam_sections, :duration, :integer
  end
end
