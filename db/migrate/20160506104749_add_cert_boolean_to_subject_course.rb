class AddCertBooleanToSubjectCourse < ActiveRecord::Migration
  def change
    add_column :subject_courses, :certificate, :boolean, default: false, null: false, index: true
  end
end
