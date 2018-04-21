# == Schema Information
#
# Table name: external_banners
#
#  id                :integer          not null, primary key
#  name              :string
#  sorting_order     :integer
#  active            :boolean          default(FALSE)
#  background_colour :string
#  text_content      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe ExternalBannersController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/external_banners').to route_to('external_banners#index')
    end

    it 'routes to #new' do
      expect(get: '/external_banners/new').to route_to('external_banners#new')
    end

    it 'routes to #show' do
      expect(get: '/external_banners/1').to route_to('external_banners#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/external_banners/1/edit').to route_to('external_banners#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/external_banners').to route_to('external_banners#create')
    end

    it 'routes to #update' do
      expect(put: '/external_banners/1').to route_to('external_banners#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/external_banners/reorder').to route_to('external_banners#reorder')
    end
    # todo move this to routes.rb ABOVE the resource:
    # post 'external_banners/reorder', to: 'external_banners#reorder'

    it 'routes to #destroy' do
      expect(delete: '/external_banners/1').to route_to('external_banners#destroy', id: '1')
    end

  end
end
