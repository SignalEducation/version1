class AddUrlFieldToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :external_url, :string
    add_column :subject_courses, :external_url_name, :string
  end
end
