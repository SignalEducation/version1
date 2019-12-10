class AddOnboardingTextFieldsToGroupsAndLevels < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :onboarding_message, :text
    add_column :levels, :onboarding_message, :text
  end
end
