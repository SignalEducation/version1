# frozen_string_literal: true

module Api
  module V1
    class SubscriptionPlansController < Api::V1::ApiController
      def index
        @subscription_plans = SubscriptionPlan.all

        render 'api/v1/subscription_plans/index.json'
      end
    end
  end
end
