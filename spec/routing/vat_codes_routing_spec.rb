require 'rails_helper'

RSpec.describe VatCodesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/vat_codes').to route_to('vat_codes#index')
    end

    it 'routes to #new' do
      expect(get: '/vat_codes/new').to route_to('vat_codes#new')
    end

    it 'routes to #show' do
      expect(get: '/vat_codes/1').to route_to('vat_codes#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/vat_codes/1/edit').to route_to('vat_codes#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/vat_codes').to route_to('vat_codes#create')
    end

    it 'routes to #update' do
      expect(put: '/vat_codes/1').to route_to('vat_codes#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/vat_codes/1').to route_to('vat_codes#destroy', id: '1')
    end

  end
end
