class CreateCbeScenarios < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_scenarios do |t|
      t.string :content

      t.timestamps
    end

    add_reference :cbe_scenarios, :cbe_section, index: true
  end
end
