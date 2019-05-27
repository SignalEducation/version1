class AddGuidToSubscriptionPlans < ActiveRecord::Migration[5.2]

  class SubscriptionPlan < ActiveRecord::Base
  end

  def up
    add_column :subscription_plans, :guid, :string

    SubscriptionPlan.find_each do |plan|
      plan.guid = ApplicationController.generate_random_code(10)
      plan.save
    end

  end

  def down
    remove_column :subscription_plans, :guid, :string
  end

end
