class AddImageToUsers < ActiveRecord::Migration[4.2]
  def up
    add_attachment :users, :profile_image
  end

  def down
    remove_attachment :users, :profile_image
    end
end
