require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/users').to route_to('users#index')
    end

    it 'routes to #new' do
      expect(get: '/users/new').to route_to('users#new')
    end

    it 'routes to #show' do
      expect(get: '/users/1').to route_to('users#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/users/1/edit').to route_to('users#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/users').to route_to('users#create')
    end

    it 'routes to #update' do
      expect(put: '/users/1').to route_to('users#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/users/1').to route_to('users#destroy', id: '1')
    end

    # special routes

    it 'routes /profile to #show' do
      expect(get: '/profile').to route_to('users#show')
    end

    xit 'routes /sign_up to #new' do
      expect(get: '/sign_up').to route_to('student_sign_ups#new')
    end

    it 'routes /change_password to #change_password' do
      expect(post: '/change_password').to route_to('users#change_password')
    end

    it 'routes /new_paid_subscription to #new_paid_subscription' do
      expect(get: '/users/1/new_paid_subscription').to route_to('users#new_paid_subscription', user_id: '1')
    end

    it 'routes /upgrade_from_free_trial to #upgrade_from_free_trial' do
      expect(patch: '/users/1/upgrade_from_free_trial').to route_to('users#upgrade_from_free_trial', user_id: '1')
    end
  end
end
