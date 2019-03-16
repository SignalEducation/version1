class AddFreeTrialLimitToUserModel < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :trial_limit_in_seconds, :integer, index: true, default: 0
  end
end
