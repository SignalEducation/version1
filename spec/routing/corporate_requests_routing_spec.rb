# == Schema Information
#
# Table name: corporate_requests
#
#  id               :integer          not null, primary key
#  name             :string
#  title            :string
#  company          :string
#  email            :string
#  phone_number     :string
#  website          :string
#  personal_message :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe CorporateRequestsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/corporate_requests').to route_to('corporate_requests#index')
    end

    it 'routes to #new' do
      expect(get: '/corporate_requests/new').to route_to('corporate_requests#new')
    end

    it 'routes to #show' do
      expect(get: '/corporate_requests/1').to route_to('corporate_requests#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/corporate_requests/1/edit').to route_to('corporate_requests#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/corporate_requests').to route_to('corporate_requests#create')
    end

    it 'routes to #update' do
      expect(put: '/corporate_requests/1').to route_to('corporate_requests#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/corporate_requests/1').to route_to('corporate_requests#destroy', id: '1')
    end

  end
end
