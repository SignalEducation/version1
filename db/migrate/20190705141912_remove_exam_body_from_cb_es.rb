class RemoveExamBodyFromCbEs < ActiveRecord::Migration[5.2]
  def change
    remove_column :cbes, :exam_body_id
  end
end
