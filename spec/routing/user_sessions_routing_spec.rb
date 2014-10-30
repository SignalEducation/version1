require 'rails_helper'

RSpec.describe UserSessionsController, type: :routing do
  describe 'routing' do

    it 'routes /sign_in to #new' do
      expect(get: '/sign_in').to route_to('user_sessions#new')
    end

    it 'routes to #create' do
      expect(post: '/user_sessions').to route_to('user_sessions#create')
    end

    it 'routes /sign_out to #destroy' do
      expect(get: '/sign_out').to route_to('user_sessions#destroy')
    end

  end
end
