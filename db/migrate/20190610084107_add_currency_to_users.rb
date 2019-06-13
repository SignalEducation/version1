class AddCurrencyToUsers < ActiveRecord::Migration[5.2]
  def up
    add_reference :users, :currency, foreign_key: true

    User.find_each do |user|
      next if user.currency.present?
      currency = get_currency(user)
      unless currency && user.update(currency: currency)
        say "#{user.id} was not updated", subitem: true
      end
    end
  end

  def down
    remove_reference :users, :currency, index: true
  end

  def get_currency(user)
    if existing_sub = user.subscriptions.all_stripe.first
      existing_sub.subscription_plan&.currency || user.country.currency
    elsif existing_order = user.orders.all_stripe.first
      existing_order.product&.currency || user.country.currency
    else
      user.country&.currency
    end
  end
end
