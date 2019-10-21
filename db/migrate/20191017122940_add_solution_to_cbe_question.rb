class AddSolutionToCbeQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_questions, :solution, :text
  end
end
