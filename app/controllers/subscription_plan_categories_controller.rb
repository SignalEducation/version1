class SubscriptionPlanCategoriesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @subscription_plan_categories = SubscriptionPlanCategory.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @subscription_plan_category = SubscriptionPlanCategory.new
  end

  def edit
  end

  def create
    @subscription_plan_category = SubscriptionPlanCategory.new(allowed_params)
    if @subscription_plan_category.save
      flash[:success] = I18n.t('controllers.subscription_plan_categories.create.flash.success')
      redirect_to subscription_plan_categories_url
    else
      render action: :new
    end
  end

  def update
    if @subscription_plan_category.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.subscription_plan_categories.update.flash.success')
      redirect_to subscription_plan_categories_url
    else
      render action: :edit
    end
  end


  def destroy
    if @subscription_plan_category.destroy
      flash[:success] = I18n.t('controllers.subscription_plan_categories.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.subscription_plan_categories.destroy.flash.error')
    end
    redirect_to subscription_plan_categories_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @subscription_plan_category = SubscriptionPlanCategory.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:subscription_plan_category).permit(:name, :available_from, :available_to)
  end

end
