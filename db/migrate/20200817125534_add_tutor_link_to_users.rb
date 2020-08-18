class AddTutorLinkToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tutor_link, :string
  end
end
