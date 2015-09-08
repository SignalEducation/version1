require 'rails_helper'

RSpec.describe CorporateStudentsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/corporate_students').to route_to('corporate_students#index')
    end

    it 'routes to #new' do
      expect(get: '/corporate_students/new').to route_to('corporate_students#new')
    end

    it 'routes to #edit' do
      expect(get: '/corporate_students/1/edit').to route_to('corporate_students#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/corporate_students').to route_to('corporate_students#create')
    end

    it 'routes to #update' do
      expect(put: '/corporate_students/1').to route_to('corporate_students#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/corporate_students/1').to route_to('corporate_students#destroy', id: '1')
    end

  end
end
