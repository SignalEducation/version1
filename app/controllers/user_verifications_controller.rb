class UserVerificationsController < ApplicationController

  before_action :get_variables

  def update
    ip_country = IpAddress.get_country(request.remote_ip)
    country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user = User.get_and_verify(params[:email_verification_code], country.id)

    if @user && @user.password_change_required?
      @user.update_attributes(password_reset_requested_at: Time.now, password_reset_token: SecureRandom.hex(10))
      set_password_url = set_password_url(id: @user.password_reset_token)
      redirect_to set_password_url
    elsif @user
      UserSession.create(@user)
      set_current_visit
      flash[:success] = 'Thank you! Your email is now verified'
      flash[:datalayer_verify] = true
      if @user.preferred_exam_body&.group
        redirect_to library_special_link(@user.preferred_exam_body.group)
      else
        redirect_to student_dashboard_url
      end

    else
      flash[:warning] = 'Sorry! That link has expired. Please try to sign in or contact us for assistance'
      redirect_to sign_in_url
    end
  end

  def account_verified
    #This is the post email verification page
    redirect_to root_url unless current_user
  end

  def resend_verification_mail
    @user = User.find_by_email_verification_code(params[:email_verification_code])
    if @user && !@user.email_verified
      MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code)) unless Rails.env.test?
      flash[:success] = "Verification Email sent to #{@user.email}"
      redirect_to request.referrer
    else
      flash[:error] = 'Verification Email was not sent.'
      redirect_to request.referrer
    end
  end

  protected

  def get_variables
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
    @subject_courses = SubjectCourse.all_active.all_in_order
    @groups = Group.all_active.all_in_order
  end


end
