class RemoveExternalUrlFieldsFromSubjectCourse < ActiveRecord::Migration
  def change
    remove_column :subject_courses, :external_url, :string
  end
end
