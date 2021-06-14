# frozen_string_literal: true

class UserVerificationsController < ApplicationController
  before_action :get_variables
  before_action :set_verify_flash, only: :update

  def update
    ip_country = IpAddress.get_country(request.remote_ip) unless Rails.env.test?
    country    = ip_country || Country.find_by(name: 'United Kingdom')
    @user      = User.get_and_verify(params[:email_verification_code], country&.id)

    if @user&.password_change_required?
      @user.update(password_reset_requested_at: Time.zone.now, password_reset_token: SecureRandom.hex(10))
      redirect_to set_password_url(id: @user.password_reset_token)
    elsif @user
      UserSession.create(@user)
      set_current_visit(@user)

      SegmentService.new.track_verification_event(@user) if flash[:datalayer_verify] || !Rails.env.test?
      if @user.preferred_exam_body&.group
        # Redirect to account_verified method below
        redirect_to registration_onboarding_url(@user.preferred_exam_body.group.name_url)
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
    @group = Group.find_by(name_url: params[:group_url])

    if current_user && @group&.active && @group&.exam_body&.active
      seo_title_maker("Welcome to learnsignal #{@group.name}", @group.seo_description, nil)
      @exam_body   = @group.exam_body
      @levels      = @group.levels.all_active
      @courses     = @group.courses.all_active.where(on_welcome_page: true)
      ip_country   = IpAddress.get_country(request.remote_ip)
      country      = ip_country || Country.find_by(name: 'United Kingdom')
      @currency_id = current_user ? current_user.get_currency(country).id : country.try(:currency_id)

      if country && @currency_id
        @subscription_plan =
          SubscriptionPlan.where(
            subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id,
            payment_frequency_in_months: @group.exam_body.preferred_payment_frequency
          ).includes(:currency).in_currency(@currency_id).all_active.all_in_order.first
      end

      @navbar     = false
      @top_margin = false
      @footer     = false
    else
      redirect_to root_url
    end
  end

  def resend_verification_mail
    @user = User.find_by(email_verification_code: params[:email_verification_code])

    if @user && !@user.email_verified
      Message.create(
        process_at: Time.zone.now,
        user_id: @user.id,
        kind: :account,
        template: 'send_verification_email',
        template_params: {
          url: user_verification_url(email_verification_code: @user.email_verification_code)
        }
      )
      flash[:success] = "Verification Email sent to #{@user.email}"
    else
      flash[:error] = 'Verification Email was not sent.'
    end
    redirect_to request.referrer
  end

  protected

  def get_variables
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
    @courses = Course.all_active.all_in_order
    @groups = Group.all_active.all_in_order
  end

  def set_verify_flash
    user = User.find_by(email_verification_code: params[:email_verification_code])
    return if user&.email_verified_at

    flash[:datalayer_verify] = true
  end
end
