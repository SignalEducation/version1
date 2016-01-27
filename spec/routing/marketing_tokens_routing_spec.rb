# == Schema Information
#
# Table name: marketing_tokens
#
#  id                    :integer          not null, primary key
#  code                  :string
#  marketing_category_id :integer
#  is_hard               :boolean          default(FALSE), not null
#  is_direct             :boolean          default(FALSE), not null
#  is_seo                :boolean          default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#

require 'rails_helper'

RSpec.describe MarketingTokensController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/marketing_tokens').to route_to('marketing_tokens#index')
    end

    it 'routes to #new' do
      expect(get: '/marketing_tokens/new').to route_to('marketing_tokens#new')
    end

    it 'routes to #show' do
      expect(get: '/marketing_tokens/1').to route_to('marketing_tokens#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/marketing_tokens/1/edit').to route_to('marketing_tokens#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/marketing_tokens').to route_to('marketing_tokens#create')
    end

    it 'routes to #destroy' do
      expect(delete: '/marketing_tokens/1').to route_to('marketing_tokens#destroy', id: '1')
    end

    it 'routes to #preview_csv' do
      expect(post: '/marketing_tokens/preview_csv').to route_to('marketing_tokens#preview_csv')
    end

    it 'routes to #import_csv' do
      expect(post: '/marketing_tokens/import_csv').to route_to('marketing_tokens#import_csv')
    end

    it 'routes to #download_csv' do
      expect(get: '/marketing_tokens/download_csv').to route_to('marketing_tokens#download_csv')
    end
  end
end
