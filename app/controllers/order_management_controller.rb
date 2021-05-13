# frozen_string_literal: true

class OrderManagementController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[user_management_access]) }
  before_action :management_layout

  def show
    @order = Order.find(params[:id])
    @user = @order.user
    @product = Product.find(@order.product_id)
    @admin_user = User.find(@order.cancelled_by_id) if @order.cancelled_by_id
  end

  def cancel_order
    @order = Order.find(params[:order_management_id])
    return if @order.cancelled?

    @order.update(
      state: 'cancelled',
      cancelled_by_id: params[:order][:cancelled_by_id],
      cancellation_note: params[:order][:cancellation_note]
    )
    redirect_to order_management_path(@order.id)
  end

  def un_cancel_order
    @order = Order.find(params[:order_management_id])
    return unless @order.cancelled?

    @order.complete!
    redirect_to order_management_path(@order.id)
  end
end
