class AddCmeCountToExamSection < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_sections, :cme_count, :integer, index: true, default: 0
  end
end
