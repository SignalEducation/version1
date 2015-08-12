class CorporateGroupsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'corporate_customer'])
  end
  before_action :get_variables

  def index
    @corporate_groups = []
    if current_user.admin?
      @corporate_groups = CorporateGroup.paginate(per_page: 50, page: params[:page]).all_in_order
    elsif current_user.corporate_customer? && current_user.corporate_customer_id
      @corporate_groups = CorporateGroup
                          .where(corporate_customer_id: current_user.corporate_customer_id)
                          .paginate(per_page: 50, page: params[:page]).all_in_order
    end
    @corporate_groups
  end

  def new
    @corporate_group = current_user.admin? ?
                         CorporateGroup.new :
                         CorporateGroup.new(corporate_customer_id: current_user.corporate_customer_id)
  end

  def edit
    if current_user.corporate_customer? && current_user.corporate_customer_id != @corporate_group.corporate_customer_id
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to corporate_groups_url
    end
  end

  def create
    @corporate_group = CorporateGroup.new(allowed_params)
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group.save
      flash[:success] = I18n.t('controllers.corporate_groups.create.flash.success')
      redirect_to corporate_groups_url
    else
      render action: :new
    end
  end

  def update
    name = allowed_params[:name]
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group.update_attributes(name: name)
      flash[:success] = I18n.t('controllers.corporate_groups.update.flash.success')
      redirect_to corporate_groups_url
    else
      render action: :edit
    end
  end

  def destroy
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group &&
       @corporate_group.destroy
      flash[:success] = I18n.t('controllers.corporate_groups.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.corporate_groups.destroy.flash.error')
    end
    redirect_to corporate_groups_url
  end

  protected

  def get_variables
    @corporate_customers = CorporateCustomer.all
    if params[:id].to_i > 0
      @corporate_group = CorporateGroup.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:corporate_group).permit(:corporate_customer_id, :name)
  end

end
