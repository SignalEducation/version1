class AddNewOnboardingBooleanToExamBody < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :new_onboarding, :boolean, default: false, null: false
  end
end
