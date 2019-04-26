class AddMockExamIdToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :mock_exam_id, :integer, index: true
  end
end
