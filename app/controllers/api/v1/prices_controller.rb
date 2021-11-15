# frozen_string_literal: true

module Api
  module V1
    class PricesController < Api::V1::ApiController
      helper ApplicationHelper

      def index
        @exam_bodies = ExamBody.all_active.all_in_order
        @group       = Group.find_by(name_url: params[:group])
        @currency    = user_currency(params[:user_id], params[:iso_code])

        if @group
          @exam_bodies = @group.exam_body
          @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id).
                                  includes(:currency).in_currency(@currency.id).all_active.all_in_display_order
          @products = Product.for_group(@group.id).includes(:currency, :group, cbe: :course, mock_exam: :course).in_currency(@currency.id).all_active
        else
          @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).
                                  includes(:currency).in_currency(@currency.id).all_active.all_in_display_order
          @products = Product.includes(:currency).in_currency(@currency.id).all_active
        end

        render 'api/v1/prices/index.json'
      end

      private

      def user_currency(user_id, iso_code)
        user    = User.find_by(id: user_id)
        country =
          if iso_code.present?
            Country.find_by(iso_code: iso_code.upcase) || Country.find_by(name: 'United Kingdom')
          else
            IpAddress.get_country(request.remote_ip) || Country.find_by(name: 'United Kingdom')
          end

        user.present? ? user.get_currency(country) : country.currency
      end
    end
  end
end
