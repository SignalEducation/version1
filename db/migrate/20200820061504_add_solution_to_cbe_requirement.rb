class AddSolutionToCbeRequirement < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_requirements, :solution, :text
  end
end
