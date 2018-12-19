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
#

class OrdersController < ApplicationController

  #TODO Review this controller split student and admin actions

  before_action :logged_in_required
  before_action except: [:new, :create, :order_complete] do
    ensure_user_has_access_rights(%w(user_management_access stripe_management_access))
  end
  before_action :get_variables

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
    @product = Product.where(id: params[:product_id]).first
    @mock_exam = @product.mock_exam
    @course = @mock_exam.subject_course
    @order = Order.new
    @layout = 'standard'
  end

  ## API call to stripe to submit order ##
  def create
    #TODO - This is all too complicated. Needs simplification.

    if current_user && params[:order] && params[:order][:product_id] && params[:order][:stripe_token]

      user = current_user
      @product = Product.find(params[:order][:product_id])
      @mock_exam = @product.mock_exam
      currency = Currency.find(@product.currency_id)
      stripe_token = params[:order][:stripe_token]

      @order = Order.new(allowed_params)
      @order.user_id = user.id
      @order.product_id = @product.id

      begin
        # stripe_order = Stripe::Order.create(
        #     currency: currency.iso_code,
        #     customer: user.stripe_customer_id,
        #     email: user.email,
        #     items: [{
        #                 amount: (@product.price.to_f * 100).to_i,
        #                 currency: currency.iso_code,
        #                 quantity: 1,
        #                 parent: @product.stripe_sku_guid
        #             }]
        # )

        # @order.stripe_customer_id = stripe_order.customer
        # @order.stripe_guid = stripe_order.id
        # @order.live_mode = stripe_order.livemode
        # @order.stripe_status = stripe_order.status
        # random_guid = "Order_#{ApplicationController.generate_random_number(10)}"
        # @order.reference_guid = random_guid


        if @order.valid?
          order = Stripe::Order.retrieve(@order.stripe_guid)
          @pay_order = order.pay(source: stripe_token)
        end
        order = Stripe::Order.retrieve(@order.stripe_guid)
        @order.stripe_status = order.status
        @order.stripe_order_payment_data = @pay_order

        if @order.save
          flash[:success] = I18n.t('controllers.orders.create.flash.mock_exam_success')
          MandrillWorker.perform_async(user.id, 'send_mock_exam_email', account_url, @mock_exam.name, @mock_exam.file, @order.reference_guid)
          redirect_to order_complete_url(@order.reference_guid)
        else
          redirect_to request.referrer
        end


      rescue Stripe::CardError => e
        body = e.json_body
        err  = body[:error]

        Rails.logger.error "DEBUG: Order#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"

        flash[:error] = "Sorry! Your request was declined because - #{err[:message]}"
        redirect_to request.referrer

      rescue => e
        Rails.logger.error "DEBUG: Order#create Failure for unknown reason - Error: #{e.inspect}"
        flash[:error] = 'Sorry Something went wrong! Please contact us for assistance.'
        redirect_to request.referrer
      end

    else
      redirect_to request.referrer
    end

    @navbar = false
  end

  def execute
    case params[:payment_processor]
    when 'paypal'
      if PaypalService.new.execute_payment(@order, params[:token])
        @subscription.start
        SubscriptionService.new(@subscription).validate_referral
        redirect_to order_complete_url(@order.reference_guid)
      else
        Rails.logger.error "DEBUG: Subscription Failed to save for unknown reason - #{@order.inspect}"
        flash[:error] = 'Your PayPal request was declined. Please contact us for assistance!'
        redirect_to new_order_path(@order)
      end
    else
      flash[:error] = 'Your payment request was declined. Please contact us for assistance!'
      redirect_to new_order_path(@order)
    end
  rescue Learnsignal::PaymentError => e
    flash[:error] = e.message
    redirect_to new_order_path(@order)
  end

  def order_complete
    @order = Order.where(reference_guid: params[:reference_guid]).first
    unless @order
      redirect_to root_url
      flash[:error] = 'Sorry something went wrong. Please try again or contact us for assistance.'
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @order = Order.where(id: params[:id]).first
    end
    @products = Product.all_in_order
    @currencies = Currency.all_in_order
  end

  def allowed_params
    params.require(:order).permit(:subject_course_id, :product_id, :user_id, :stripe_token, :terms_and_conditions)
  end

end
