# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :logged_in_required
  before_action :set_order, only: %i[execute update]

  include OrdersHelper

  def new
    @product =
      if params[:product_id]
        Product.find(params[:product_id])
      elsif params[:exam_body_id]
        currency_id = user_currency_id
        exam_body = ExamBody.find(params[:exam_body_id])
        @product = Product.for_group(exam_body&.group&.id).where(product_type: :lifetime_access).includes(:currency).in_currency(currency_id).all_active.all_in_order.first
      end

    if @product.nil?
      flash[:warning] = 'Product not found, please contact support.'
      redirect_to student_dashboard_url and return
    end

    @existing_order = current_user.orders.for_product(@product.id).where(state: :completed).last
    if @existing_order && %w[lifetime_access course_access].include?(@existing_order.product.product_type)
      flash[:warning] = 'You have already purchased that product. You cannot purchase it twice.'
      redirect_to student_dashboard_url and return
    elsif !@product
      redirect_to prep_products_url
    end

    @order   = @product&.orders&.build
    @layout  = 'standard'

    seo_title_maker("#{@order&.product&.name_by_type} Payment | Learnsignal", 'Get access to ACCA question and solution correction packs from learnsignal designed by experts to help you pass your exams the first time.', true)
  end

  def create
    order_object = PurchaseService.new(current_user.orders.build(order_params))
    @order       = order_object.create_purchase
    @navbar      = false

    @order.transaction do
      if @order.save
        generate_order_response(@order, order_object)
      else
        respond_to do |format|
          format.html { render_general_html_error(@order.product_id) }
          format.json { render_general_json_error }
        end
      end
    end
  rescue Learnsignal::PaymentError => e
    respond_to do |format|
      format.html do
        render_general_html_error(order_params['product_id'], e.message)
      end
      format.json { render_general_json_error(e.message) }
    end
  end

  def update
    if @order.stripe? && @order.pending_3d_secure?
      update_status(params[:status])
    else
      raise(Learnsignal::PaymentError,
            'Your payment was declined. Please contact us for assistance!')
    end
  rescue Learnsignal::PaymentError => e
    render json: { error: { message: e.message } }, status: :unprocessable_entity
  end

  def execute
    case params[:payment_processor]
    when 'paypal'
      PaypalService.new.execute_payment(@order, params[:paymentId], params[:PayerID])
      flash[:success] =
        I18n.t('controllers.orders.create.flash.mock_exam_success')
      if @order.product.lifetime_access?
        redirect_to order_complete_url(product_id: @order.product_id,
                                       product_type: @order.product.url_by_type,
                                       order_id: @order.id,
                                       payment_processor: 'Paypal')
      else
        redirect_to user_exercises_path(current_user)
      end
    else
      render_general_html_error(@order.product_id, 'Your payment request was ' \
                                'declined. Please contact us for assistance!')
    end
  rescue Learnsignal::PaymentError => e
    render_general_html_error(@order.product_id, e.message)
  end

  def order_complete
    @order          = Order.find_by(id: params[:order_id])
    @product        = Product.find_by(id: params[:product_id])
    @subscriptions  = Subscription.where(user_id: @order.user_id).not_pending
    @payment_processor = params[:payment_processor]
    @studies_link   =
      if @product&.lifetime_access?
        student_dashboard_url
      elsif @product&.course_access?
        library_course_url(@product.group.name_url, @product.course.name_url)
      else
        user_exercises_path(current_user)
      end
  end

  private

  def order_params
    params.require(:order).permit(
      :course_id, :product_id, :user_id, :stripe_payment_method_id,
      :use_paypal, :paypal_approval_url, :stripe_payment_intent_id
    )
  end

  def generate_order_response(order, order_object)
    if order_object.stripe? && (order.pending_3d_secure? || order.complete)
      render 'create', status: :ok
    elsif order_object.paypal?
      redirect_to order.paypal_approval_url
    else
      respond_to do |format|
        format.html { render_general_html_error(order.product_id) }
        format.json { render_general_json_error }
      end
    end
  end

  def render_general_html_error(product_id, message = nil)
    flash[:error] = message || 'Something went wrong. Please try again.'
    redirect_to new_product_order_url(product_id: product_id)
  end

  def render_general_json_error(message = nil)
    render json: {
      error: { message: (message || 'Something went wrong. Please try again.') }
    }, status: :unprocessable_entity
  end

  def set_order
    @order = Order.find_by(id: params[:id])
  end

  def update_status(status)
    case status
    when 'requires_confirmation'
      @order.confirm_payment_intent
    when 'succeeded'
      @order.confirm_3d_secure unless @order.completed?
    else
      @order.mark_pending
      raise Learnsignal::PaymentError, 'Your payment was declined. Please try again.'
    end
    render 'create', status: :ok
  end

  def user_currency_id
    if current_user
      country = IpAddress.get_country(request.remote_ip) || current_user.country
      currency = current_user.get_currency(country)
      currency_id = currency.id
    else
      country = IpAddress.get_country(request.remote_ip) || Country.find_by(name: 'United Kingdom')
      currency_id = country.currency_id
    end

    currency_id
  end
end
