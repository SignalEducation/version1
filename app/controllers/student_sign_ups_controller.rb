class StudentSignUpsController < ApplicationController

  before_action :logged_in_required, only: [:account_verified, :admin_resend_verification_mail]
  before_action :logged_out_required, except: [:account_verified, :admin_resend_verification_mail]
  before_action :get_variables

  def show
    #This is the post sign-up landing page.
    #FAQ should be in this view
    @user = User.get_and_activate(params[:account_activation_code])
    redirect_to root_url unless @user
  end

  def account_verified
    #This is the post email verification page
    if current_user.topic_interest.present?
      home_page = HomePage.where(public_url: current_user.topic_interest).first
      @group = home_page.group if home_page
    end
    @groups = Group.for_public.all_active.all_in_order
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
    @courses = SubjectCourse.all_active.all_live.all_in_order
  end
end
