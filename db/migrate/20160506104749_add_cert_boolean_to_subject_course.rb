class AddCertBooleanToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :certificate, :boolean, default: false, null: false, index: true
  end
end
