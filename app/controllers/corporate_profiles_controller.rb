class CorporateProfilesController < ApplicationController

  before_action :logged_out_required
  before_action :set_variables

  def show
    redirect_to root_url unless current_corporate
  end

  def login
    redirect_to root_url unless current_corporate
  end

  def corporate_verification
    if params[:user_name] == current_corporate.user_name && params[:passcode] == current_corporate.passcode
      redirect_to new_corporate_profile_url
    else
      flash[:error] = I18n.t('controllers.corporate_profiles.show.flash.error')
      render action: :show
    end
  end

  def new
    if request.referrer
      url_ending = request.referrer.split('/').last
      path_ending = corporate_login_url.split('/').last
      redirect_to corporate_login_url unless (request.subdomain == current_corporate.subdomain) && (url_ending == path_ending)
      @corporate_student = User.new
    else
      redirect_to corporate_login_url
    end
  end

  def create
    @corporate_student = User.new(allowed_params.merge({user_group_id: UserGroup.where(corporate_student: true).first.id}))
    @corporate_student.corporate_customer_id = current_corporate.id if current_corporate
    @corporate_student.password_confirmation = @corporate_student.password
    @corporate_student.activate_user
    @corporate_student.validate_user
    @corporate_student.country_id = current_corporate.country_id  if current_corporate
    @corporate_student.locale = 'en'
    if @corporate_student.valid? && @corporate_student.save
      UserSession.create(@corporate_student)
      redirect_to subscription_groups_url(subdomain: current_corporate.subdomain)
    else
      render action: :new
    end

  end

  protected

  def generate_guid
    @guid = SecureRandom.hex(10)
  end

  def set_variables
    @navbar = nil
    @footer = nil
  end

  def allowed_params
    usr_params = [:first_name, :last_name, :email, :employee_guid, :password, :password_confirmation]
    params.require(:user).permit(usr_params)
  end

end
