class AddTutorTitleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tutor_title, :string
  end
end
