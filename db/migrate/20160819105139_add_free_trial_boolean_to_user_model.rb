class AddFreeTrialBooleanToUserModel < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :free_trial, :boolean, index: true, default: false
    add_column :users, :trial_limit_in_days, :integer, index: true, default: 0
  end
end
