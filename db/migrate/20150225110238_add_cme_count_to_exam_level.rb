class AddCmeCountToExamLevel < ActiveRecord::Migration
  def change
    add_column :exam_levels, :cme_count, :integer, index: true, default: 0
  end
end
