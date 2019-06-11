class CreateCorporateGroupsUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :corporate_groups_users, id: false do |t|
      t.references :user, index: true
      t.references :corporate_group, index: true
    end
  end
end
