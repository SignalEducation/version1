class CreateForumPostConcerns < ActiveRecord::Migration[4.2]
  def change
    create_table :forum_post_concerns do |t|
      t.integer :forum_post_id, index: true
      t.integer :user_id, index: true
      t.string :reason
      t.boolean :live, default: true, null: false

      t.timestamps
    end
  end
end
