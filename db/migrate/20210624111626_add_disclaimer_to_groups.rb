class AddDisclaimerToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :disclaimer, :text
  end
end
