# frozen_string_literal: true

module Api
  module V1
    class PricesController < Api::V1::ApiController
      helper ApplicationHelper

      def index
        @exam_bodies = ExamBody.all_active.all_in_order
        @group       = Group.find_by(name_url: params[:group])
        @currency    = user_currency(params[:iso_code])

        if @group
          @exam_bodies = @group.exam_body
          @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id).
                                  includes(:currency).in_currency(@currency.id).all_active.all_in_display_order
          @products = Product.for_group(@group.id).includes(:currency).in_currency(@currency.id).all_active
        else
          @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).
                                  includes(:currency).in_currency(@currency.id).all_active.all_in_display_order
          @products = Product.includes(:currency).in_currency(@currency.id).all_active
        end

        render 'api/v1/prices/index.json'
      end

      private

      def user_currency(iso_code)
        currency = Currency.find_by(iso_code: iso_code.upcase) if iso_code.present?
        return currency if currency.present?

        country = IpAddress.get_country(request.remote_ip) || Country.find_by(name: 'United Kingdom')

        if @current_user
          @current_user.get_currency(country)
        else
          country.currency
        end
      end
    end
  end
end
