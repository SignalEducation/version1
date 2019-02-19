class AddSortingOrderToQuizQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_questions, :sorting_order, :integer, index: true
  end
end
