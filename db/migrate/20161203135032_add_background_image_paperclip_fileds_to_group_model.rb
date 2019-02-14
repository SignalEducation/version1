class AddBackgroundImagePaperclipFiledsToGroupModel < ActiveRecord::Migration[4.2]
  def up
    add_attachment :groups, :background_image
  end

  def down
    remove_attachment :groups, :background_image
    end
end
