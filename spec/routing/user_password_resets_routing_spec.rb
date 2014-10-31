require 'rails_helper'

RSpec.describe UserPasswordResetsController, type: :routing do
  describe 'routing' do

    it 'routes to #new' do
      expect(get: '/user_password_resets/new').to route_to('user_password_resets#new')
    end

    it 'routes to #edit' do
      expect(get: '/user_password_resets/1/edit').to route_to('user_password_resets#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_password_resets').to route_to('user_password_resets#create')
    end

    it 'routes to #update' do
      expect(put: '/user_password_resets/1').to route_to('user_password_resets#update', id: '1')
    end

    # special routes
    it 'routes /forgot_password to #new' do
      expect(get: '/forgot_password').to route_to('user_password_resets#new')
    end

    it 'routes /reset_password to #edit' do
      expect(get: '/reset_password/1').to route_to('user_password_resets#edit', id: '1')
    end

  end
end
