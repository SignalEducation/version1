class AddMockExamIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :mock_exam_id, :integer, index: true
  end
end
