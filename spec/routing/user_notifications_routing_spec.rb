require 'rails_helper'

RSpec.describe UserNotificationsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/user_notifications').to route_to('user_notifications#index')
    end

    it 'routes to #new' do
      expect(get: '/user_notifications/new').to route_to('user_notifications#new')
    end

    it 'routes to #show' do
      expect(get: '/user_notifications/1').to route_to('user_notifications#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/user_notifications/1/edit').to route_to('user_notifications#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_notifications').to route_to('user_notifications#create')
    end

    it 'routes to #update' do
      expect(put: '/user_notifications/1').to route_to('user_notifications#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/user_notifications/1').to route_to('user_notifications#destroy', id: '1')
    end

  end
end
