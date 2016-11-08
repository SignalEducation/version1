class AddCoverImagePaperclipToMockExam < ActiveRecord::Migration
  def up
    add_attachment :mock_exams, :cover_image
  end

  def down
    remove_attachment :mock_exams, :cover_image
  end
end
