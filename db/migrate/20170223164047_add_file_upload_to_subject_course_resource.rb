class AddFileUploadToSubjectCourseResource < ActiveRecord::Migration[4.2]
  def up
    add_attachment :subject_course_resources, :file_upload
  end

  def down
    remove_attachment :subject_course_resources, :file_upload
  end
end
