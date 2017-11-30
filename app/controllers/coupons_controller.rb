# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default(FALSE)
#  active             :boolean          default(FALSE)
#  amount_off         :integer
#  duration           :string
#  duration_in_months :integer
#  max_redemptions    :integer
#  percent_off        :integer
#  redeem_by          :datetime
#  times_redeemed     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_coupon_data :text
#

class CouponsController < ApplicationController

  before_action :logged_in_required
  before_action except: [:validate_coupon] do
    ensure_user_has_access_rights(%w(stripe_management_access))
  end
  before_action :get_variables

  def index
    @coupons = Coupon.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @coupon = Coupon.new
  end

  def create
    @coupon = Coupon.new(allowed_params)
    if @coupon.save
      flash[:success] = I18n.t('controllers.coupons.create.flash.success')
      redirect_to coupons_url
    else
      render action: :new
    end
  end

  def destroy
    if @coupon.destroy
      flash[:success] = I18n.t('controllers.coupons.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.coupons.destroy.flash.error')
    end
    redirect_to coupons_url
  end

  def validate_coupon
    respond_to do |format|
      format.json {
        discount = Coupon.verify_coupon_and_get_discount(params[:coupon_code], params[:plan_id])
        data = {valid: discount[0], discounted_price: discount[1]}

        render json: data, status: :ok
      }
    end

  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @coupon = Coupon.where(id: params[:id]).first
    end
    @currencies = Currency.all_in_order.all_active
    @layout = 'management'
  end

  def allowed_params
    params.require(:coupon).permit(:name, :code, :currency_id, :amount_off, :duration, :max_redemptions,
                                   :duration_in_months, :percent_off, :redeem_by)
  end

end
