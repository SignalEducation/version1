class CreateJwtBlockedTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :jwt_blocked_tokens do |t|
      t.string  :token, null: false

      t.timestamps
    end
  end
end
