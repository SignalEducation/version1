class CreateGroupsSubjectCourses < ActiveRecord::Migration
  def change
    create_table :groups_subject_courses, id: false do |t|
      t.references :group, null: false, index: true
      t.references :subject_course,  null: false, index: true
    end
  end
end
