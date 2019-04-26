class AddCoverImagePaperclipToMockExam < ActiveRecord::Migration[4.2]
  def up
    add_attachment :mock_exams, :cover_image
  end

  def down
    remove_attachment :mock_exams, :cover_image
  end
end
