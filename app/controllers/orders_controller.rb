# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  subject_course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default(FALSE)
#  stripe_status             :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#  paypal_guid               :string
#  paypal_status             :string
#  state                     :string
#

class OrdersController < ApplicationController
  # TODO, Review this controller split student and admin actions

  before_action :logged_in_required
  before_action only: %i[index show] do
    ensure_user_has_access_rights(%w[user_management_access stripe_management_access])
  end
  before_action :set_order, only: %i[show execute]

  def index
    @orders = Order.paginate(per_page: 50, page: params[:page]).all_in_order
    @layout = 'management'

    seo_title_maker('Orders', '', true)
  end

  def show
    @layout = 'management'

    seo_title_maker('Orders', '', true)
  end

  def new
    @order     = Order.new
    @product   = Product.find(params[:product_id])
    @layout    = 'standard'
    MailchimpService.new.audience_checkout_tag(current_user.id, @product.mock_exam.subject_course.exam_body_id, @product.name, 'active')
    seo_title_maker("#{@product.mock_exam.name} Payment | LearnSignal", 'Get access to ACCA question and solution correction packs from learnsignal designed by experts to help you pass your exams the first time.', true)
  end

  def create
    order        = current_user.orders.build(allowed_params)
    order_object = PurchaseService.new(order)
    @order       = order_object.create_purchase

    @order.transaction do
      if @order.save # an order invoice will be created by order model callback
        if order_object.stripe? && @order.complete
          flash[:success] = I18n.t('controllers.orders.create.flash.mock_exam_success')
          redirect_to user_exercises_path(current_user)
        elsif order_object.paypal?
          redirect_to @order.paypal_approval_url
        else
          flash[:error] = 'Something went wrong. Please try again.'
          redirect_to new_order_url(product_id: @order.product_id)
        end
      else
        flash[:error] = 'Something went wrong. Please try again. Or contact us for assistance'
        redirect_to new_order_url(product_id: @order.product_id)
      end
    end

    @navbar = false
  rescue Learnsignal::PaymentError => e
    flash[:error] = e.message
    redirect_to new_order_url(product_id: allowed_params['product_id'])
  end

  def execute
    case params[:payment_processor]
    when 'paypal'
      PaypalService.new.execute_payment(@order, params[:paymentId], params[:PayerID])
      flash[:success] = I18n.t('controllers.orders.create.flash.mock_exam_success')
      redirect_to user_exercises_path(current_user)
    else
      flash[:error] = 'Your payment request was declined. Please contact us for assistance!'
      redirect_to new_order_url(product_id: @order.product_id)
    end
  rescue Learnsignal::PaymentError => e
    flash[:error] = e.message
    redirect_to new_order_path(product_id: @order.product_id)
  end

  def complete
    @order = Order.find_by(reference_guid: params[:reference_guid])

    return if @order.present?

    redirect_to root_url
    flash[:error] = 'Sorry something went wrong. Please try again or contact us for assistance.'
  end

  protected

  def set_order
    @order = Order.find(params[:id]) if params[:id].to_i.positive?
  end

  def allowed_params
    params.require(:order).permit(
      :subject_course_id, :product_id, :user_id,
      :stripe_token, :use_paypal, :paypal_approval_url
    )
  end
end
