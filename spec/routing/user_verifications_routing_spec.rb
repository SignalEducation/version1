require 'rails_helper'

RSpec.describe UserVerificationsController, type: :routing do
  describe 'routing' do

    it 'should route to #update' do
      expect(get: '/user_verification/abc123').to route_to('user_verifications#update', email_verification_code: 'abc123')
    end

  end
end
