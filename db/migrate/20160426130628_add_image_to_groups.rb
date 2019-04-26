class AddImageToGroups < ActiveRecord::Migration[4.2]
  def up
    add_attachment :groups, :image
  end

  def down
    remove_attachment :groups, :image
  end
end
