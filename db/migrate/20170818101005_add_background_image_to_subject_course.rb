class AddBackgroundImageToSubjectCourse < ActiveRecord::Migration
  def up
    add_attachment :subject_courses, :background_image
  end

  def down
    remove_attachment :subject_courses, :background_image
  end
end
