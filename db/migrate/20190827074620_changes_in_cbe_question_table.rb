class ChangesInCbeQuestionTable < ActiveRecord::Migration[5.2]
  def change
    add_column    :cbe_questions, :sorting_order, :integer
    remove_column :cbe_questions, :label, :string
    rename_column :cbe_questions, :description, :content
    add_reference :cbe_questions, :cbe_scenario, index: true
  end
end
