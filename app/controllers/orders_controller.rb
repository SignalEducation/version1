# == Schema Information
#
# Table name: orders
#
#  id                 :integer          not null, primary key
#  product_id         :integer
#  subject_course_id  :integer
#  user_id            :integer
#  stripe_guid        :string
#  stripe_customer_id :string
#  live_mode          :boolean          default(FALSE)
#  current_status     :string
#  coupon_code        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class OrdersController < ApplicationController

  before_action :logged_in_required, except: [:new, :create]
  before_action except: [:new, :create] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @orders = Order.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @order = Order.new
  end

  def create

    if params[:order] && params[:order][:subject_course_id] && params[:order][:stripe_token]

      user = current_user
      subject_course_id = params[:order][:subject_course_id]
      product = Product.find_by_subject_course_id(subject_course_id)
      currency = Currency.find(product.currency_id)
      stripe_token = params[:order][:stripe_token]

      @order = Order.new(allowed_params)
      @order.user_id = user.id
      @order.product_id = product.id

      stripe_order = Stripe::Order.create(
          currency: currency.iso_code,
          customer: user.stripe_customer_id,
          email: user.email,
          items: [{
                      amount: (product.price.to_f * 100).to_i,
                      currency: currency.iso_code,
                      quantity: 1,
                      parent: product.stripe_sku_guid
                  }]
      )

      @order.stripe_customer_id = stripe_order.customer
      @order.stripe_guid = stripe_order.id
      @order.live_mode = stripe_order.livemode
      @order.current_status = stripe_order.status

      if @order.valid?
        order = Stripe::Order.retrieve(@order.stripe_guid)
        pay_order = order.pay(source: stripe_token)
        #order_transaction = OrderTransaction.create_from_stripe_data(pay_order)
      end
    else
      redirect_to new_order_url
    end

    if @order.save
      flash[:success] = I18n.t('controllers.orders.create.flash.success')
      redirect_to orders_url
    else
      render action: :new
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @order = Order.where(id: params[:id]).first
    end
    @product_category = SubjectCourseCategory.all_product.first
    @courses = SubjectCourse.all_active.all_in_order.in_category(@product_category.id)
  end

  def allowed_params
    params.require(:order).permit(:subject_course_id, :user_id, :stripe_token)
  end

end
