class AddImageToGroups < ActiveRecord::Migration
  def up
    add_attachment :groups, :image
  end

  def down
    remove_attachment :groups, :image
  end
end
