class CreateUsersSubjectCourses < ActiveRecord::Migration
  def change
    create_table :subject_courses_users, id: false do |t|
      t.references :subject_course, null: false, index: true
      t.references :user, null: false, index: true
    end
  end
end
