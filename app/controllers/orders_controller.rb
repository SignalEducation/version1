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

  before_action :logged_in_required, except: :new
  #before_action do
  #  ensure_user_is_of_type(['admin'])
  #end
  before_action :get_variables

  def index
    @orders = Order.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @order = Order.new
  end

  def edit
  end

  def create
    @order = Order.new(allowed_params)
    @order.user_id = current_user.id
    if @order.save
      flash[:success] = I18n.t('controllers.orders.create.flash.success')
      redirect_to orders_url
    else
      render action: :new
    end
  end

  def update
    if @order.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.orders.update.flash.success')
      redirect_to orders_url
    else
      render action: :edit
    end
  end


  def destroy
    if @order.destroy
      flash[:success] = I18n.t('controllers.orders.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.orders.destroy.flash.error')
    end
    redirect_to orders_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @order = Order.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:order).permit(:product_id, :subject_course_id, :user_id)
  end

end
