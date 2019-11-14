# frozen_string_literal: true

module Admin
  class OrdersController < ApplicationController
    before_action :logged_in_required
    before_action only: %i[index show] do
      ensure_user_has_access_rights(%w[user_management_access stripe_management_access])
    end
    before_action :set_order, only: %i[show update]
    before_action :management_layout

    def index
      @orders = Order.includes(:user, :product).paginate(per_page: 50, page: params[:page]).all_in_order
      seo_title_maker('Orders', '', true)
    end

    def show; end

    def update_product
      @order    = Order.find(params[:order_id])
      @products = @order.product.cbe_id.nil? ? Product.cbes : Product.mock_exams
    end

    def update
      ActiveRecord::Base.transaction do
        @order.update(product_id: params[:order][:product_id])
        @order.exercises.update_all(product_id: params[:order][:product_id])
      end

      flash[:success] = 'Product successfully updated'
      redirect_to admin_order_path(@order)
    rescue => e
      Airbrake::AirbrakeLogger.new(logger).error e.message

      flash[:error] = 'Could not update an order'
      redirect_to admin_orders_path
    end

    private

    def set_order
      @order = Order.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      Airbrake::AirbrakeLogger.new(logger).error e.message
    end
  end
end
