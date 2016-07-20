class StudentSignUpsController < ApplicationController

  before_action :logged_in_required
  before_action :get_variables

  def show
  end

  def resend_verification_mail
    @user = current_user
    if @user.email_verification_code.nil?
      redirect_to(root_url)
    else
      flash[:success] = I18n.t('controllers.home_pages.resend_verification_mail.flash.success')
      MandrillWorker.perform_async(user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))
    end
  end

  protected

  def get_variables
    @courses = SubjectCourse.all_active.all_live.all_in_order
  end
end
