class AddCmeCountToExamSection < ActiveRecord::Migration
  def change
    add_column :exam_sections, :cme_count, :integer, index: true, default: 0
  end
end
