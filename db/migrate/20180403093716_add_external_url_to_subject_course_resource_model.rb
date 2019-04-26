class AddExternalUrlToSubjectCourseResourceModel < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_course_resources, :external_url, :string
  end
end
