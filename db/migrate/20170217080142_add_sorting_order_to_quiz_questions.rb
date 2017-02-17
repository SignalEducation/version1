class AddSortingOrderToQuizQuestions < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :sorting_order, :integer, index: true
  end
end
