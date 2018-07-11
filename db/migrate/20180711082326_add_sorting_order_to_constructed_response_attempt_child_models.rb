class AddSortingOrderToConstructedResponseAttemptChildModels < ActiveRecord::Migration
  def change
    add_column :scenario_question_attempts, :sorting_order, :integer
    add_column :scenario_answer_attempts, :sorting_order, :integer
  end
end
