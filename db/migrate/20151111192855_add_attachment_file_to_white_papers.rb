class AddAttachmentFileToWhitePapers < ActiveRecord::Migration
  def self.up
    change_table :white_papers do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :white_papers, :file
  end
end
