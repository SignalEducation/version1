class StudentSignUpsController < ApplicationController

  before_action :get_variables

  def show
  end

  def resend_verification_mail
    IntercomVerificationMessageWorker.perform_at(30.seconds.from_now, @user.id,user_verification_url(email_verification_code: @user.email_verification_code))
  end

  protected

  def get_variables
    @courses = SubjectCourse.all_active.all_live.all_in_order
    @user = current_user
    if @user.email_verification_code.nil?
      redirect_to(root_url)
    end
  end

end
