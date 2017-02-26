# == Schema Information
#
# Table name: user_groups
#
#  id                                   :integer          not null, primary key
#  name                                 :string
#  description                          :text
#  individual_student                   :boolean          default(FALSE), not null
#  corporate_student                    :boolean          default(FALSE), not null
#  tutor                                :boolean          default(FALSE), not null
#  content_manager                      :boolean          default(FALSE), not null
#  blogger                              :boolean          default(FALSE), not null
#  corporate_customer                   :boolean          default(FALSE), not null
#  site_admin                           :boolean          default(FALSE), not null
#  subscription_required_at_sign_up     :boolean          default(FALSE), not null
#  subscription_required_to_see_content :boolean          default(FALSE), not null
#  created_at                           :datetime
#  updated_at                           :datetime
#  complimentary                        :boolean          default(FALSE)
#  customer_support                     :boolean          default(FALSE)
#  marketing_support                    :boolean          default(FALSE)
#

class UserGroupsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables

  def index
    @user_groups = UserGroup.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @user_group = UserGroup.new
  end

  def edit
  end

  def create
    @user_group = UserGroup.new(allowed_params)
    if @user_group.save
      flash[:success] = I18n.t('controllers.user_groups.create.flash.success')
      redirect_to user_groups_url
    else
      render action: :new
    end
  end

  def update
    if @user_group.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.user_groups.update.flash.success')
      redirect_to user_groups_url
    else
      render action: :edit
    end
  end

  def destroy
    if @user_group.destroy
      flash[:success] = I18n.t('controllers.user_groups.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.user_groups.destroy.flash.error')
    end
    redirect_to user_groups_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @user_group = UserGroup.where(id: params[:id]).first
    end
    seo_title_maker(@user_group.try(:name) || 'User groups', '', true)
  end

  def allowed_params
    params.require(:user_group).permit(:name, :description, :individual_student, :tutor, :content_manager, :blogger, :site_admin, :subscription_required_at_sign_up, :subscription_required_to_see_content, :complimentary, :customer_support, :marketing_support)
  end

end
