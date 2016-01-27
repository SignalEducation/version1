# == Schema Information
#
# Table name: marketing_categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

class MarketingCategoriesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @marketing_categories = MarketingCategory.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @marketing_category = MarketingCategory.new
  end

  def edit
    redirect_to marketing_categories_url unless @marketing_category.editable?
  end

  def create
    @marketing_category = MarketingCategory.new(allowed_params)
    if @marketing_category.save
      flash[:success] = I18n.t('controllers.marketing_categories.create.flash.success')
      redirect_to marketing_categories_url
    else
      render action: :new
    end
  end

  def update
    if !@marketing_category.editable?
      flash[:error] = I18n.t('controllers.marketing_categories.update.flash.error')
      redirect_to marketing_categories_url
    elsif @marketing_category.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.marketing_categories.update.flash.success')
      redirect_to marketing_categories_url
    else
      render action: :edit
    end
  end

  def destroy
    if @marketing_category.destroy
      flash[:success] = I18n.t('controllers.marketing_categories.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.marketing_categories.destroy.flash.error')
    end
    redirect_to marketing_categories_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @marketing_category = MarketingCategory.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:marketing_category).permit(:name)
  end

end
