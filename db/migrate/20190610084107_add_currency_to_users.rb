class AddCurrencyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :currency, foreign_key: true
  end
end
