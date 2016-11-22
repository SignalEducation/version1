class AddDiscourseUserBooleanToUserModel < ActiveRecord::Migration
  def change
    add_column :users, :discourse_user, :boolean, default: :false
  end
end
