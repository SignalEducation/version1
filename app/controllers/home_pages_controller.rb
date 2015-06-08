class HomePagesController < ApplicationController

  before_action :logged_in_required, except: [:show]
  before_action except: [:show] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def show
    seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)
    if @home_page
      cookies.encrypted[:latest_subscription_plan_category_guid] ||= {value: @home_page.subscription_plan_category.try(:guid), httponly: true}
    end
  end

  def new
    @home_page = HomePage.new
  end

  def edit
  end

  def create
    @home_page = HomePage.new(allowed_params)
    if @home_page.save
      flash[:success] = I18n.t('controllers.home_pages.create.flash.success')
      redirect_to home_pages_url
    else
      render action: :new
    end
  end

  def update
    if @home_page.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.home_pages.update.flash.success')
      redirect_to home_pages_url
    else
      render action: :edit
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @home_page = HomePage.where(id: params[:id]).first
    end
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
  end

  def allowed_params
    params.require(:home_page).permit(:seo_title, :seo_description, :subscription_plan_category_id, :public_url)
  end

end
