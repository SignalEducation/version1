class UpdateStateForExistingSubscriptions < ActiveRecord::Migration
  def change
    Subscription.find_each do |sub|
      case sub.stripe_status
      when 'active', 'canceled-pending'
        sub.update_columns(state: 'active')
      when 'past_due'
        sub.update_columns(state: 'errored')
      when 'canceled'
        sub.update_columns(state: 'cancelled')
      else
        sub.update_columns(state: 'pending')
      end
    end
  end
end
