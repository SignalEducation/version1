class AddPreviewBooleanToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :preview, :boolean, default: false, index: true
  end
end
