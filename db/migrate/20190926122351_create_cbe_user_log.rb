class CreateCbeUserLog < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_user_logs do |t|
      t.integer :status
      t.float :score

      t.timestamps
    end

    add_reference :cbe_user_logs, :cbe, index: true
    add_reference :cbe_user_logs, :user, index: true
  end
end
