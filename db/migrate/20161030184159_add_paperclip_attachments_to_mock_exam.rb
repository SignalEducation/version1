class AddPaperclipAttachmentsToMockExam < ActiveRecord::Migration
  def up
    add_attachment :mock_exams, :file
  end

  def down
    remove_attachment :mock_exams, :file
  end
end
