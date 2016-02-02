# == Schema Information
#
# Table name: marketing_categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe MarketingCategoriesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/marketing_categories').to route_to('marketing_categories#index')
    end

    it 'routes to #new' do
      expect(get: '/marketing_categories/new').to route_to('marketing_categories#new')
    end

    it 'routes to #show' do
      expect(get: '/marketing_categories/1').to route_to('marketing_categories#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/marketing_categories/1/edit').to route_to('marketing_categories#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/marketing_categories').to route_to('marketing_categories#create')
    end

    it 'routes to #update' do
      expect(put: '/marketing_categories/1').to route_to('marketing_categories#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/marketing_categories/1').to route_to('marketing_categories#destroy', id: '1')
    end

  end
end
