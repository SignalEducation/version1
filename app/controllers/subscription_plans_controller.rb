# frozen_string_literal: true

class SubscriptionPlansController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[stripe_management_access]) }
  before_action :management_layout
  before_action :get_variables

  def index
    @subscription_plans = SubscriptionPlan.includes(:subscriptions, :currency, :exam_body).
                            search(params[:search]).
                            by_exam_body(params[:exam_body_id]).
                            all_in_order

    seo_title_maker('Subscription Plans', '', true)
  end

  def show; end

  def new
    @subscription_plan = SubscriptionPlan.new
  end

  def edit; end

  def create
    @subscription_plan = SubscriptionPlan.new(create_params)

    if @subscription_plan.save
      flash[:success] = I18n.t('controllers.subscription_plans.create.flash.success')
      redirect_to subscription_plans_url
    else
      render action: :new
    end
  end

  def update
    if @subscription_plan.update_attributes(update_params)
      flash[:success] = I18n.t('controllers.subscription_plans.update.flash.success')
      redirect_to subscription_plans_url
    else
      render action: :edit
    end
  end

  def destroy
    if @subscription_plan.destroy
      flash[:success] = I18n.t('controllers.subscription_plans.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.subscription_plans.destroy.flash.error')
    end

    redirect_to subscription_plans_url
  end

  def all_subscriptions
    @subscriptions = Subscription.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def subscription_show
    @subscription = Subscription.where(id: params[:id]).first
  end

  private

  def get_variables
    @subscription_plan = SubscriptionPlan.find_by(id: params[:id]) if params[:id].to_i > 0
    @currencies = Currency.all_active.all_in_order
    @payment_frequencies = SubscriptionPlan::PAYMENT_FREQUENCIES
    seo_title_maker(@subscription_plan.try(:id).to_s, '', true)
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
  end

  def create_params
    params.require(:subscription_plan).permit(
      :payment_frequency_in_months, :currency_id, :price, :available_from,
      :name, :subscription_plan_category_id, :available_to, :stripe_guid,
      :monthly_percentage_off, :previous_plan_price, :exam_body_id,
      :sub_heading_text, :bullet_points_list
    )
  end

  def update_params
    params.require(:subscription_plan).permit(
      :available_from, :available_to, :name,
      :subscription_plan_category_id, :monthly_percentage_off,
      :previous_plan_price, :exam_body_id,
      :sub_heading_text, :bullet_points_list, :most_popular,
      :registration_form_heading, :login_form_heading
    )
  end
end
