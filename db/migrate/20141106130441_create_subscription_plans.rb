class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.boolean :available_to_students, default: false, null: false, index: true
      t.boolean :available_to_corporates, default: false, null: false, index: true
      t.boolean :all_you_can_eat, default: true, null: false
      t.integer :payment_frequency_in_months, default: 1, index: true
      t.integer :currency_id, index: true
      t.decimal :price
      t.date :available_from, index: true
      t.date :available_to, index: true
      t.string :stripe_guid
      t.integer :trial_period_in_days, default: 0

      t.timestamps
    end
  end
end
