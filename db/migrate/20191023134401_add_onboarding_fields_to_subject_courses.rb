class AddOnboardingFieldsToSubjectCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :subject_courses, :on_welcome_page, :boolean, default: false
    add_column :subject_courses, :unit_label, :string
  end
end
