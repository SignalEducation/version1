class AddFreeTrialLimitToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :trial_limit_in_seconds, :integer, index: true, default: 0
  end
end
