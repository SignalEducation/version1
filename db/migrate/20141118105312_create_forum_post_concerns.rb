class CreateForumPostConcerns < ActiveRecord::Migration
  def change
    create_table :forum_post_concerns do |t|
      t.integer :forum_post_id
      t.integer :user_id
      t.string :reason
      t.boolean :live

      t.timestamps
    end
  end
end
