class AddUserReferenceToPaymentIntent < ActiveRecord::Migration[5.2]
  def change
    add_reference :payment_intents, :user, foreign_key: true
  end
end
