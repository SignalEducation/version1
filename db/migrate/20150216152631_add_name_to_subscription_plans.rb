class AddNameToSubscriptionPlans < ActiveRecord::Migration
  def up
    add_column :subscription_plans, :name, :string, index: true
    SubscriptionPlan.all.each do |sp|
      sp.update_attributes!(name:  "LearnSignal - every #{sp.payment_frequency_in_months} months #{sp.currency.try(:iso_code)}")
    end
  end

  def down
    remove_column :subscription_plans, :name
  end
end
