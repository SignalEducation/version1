class AddUrlFieldToSubjectCourse < ActiveRecord::Migration
  def change
    add_column :subject_courses, :external_url, :string
  end
end
