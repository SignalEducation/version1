# frozen_string_literal: true

module Admin
  class OrdersController < ApplicationController
    before_action :logged_in_required
    before_action only: %i[index show] do
      ensure_user_has_access_rights(%w[user_management_access stripe_management_access])
    end
    before_action :set_order, only: :show

    layout 'management'

    def index
      @orders = Order.includes(:user, :product).paginate(per_page: 50, page: params[:page]).all_in_order
      seo_title_maker('Orders', '', true)
    end

    def show; end

    private

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
