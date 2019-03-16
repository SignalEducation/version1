class RemoveExternalUrlFieldsFromSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    remove_column :subject_courses, :external_url, :string
  end
end
