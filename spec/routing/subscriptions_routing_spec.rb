# == Schema Information
#
# Table name: subscriptions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  subscription_plan_id :integer
#  stripe_guid          :string
#  next_renewal_date    :date
#  complimentary        :boolean          default(FALSE), not null
#  current_status       :string
#  created_at           :datetime
#  updated_at           :datetime
#  stripe_customer_id   :string
#  stripe_customer_data :text
#  livemode             :boolean          default(FALSE)
#  active               :boolean          default(FALSE)
#  terms_and_conditions :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe SubscriptionsController, type: :routing do
  describe 'routing' do

    it 'routes to #update' do
      expect(put: '/subscriptions/1').to route_to('subscriptions#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/subscriptions/1').to route_to('subscriptions#destroy', id: '1')
    end

  end
end
