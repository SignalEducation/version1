class UserVerificationsController < ApplicationController

  before_action only: [:admin_resend_verification_mail] do
    ensure_user_has_access_rights(%w(user_management_access))
  end
  before_action :get_variables

  def update
    @user = User.get_and_verify(params[:email_verification_code])
    if @user && @user.password_change_required?
      @user.update_attributes(password_reset_requested_at: Time.now, password_reset_token: SecureRandom.hex(10))
      set_password_url = set_password_url(id: @user.password_reset_token)
      redirect_to set_password_url
    elsif @user
      UserSession.create(@user)
      set_current_visit
      redirect_to account_verified_url
    else
      flash[:error] = I18n.t('controllers.user_activations.update.error')
      redirect_to library_url
    end
  end

  def account_verified
    #This is the post email verification page

  end

  def resend_verification_mail
    @user = User.find_by_email_verification_code(params[:email_verification_code])
    if @user
      flash[:success] = I18n.t('controllers.home_pages.resend_verification_mail.flash.success')
      MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))
    else
      redirect_to(root_url)
    end
  end

  def admin_resend_verification_mail
    @user = User.find_by_email_verification_code(params[:email_verification_code])
    if @user
      flash[:success] = 'Verification Email sent'
      MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))
      redirect_to users_url
    else
      flash[:error] = 'Verification Email was not sent'
      redirect_to users_url
    end
  end

  protected

  def get_variables
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
    @subject_courses = SubjectCourse.all_active.all_in_order
    @groups = Group.all_active.all_in_order
  end


end
