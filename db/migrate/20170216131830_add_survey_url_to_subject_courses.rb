class AddSurveyUrlToSubjectCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :survey_url, :string
  end
end
