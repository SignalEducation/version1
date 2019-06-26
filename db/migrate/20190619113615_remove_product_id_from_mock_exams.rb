class RemoveProductIdFromMockExams < ActiveRecord::Migration[5.2]
  def change
    remove_column :mock_exams, :product_id
  end
end
