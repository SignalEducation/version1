class AddNameToCbeScenarios < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_scenarios, :name, :string
  end
end
