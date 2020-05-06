# frozen_string_literal: true

class UserVerificationsController < ApplicationController
  before_action :get_variables

  def update
    ip_country = IpAddress.get_country(request.remote_ip)
    country    = ip_country || Country.find_by(name: 'United Kingdom')
    @user      = User.get_and_verify(params[:email_verification_code], country.id)

    if @user&.password_change_required?
      @user.update(password_reset_requested_at: Time.zone.now, password_reset_token: SecureRandom.hex(10))
      redirect_to set_password_url(id: @user.password_reset_token)
    elsif @user
      UserSession.create(@user)
      set_current_visit(@user)
      flash[:datalayer_verify] = true
      if @user.preferred_exam_body&.group
        if @user.preferred_exam_body&.group == Group.find_by(name: 'CPD')
          redirect_to registration_onboarding_url(@user.preferred_exam_body.group.name_url)
        else
          lib_version = library_special_link(@user.preferred_exam_body.group)
          onboarding_version = registration_onboarding_url(@user.preferred_exam_body.group.name_url)

          ab_test(:user_onboarding, 'library', 'onboarding') do |test|
            # flash[:success] = 'Thank you! Your email is now verified'
            redirect_to test == 'onboarding' ? onboarding_version : lib_version
          end
        end
      else
        flash[:success] = 'Thank you! Your email is now verified'
        redirect_to student_dashboard_url
      end

    else
      flash[:warning] = 'Sorry! That link has expired. Please try to sign in or contact us for assistance'
      redirect_to sign_in_url
    end
  end

  def account_verified
    # This is the post email verification page
    redirect_to root_url unless current_user

    @group = Group.find_by(name_url: params[:group_url])
    redirect_to root_url and return unless @group&.active && @group&.exam_body&.active

    seo_title_maker("Welcome to learnsignal #{@group.name}", @group.seo_description, nil)

    @levels = @group.levels.all_active
    @courses = @group.subject_courses.all_active.where(on_welcome_page: true)

    ip_country = IpAddress.get_country(request.remote_ip)
    country = ip_country ? ip_country : Country.find_by(name: 'United Kingdom')
    @currency_id = current_user ? current_user.get_currency(country).id : country.try(:currency_id)

    if country && @currency_id
      @subscription_plan =
          SubscriptionPlan.where(
              subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id,
              payment_frequency_in_months: @group.exam_body.preferred_payment_frequency).
              includes(:currency).in_currency(@currency_id).all_active.all_in_order.first
    end
    @navbar     = false
    @top_margin = false
    @footer     = false
  end

  def resend_verification_mail
    @user = User.find_by(email_verification_code: params[:email_verification_code])

    if @user && !@user.email_verified
      MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code)) unless Rails.env.test?
      flash[:success] = "Verification Email sent to #{@user.email}"
    else
      flash[:error] = 'Verification Email was not sent.'
    end

    redirect_to request.referrer
  end

  protected

  def get_variables
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
    @subject_courses = SubjectCourse.all_active.all_in_order
    @groups = Group.all_active.all_in_order
  end
end
