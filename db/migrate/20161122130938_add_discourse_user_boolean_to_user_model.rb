class AddDiscourseUserBooleanToUserModel < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :discourse_user, :boolean, default: :false
  end
end
