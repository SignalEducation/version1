# == Schema Information
#
# Table name: subscription_plan_categories
#
#  id                   :integer          not null, primary key
#  name                 :string
#  available_from       :datetime
#  available_to         :datetime
#  guid                 :string
#  created_at           :datetime
#  updated_at           :datetime
#  trial_period_in_days :integer
#

require 'rails_helper'

RSpec.describe SubscriptionPlanCategoriesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/subscription_plan_categories').to route_to('subscription_plan_categories#index')
    end

    it 'routes to #new' do
      expect(get: '/subscription_plan_categories/new').to route_to('subscription_plan_categories#new')
    end

    it 'routes to #show' do
      expect(get: '/subscription_plan_categories/1').to route_to('subscription_plan_categories#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/subscription_plan_categories/1/edit').to route_to('subscription_plan_categories#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/subscription_plan_categories').to route_to('subscription_plan_categories#create')
    end

    it 'routes to #update' do
      expect(put: '/subscription_plan_categories/1').to route_to('subscription_plan_categories#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/subscription_plan_categories/1').to route_to('subscription_plan_categories#destroy', id: '1')
    end

  end
end
