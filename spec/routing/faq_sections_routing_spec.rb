# == Schema Information
#
# Table name: faq_sections
#
#  id            :integer          not null, primary key
#  name          :string
#  name_url      :string
#  description   :text
#  active        :boolean          default(TRUE)
#  sorting_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe FaqSectionsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/faq_sections').to route_to('faq_sections#index')
    end

    it 'routes to #new' do
      expect(get: '/faq_sections/new').to route_to('faq_sections#new')
    end

    it 'routes to #show' do
      expect(get: '/faq_sections/1').to route_to('faq_sections#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/faq_sections/1/edit').to route_to('faq_sections#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/faq_sections').to route_to('faq_sections#create')
    end

    it 'routes to #update' do
      expect(put: '/faq_sections/1').to route_to('faq_sections#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/faq_sections/reorder').to route_to('faq_sections#reorder')
    end
    # todo move this to routes.rb ABOVE the resource:
    # post 'faq_sections/reorder', to: 'faq_sections#reorder'

    it 'routes to #destroy' do
      expect(delete: '/faq_sections/1').to route_to('faq_sections#destroy', id: '1')
    end

  end
end
