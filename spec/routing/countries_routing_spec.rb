# == Schema Information
#
# Table name: countries
#
#  id            :integer          not null, primary key
#  name          :string
#  iso_code      :string
#  country_tld   :string
#  sorting_order :integer
#  in_the_eu     :boolean          default(FALSE), not null
#  currency_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  continent     :string
#

require 'rails_helper'

RSpec.describe CountriesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/countries').to route_to('countries#index')
    end

    it 'routes to #new' do
      expect(get: '/countries/new').to route_to('countries#new')
    end

    it 'routes to #show' do
      expect(get: '/countries/1').to route_to('countries#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/countries/1/edit').to route_to('countries#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/countries').to route_to('countries#create')
    end

    it 'routes to #update' do
      expect(put: '/countries/1').to route_to('countries#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/countries/reorder').to route_to('countries#reorder')
    end

    it 'routes to #destroy' do
      expect(delete: '/countries/1').to route_to('countries#destroy', id: '1')
    end

  end
end
