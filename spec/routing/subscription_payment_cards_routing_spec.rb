# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string
#  status              :string
#  brand               :string
#  last_4              :string
#  expiry_month        :integer
#  expiry_year         :integer
#  address_line1       :string
#  account_country     :string
#  account_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string
#  funding             :string
#  cardholder_name     :string
#  fingerprint         :string
#  cvc_checked         :string
#  address_line1_check :string
#  address_zip_check   :string
#  dynamic_last4       :string
#  customer_guid       :string
#  is_default_card     :boolean          default(FALSE)
#  address_line2       :string
#  address_city        :string
#  address_state       :string
#  address_zip         :string
#  address_country     :string
#

require 'rails_helper'

RSpec.describe SubscriptionPaymentCardsController, type: :routing do
  describe 'routing' do

    it 'routes to #create' do
      expect(post: '/subscription_payment_cards').to route_to('subscription_payment_cards#create')
    end

    it 'routes to #update' do
      expect(put: '/subscription_payment_cards/1').to route_to('subscription_payment_cards#update', id: '1')
    end

  end
end
