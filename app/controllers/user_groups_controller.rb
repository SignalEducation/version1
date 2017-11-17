# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string
#  description                  :text
#  individual_student           :boolean          default(FALSE), not null
#  tutor                        :boolean          default(FALSE), not null
#  content_manager              :boolean          default(FALSE), not null
#  blogger                      :boolean          default(FALSE), not null
#  site_admin                   :boolean          default(FALSE), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  complimentary                :boolean          default(FALSE)
#  customer_support             :boolean          default(FALSE)
#  marketing_support            :boolean          default(FALSE)
#  system_requirements_access   :boolean          default(FALSE)
#  content_management_access    :boolean          default(FALSE)
#  stripe_management_access     :boolean          default(FALSE)
#  user_management_access       :boolean          default(FALSE)
#  developer_access             :boolean          default(FALSE)
#  home_pages_access            :boolean          default(FALSE)
#  user_group_management_access :boolean          default(FALSE)
#  student_user                 :boolean          default(FALSE)
#  trial_or_sub_required        :boolean          default(FALSE)
#  blocked_user                 :boolean          default(FALSE)
#

class UserGroupsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(user_group_management_access))
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
    @navbar = false
    @footer = false
    @top_margin = false
  end

  def allowed_params
    params.require(:user_group).permit(:name, :description, :system_requirements_access,
                                       :content_management_access, :stripe_management_access,
                                       :user_management_access, :developer_access,
                                       :home_pages_access, :user_group_management_access,
                                       :student_user, :trial_or_sub_required, :blocked_user)
  end

end
