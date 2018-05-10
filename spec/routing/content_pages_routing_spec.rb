# == Schema Information
#
# Table name: content_pages
#
#  id              :integer          not null, primary key
#  name            :string
#  public_url      :string
#  seo_title       :string
#  seo_description :text
#  text_content    :text
#  h1_text         :string
#  h1_subtext      :string
#  nav_type        :string
#  footer_link     :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe ContentPagesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/content_pages').to route_to('content_pages#index')
    end

    it 'routes to #new' do
      expect(get: '/content_pages/new').to route_to('content_pages#new')
    end

    it 'routes to #show' do
      expect(get: '/content_pages/1').to route_to('content_pages#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/content_pages/1/edit').to route_to('content_pages#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/content_pages').to route_to('content_pages#create')
    end

    it 'routes to #update' do
      expect(put: '/content_pages/1').to route_to('content_pages#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/content_pages/1').to route_to('content_pages#destroy', id: '1')
    end

  end
end
