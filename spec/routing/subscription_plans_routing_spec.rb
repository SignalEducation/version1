# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  available_to_students         :boolean          default(FALSE), not null
#  available_to_corporates       :boolean          default(FALSE), not null
#  all_you_can_eat               :boolean          default(TRUE), not null
#  payment_frequency_in_months   :integer          default(1)
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string
#  trial_period_in_days          :integer          default(0)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe SubscriptionPlansController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/subscription_plans').to route_to('subscription_plans#index')
    end

    it 'routes to #new' do
      expect(get: '/subscription_plans/new').to route_to('subscription_plans#new')
    end

    it 'routes to #show' do
      expect(get: '/subscription_plans/1').to route_to('subscription_plans#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/subscription_plans/1/edit').to route_to('subscription_plans#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/subscription_plans').to route_to('subscription_plans#create')
    end

    it 'routes to #update' do
      expect(put: '/subscription_plans/1').to route_to('subscription_plans#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/subscription_plans/1').to route_to('subscription_plans#destroy', id: '1')
    end

  end
end
