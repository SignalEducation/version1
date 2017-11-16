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
#  current_status            :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#

class OrdersController < ApplicationController

  before_action :logged_in_required
  before_action except: [:new, :create] do
    ensure_user_is_of_type(%w(admin))
  end
  before_action only: [:new, :create] do
    ensure_user_is_of_type(%w(individual_student))
  end
  before_action :get_variables

  def index
    @orders = Order.paginate(per_page: 50, page: params[:page]).all_in_order
    @navbar = false
    @footer = false
    @top_margin = false
    seo_title_maker('Orders', '', true)

  end

  def show
    @navbar = false
    @footer = false
    @top_margin = false
    seo_title_maker('Orders', '', true)
  end

  def new
    @product = Product.where(id: params[:product_id]).first
    @mock_exam = @product.mock_exam
    @course = @mock_exam.subject_course
    @order = Order.new
    @navbar = false
  end

  def create
    if current_user && params[:order] && params[:order][:product_id] && params[:order][:stripe_token]

      user = current_user
      @product = Product.find(params[:order][:product_id])
      @mock_exam = @product.mock_exam
      currency = Currency.find(@product.currency_id)
      stripe_token = params[:order][:stripe_token]

      @order = Order.new(allowed_params)
      @order.user_id = user.id
      @order.product_id = @product.id

      stripe_order = Stripe::Order.create(
          currency: currency.iso_code,
          customer: user.stripe_customer_id,
          email: user.email,
          items: [{
                      amount: (@product.price.to_f * 100).to_i,
                      currency: currency.iso_code,
                      quantity: 1,
                      parent: @product.stripe_sku_guid
                  }]
      )

      @order.stripe_customer_id = stripe_order.customer
      @order.stripe_guid = stripe_order.id
      @order.live_mode = stripe_order.livemode
      @order.current_status = stripe_order.status
      random_guid = "Order_#{ApplicationController.generate_random_number(10)}"
      @order.reference_guid = random_guid

      if @order.valid?
        order = Stripe::Order.retrieve(@order.stripe_guid)
        @pay_order = order.pay(source: stripe_token)
      end
      order = Stripe::Order.retrieve(@order.stripe_guid)
      @order.current_status = order.status
      @order.stripe_order_payment_data = @pay_order
    else
      render action: :new
    end

    if @order.save
      flash[:success] = I18n.t('controllers.orders.create.flash.mock_exam_success')
      MandrillWorker.perform_async(user.id, 'send_mock_exam_email', account_url, @mock_exam.name, @mock_exam.file, @order.reference_guid)
      redirect_to account_url(anchor: :orders)
    else
      render action: :new
    end
    @navbar = false
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
