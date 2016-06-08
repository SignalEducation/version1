# == Schema Information
#
# Table name: white_paper_requests
#
#  id             :integer          not null, primary key
#  name           :string
#  email          :string
#  number         :string
#  company_name   :string
#  white_paper_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe WhitePaperRequestsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/white_paper_requests').to route_to('white_paper_requests#index')
    end

    it 'routes to #new' do
      expect(get: '/white_paper_requests/new').to route_to('white_paper_requests#new')
    end

    it 'routes to #show' do
      expect(get: '/white_paper_requests/1').to route_to('white_paper_requests#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/white_paper_requests/1/edit').to route_to('white_paper_requests#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/white_paper_requests').to route_to('white_paper_requests#create')
    end

    it 'routes to #update' do
      expect(put: '/white_paper_requests/1').to route_to('white_paper_requests#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/white_paper_requests/1').to route_to('white_paper_requests#destroy', id: '1')
    end

  end
end
