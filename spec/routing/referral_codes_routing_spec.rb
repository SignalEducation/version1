require 'rails_helper'

RSpec.describe ReferralCodesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/referral_codes').to route_to('referral_codes#index')
    end

    it 'routes to #show' do
      expect(get: '/referral_codes/1').to route_to('referral_codes#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/referral_codes').to route_to('referral_codes#create')
    end

    it 'routes to #destroy' do
      expect(delete: '/referral_codes/1').to route_to('referral_codes#destroy', id: '1')
    end

  end
end
