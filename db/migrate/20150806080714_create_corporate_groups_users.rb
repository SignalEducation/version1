class CreateCorporateGroupsUsers < ActiveRecord::Migration
  def change
    create_table :corporate_groups_users, id: false do |t|
      t.references :user, index: true
      t.references :corporate_group, index: true
    end
  end
end
