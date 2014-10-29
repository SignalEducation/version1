class CreateUserGroups < ActiveRecord::Migration
  def up
    create_table :user_groups do |t|
      t.string :name
      t.text :description
      t.boolean :individual_student, default: false, null: false
      t.boolean :corporate_student, default: false, null: false
      t.boolean :tutor, default: false, null: false
      t.boolean :content_manager, default: false, null: false
      t.boolean :blogger, default: false, null: false
      t.boolean :corporate_customer, default: false, null: false
      t.boolean :site_admin, default: false, null: false
      t.boolean :forum_manager, default: false, null: false
      t.boolean :subscription_required_at_sign_up, default: false, null: false
      t.boolean :subscription_required_to_see_content, default: false, null: false

      t.timestamps
    end
  end

  def down
    drop_table :user_groups
  end
end
