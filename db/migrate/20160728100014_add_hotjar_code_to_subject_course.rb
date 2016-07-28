class AddHotjarCodeToSubjectCourse < ActiveRecord::Migration
  def change
    add_column :subject_courses, :hotjar_guid, :string
  end
end
