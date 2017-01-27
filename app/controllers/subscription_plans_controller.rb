# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  available_to_students         :boolean          default(FALSE), not null
#  available_to_corporates       :boolean          default(FALSE), not null
#  all_you_can_eat               :boolean          default(TRUE), not null
#  payment_frequency_in_months   :integer          default(1)
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string
#  trial_period_in_days          :integer          default(0)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default(FALSE)
#

class SubscriptionPlansController < ApplicationController

  before_action :logged_in_required, except: [:public_index]
  before_action except: [:public_index] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @student_subscription_plans = SubscriptionPlan.for_students.paginate(per_page: 50, page: params[:page]).all_in_order
    @corporate_subscription_plans = SubscriptionPlan.for_corporates.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def public_index
    ip_country = IpAddress.get_country(request.remote_ip)
    country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @currency_id = country.currency_id
    @student_subscription_plans = SubscriptionPlan.where('price > 0.0').where(livemode: true).where(subscription_plan_category_id: nil).includes(:currency).for_students.in_currency(@currency_id).all_active.all_in_order
    @student_plan_1 = @student_subscription_plans[0]
    @student_plan_2 = @student_subscription_plans[1]
    @student_plan_3 = @student_subscription_plans[2]
    seo_title_maker('Pricing', 'Join LearnSignal today. Sign up in seconds.', nil)
  end

  def show
  end

  def new
    @subscription_plan = SubscriptionPlan.new
  end

  def edit
  end

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

  protected

  def get_variables
    if params[:id].to_i > 0
      @subscription_plan = SubscriptionPlan.where(id: params[:id]).first
    end
    @currencies = Currency.all_active.all_in_order
    @payment_frequencies = SubscriptionPlan::PAYMENT_FREQUENCIES
    seo_title_maker(@subscription_plan.try(:id).to_s, '', true)
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
  end

  def create_params
    params.require(:subscription_plan).permit(:available_to_students, :available_to_corporates, :all_you_can_eat, :payment_frequency_in_months, :currency_id, :price, :available_from, :available_to, :stripe_guid, :trial_period_in_days, :name, :subscription_plan_category_id)
  end

  def update_params
    params.require(:subscription_plan).permit(:available_to_students, :available_to_corporates, :available_from, :available_to, :name, :subscription_plan_category_id, :all_you_can_eat)
  end

end
