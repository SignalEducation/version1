class AddGuidToUsers < ActiveRecord::Migration
  def up
    add_column :users, :guid, :string
    User.all.each do |u|
      u.guid = ApplicationController.generate_random_code(10)
      u.save!
    end
  end

  def down
    remove_column :users, :guid
  end
end
