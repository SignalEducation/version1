require 'rails_helper'

RSpec.describe WhitePapersController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/white_papers').to route_to('white_papers#index')
    end

    it 'routes to #new' do
      expect(get: '/white_papers/new').to route_to('white_papers#new')
    end

    it 'routes to #show' do
      expect(get: '/white_papers/1').to route_to('white_papers#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/white_papers/1/edit').to route_to('white_papers#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/white_papers').to route_to('white_papers#create')
    end

    it 'routes to #update' do
      expect(put: '/white_papers/1').to route_to('white_papers#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/white_papers/1').to route_to('white_papers#destroy', id: '1')
    end

  end
end
