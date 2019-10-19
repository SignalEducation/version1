class AddShortDescriptionToSubjectCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :subject_courses, :short_description, :text
  end
end
