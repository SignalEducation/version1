# frozen_string_literal: true

class CouponsController < ApplicationController
  before_action :logged_in_required
  before_action except: [:validate_coupon] do
    ensure_user_has_access_rights(%w[stripe_management_access])
  end
  before_action :management_layout
  before_action :set_coupon, only: %i[show edit update]
  before_action :form_variables, only: %i[new edit create]

  def index
    @coupons = Coupon.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show; end

  def new
    @coupon = Coupon.new(active: true)
  end

  def edit; end

  def create
    @coupon = Coupon.new(allowed_params)

    if @coupon.save
      flash[:success] = I18n.t('controllers.coupons.create.flash.success')
      redirect_to coupons_url
    else
      render action: :new
    end
  end

  def update
    if @coupon.update(allowed_params)
      flash[:success] = I18n.t('controllers.coupons.update.flash.success')
      redirect_to coupons_url
    else
      flash[:error] = I18n.t('controllers.coupons.update.flash.error')
      render action: :edit
    end
  end

  def validate_coupon
    discount = Coupon.verify_coupon_and_get_discount(params[:coupon_code], params[:plan_id])

    respond_to do |format|
      format.json do
        render json: { valid: discount[0],
                       discounted_price: discount[1],
                       reason: discount[2],
                       coupon_id: discount[3] }, status: :ok
      end
    end
  end

  protected

  def set_coupon
    @coupon = Coupon.find(params[:id])
  end

  def form_variables
    @currencies = Currency.all_in_order.all_active
    @exam_bodies = ExamBody.all_in_order
  end

  def allowed_params
    params.require(:coupon).permit(:name, :code, :currency_id, :amount_off, :duration, :max_redemptions,
                                   :duration_in_months, :percent_off, :redeem_by, :exam_body_id,
                                   :monthly_interval, :quarterly_interval, :yearly_interval, :active,
                                   :discounted_price, :coupon_id)
  end
end
