class AddMessageOnboardingRelationship < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :onboarding_process_id, :integer
  end
end
