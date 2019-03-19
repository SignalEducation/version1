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

  #TODO Review this controller split student and admin actions

  before_action :logged_in_required
  before_action except: [:new, :create, :order_complete, :execute] do
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

  def create
    @order = current_user.orders.build(allowed_params)
    order_object = PurchaseService.new(@order)
    @order = order_object.create_purchase
    if @order && @order.save
      if order_object.stripe? && @order.complete
        flash[:success] = I18n.t('controllers.orders.create.flash.mock_exam_success')
        redirect_to order_complete_url(@order.reference_guid)
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
    @navbar = false
  rescue Learnsignal::PaymentError => e
    flash[:error] = e.message
    redirect_to new_order_url(product_id: @order.product_id)
  end

  def execute
    case params[:payment_processor]
    when 'paypal'
      PaypalService.new.execute_payment(@order, params[:paymentId], params[:PayerID])
      flash[:success] = I18n.t('controllers.orders.create.flash.mock_exam_success')
      redirect_to order_complete_url(@order.reference_guid)
    else
      flash[:error] = 'Your payment request was declined. Please contact us for assistance!'
      redirect_to new_order_url(product_id: @order.product_id)
    end
  rescue Learnsignal::PaymentError => e
    flash[:error] = e.message
    redirect_to new_order_path(product_id: @order.product_id)
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
    params.require(:order).permit(
      :subject_course_id, :product_id, :user_id, :stripe_token,
      :terms_and_conditions, :use_paypal, :paypal_approval_url
    )
  end

end
