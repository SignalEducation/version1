class CreateUserLikes < ActiveRecord::Migration
  def change
    create_table :user_likes do |t|
      t.integer :user_id, index: true
      t.string :likeable_type
      t.integer :likeable_id, index: true

      t.timestamps
    end
  end
end
