require 'rails_helper'

RSpec.describe UserActivationsController, type: :routing do
  describe 'routing' do

    it 'should route to #update' do
      expect(get: '/user_activate/abc123').to route_to('user_activations#update', activation_code: 'abc123')
    end

  end
end
