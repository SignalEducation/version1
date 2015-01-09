require 'rails_helper'

RSpec.describe UserActivityLogsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/user_activity_logs').to route_to('user_activity_logs#index')
    end

    it 'routes to #new' do
      expect(get: '/user_activity_logs/new').to route_to('user_activity_logs#new')
    end

    it 'routes to #show' do
      expect(get: '/user_activity_logs/1').to route_to('user_activity_logs#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/user_activity_logs/1/edit').to route_to('user_activity_logs#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_activity_logs').to route_to('user_activity_logs#create')
    end

    it 'routes to #update' do
      expect(put: '/user_activity_logs/1').to route_to('user_activity_logs#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/user_activity_logs/1').to route_to('user_activity_logs#destroy', id: '1')
    end

  end
end
