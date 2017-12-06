# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe RefundsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/refunds').to route_to('refunds#index')
    end

    it 'routes to #new' do
      expect(get: '/refunds/new').to route_to('refunds#new')
    end

    it 'routes to #show' do
      expect(get: '/refunds/1').to route_to('refunds#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/refunds/1/edit').to route_to('refunds#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/refunds').to route_to('refunds#create')
    end

    it 'routes to #update' do
      expect(put: '/refunds/1').to route_to('refunds#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/refunds/1').to route_to('refunds#destroy', id: '1')
    end

  end
end
