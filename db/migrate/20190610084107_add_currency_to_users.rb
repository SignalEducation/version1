class AddCurrencyToUsers < ActiveRecord::Migration[5.2]
  def up
    add_reference :users, :currency, foreign_key: true
  end

  def down
    remove_reference :users, :currency, index: true
  end
end
