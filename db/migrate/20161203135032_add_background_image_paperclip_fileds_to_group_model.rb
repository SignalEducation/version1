class AddBackgroundImagePaperclipFiledsToGroupModel < ActiveRecord::Migration
  def up
    add_attachment :groups, :background_image
  end

  def down
    remove_attachment :groups, :background_image
    end
end
