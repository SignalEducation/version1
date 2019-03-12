class AddOrganisationToSubscriptionPlan < ActiveRecord::Migration[5.2]
  def change
    add_reference :subscription_plans, :organisation, foreign_key: true
  end
end
