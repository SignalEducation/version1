class CorporateProfilesController < ApplicationController
  require 'pry-remote'
  before_action :logged_out_required

  def show
    @corp_account = @corporate_with_subdomain
  end

  def corporate_verification
    @corp_account = @corporate_with_subdomain
    if params[:user_name] == @corp_account.user_name && params[:passcode] == @corp_account.passcode
      redirect_to new_corporate_profile_url(corp_id: @corp_account.id)
    else
      flash[:error] = I18n.t('controllers.corporate_profiles.show.flash.error')
      render action: :show
    end
  end

  def new
    redirect_to root_url unless (request.subdomain == @corporate_with_subdomain.subdomain) && (params[:corp_id] == @corporate_with_subdomain.id.to_s)
    @corporate_student = User.new
  end

  def create
    @corporate_student = User.new(allowed_params.merge({user_group_id: UserGroup.where(corporate_student: true).first.id}))
    @corporate_student.corporate_customer_id = @corporate_with_subdomain.id if @corporate_with_subdomain
    @corporate_student.activate_user
    @corporate_student.validate_user
    @corporate_student.country_id = @corporate_with_subdomain.country_id  if @corporate_with_subdomain
    @corporate_student.locale = 'en'
    if @corporate_student.valid? && @corporate_student.save
      #@corporate_student.corporate_group_ids = params[:corporate_student][:corporate_group_ids]
      UserSession.create(@corporate_student)
      redirect_to dashboard_url
    else
      render action: :new
    end

  end

  protected

  def allowed_params
    usr_params = [:first_name, :last_name, :email, :employee_guid, :password, :password_confirmation]
    params.require(:user).permit(usr_params)
  end

end
