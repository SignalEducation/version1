class AddAttachmentCoverImageToWhitePapers < ActiveRecord::Migration
  def self.up
    change_table :white_papers do |t|
      t.attachment :cover_image
    end
  end

  def self.down
    remove_attachment :white_papers, :cover_image
  end
end
