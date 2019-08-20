# frozen_string_literal: true

class UserGroupsController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[user_group_management_access]) }
  before_action :management_layout
  before_action :get_variables

  def index
    @user_groups = UserGroup.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show; end

  def new
    @user_group = UserGroup.new
  end

  def edit; end

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
    @user_group = UserGroup.find_by(id: params[:id]) if params[:id].to_i.positive?
    seo_title_maker(@user_group.try(:name) || 'User groups', '', true)
  end

  def allowed_params
    params.require(:user_group).permit(:name, :description, :system_requirements_access,
                                       :content_management_access, :stripe_management_access,
                                       :user_management_access, :developer_access,
                                       :marketing_resources_access, :user_group_management_access,
                                       :student_user, :trial_or_sub_required, :blocked_user,
                                       :tutor, :exercise_corrections_access)
  end
end
