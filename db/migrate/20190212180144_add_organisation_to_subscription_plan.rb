class AddOrganisationToSubscriptionPlan < ActiveRecord::Migration[5.2]
  def change
    create_table :organisations do |t|
      t.string :name

      t.timestamps
    end
    add_reference :subscription_plans, :organisation, foreign_key: true
  end
end
