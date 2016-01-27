# == Schema Information
#
# Table name: currencies
#
#  id              :integer          not null, primary key
#  iso_code        :string
#  name            :string
#  leading_symbol  :string
#  trailing_symbol :string
#  active          :boolean          default(FALSE), not null
#  sorting_order   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe CurrenciesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/currencies').to route_to('currencies#index')
    end

    it 'routes to #new' do
      expect(get: '/currencies/new').to route_to('currencies#new')
    end

    it 'routes to #show' do
      expect(get: '/currencies/1').to route_to('currencies#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/currencies/1/edit').to route_to('currencies#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/currencies').to route_to('currencies#create')
    end

    it 'routes to #update' do
      expect(put: '/currencies/1').to route_to('currencies#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/currencies/reorder').to route_to('currencies#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/currencies/1').to route_to('currencies#destroy', id: '1')
    end

  end
end
