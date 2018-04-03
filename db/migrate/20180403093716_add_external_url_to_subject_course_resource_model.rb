class AddExternalUrlToSubjectCourseResourceModel < ActiveRecord::Migration
  def change
    add_column :subject_course_resources, :external_url, :string
  end
end
