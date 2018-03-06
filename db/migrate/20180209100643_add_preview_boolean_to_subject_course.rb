class AddPreviewBooleanToSubjectCourse < ActiveRecord::Migration
  def change
    add_column :subject_courses, :preview, :boolean, default: false, index: true
  end
end
