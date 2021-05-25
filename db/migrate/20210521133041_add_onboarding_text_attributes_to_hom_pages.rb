class AddOnboardingTextAttributesToHomPages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :onboarding_welcome_heading, :string
    add_column :home_pages, :onboarding_welcome_subheading, :text
    add_column :home_pages, :onboarding_level_heading, :string
    add_column :home_pages, :onboarding_level_subheading, :text
  end
end
