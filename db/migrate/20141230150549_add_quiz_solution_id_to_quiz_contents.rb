class AddQuizSolutionIdToQuizContents < ActiveRecord::Migration
  def change
    add_column :quiz_contents, :quiz_solution_id, :integer, index: true
  end
end
