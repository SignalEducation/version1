class AddHotjarCodeToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :hotjar_guid, :string
  end
end
