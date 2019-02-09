class AddPaperclipAttachmentsToMockExam < ActiveRecord::Migration[4.2]
  def up
    add_attachment :mock_exams, :file
  end

  def down
    remove_attachment :mock_exams, :file
  end
end
