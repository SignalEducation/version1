class SubscriptionPlansController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @subscription_plans = SubscriptionPlan.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @subscription_plan = SubscriptionPlan.new
  end

  def edit
  end

  def create
    @subscription_plan = SubscriptionPlan.new(allowed_params)
    if @subscription_plan.save
      flash[:success] = I18n.t('controllers.subscription_plans.create.flash.success')
      redirect_to subscription_plans_url
    else
      render action: :new
    end
  end

  def update
    if @subscription_plan.update_attributes(allowed_params)
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

  protected

  def get_variables
    if params[:id].to_i > 0
      @subscription_plan = SubscriptionPlan.where(id: params[:id]).first
    end
    @currencies = Currency.all_active.all_in_order
    @payment_frequencies = SubscriptionPlan::PAYMENT_FREQUENCIES
    seo_title_maker(@subscription_plan.try(:id).to_s)
  end

  def allowed_params
    params.require(:subscription_plan).permit(:available_to_students, :available_to_corporates, :all_you_can_eat, :payment_frequency_in_months, :currency_id, :price, :available_from, :available_to, :stripe_guid, :trial_period_in_days)
  end

end
