class CreateSubscriptionPlanCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :subscription_plan_categories do |t|
      t.string :name, index: true
      t.datetime :available_from, index: true
      t.datetime :available_to, index: true
      t.string :guid, index: true

      t.timestamps
    end
  end
end
