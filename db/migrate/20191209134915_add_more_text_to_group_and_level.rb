class AddMoreTextToGroupAndLevel < ActiveRecord::Migration[5.2]
  def change
    rename_column :groups, :onboarding_message, :onboarding_level_subheading
    rename_column :levels, :onboarding_message, :onboarding_course_subheading

    add_column :groups, :onboarding_level_heading, :string
    add_column :levels, :onboarding_course_heading, :string
  end
end
