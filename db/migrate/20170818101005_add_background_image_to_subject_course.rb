class AddBackgroundImageToSubjectCourse < ActiveRecord::Migration[4.2]
  def up
    add_attachment :subject_courses, :background_image
  end

  def down
    remove_attachment :subject_courses, :background_image
  end
end
