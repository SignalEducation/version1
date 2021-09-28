class AddOnboardingCourseRelationshipToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :onboarding_course, foreign_key: { to_table: :courses }
  end
end
