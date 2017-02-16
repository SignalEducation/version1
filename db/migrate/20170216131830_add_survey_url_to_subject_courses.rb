class AddSurveyUrlToSubjectCourses < ActiveRecord::Migration
  def change
    add_column :subject_courses, :survey_url, :string
  end
end
