class StudentSignUpsController < ApplicationController

  before_action :logged_out_required, except: :show
  before_action :logged_in_required, only: :show
  before_action :get_variables

  def show
    # this is the 'thank you for registering' page
    @user = User.find_by_guid(params[:id])
    if @user.subscriptions.count == 1
      @subscription = @user.subscriptions.first
    else
      redirect_to profile_url
    end
  end

  def new
    @user = User.new
    @user.country_id = IpAddress.get_country(request.remote_ip).try(:id)
    @user.subscriptions.build(subscription_plan_id: @subscription_plans.first.id)
  end

  def create
    @user = User.new(allowed_params.merge(user_group_id: 1))
    if @user.save
      @user = User.get_and_activate(@user.account_activation_code)
      UserSession.create(@user)
      assign_anonymous_logs_to_user(@user.id)
      flash[:success] = I18n.t('controllers.student_sign_ups.create.flash.success')
      redirect_to personal_sign_up_complete_url(@user.guid)
    else
      extra_needed = nil
      @user.errors.dup.each do |field, message|
        if field.to_s.include?('credit_card')
          @user.errors.delete(field)
          @user.errors.add(:base, message)
        elsif field.to_s.include?('.')
          @user.errors.delete(field)
          extra_needed = true
        end
      end
      if extra_needed
        @user.errors[:subscription_plan] = I18n.t('views.layouts.error_messages.is_invalid')
      end
      render 'new'
    end
  end

  protected

  def allowed_params
    params.require(:user).permit(
          :email, :first_name, :last_name,
          :country_id, :locale,
          #:operational_email_frequency,
          #:study_plan_notifications_email_frequency,
          #:falling_behind_email_alert_frequency,
          #:marketing_email_frequency,
          #:marketing_email_permission_given_at,
          #:blog_notification_email_frequency,
          #:forum_notification_email_frequency,
          :password, :password_confirmation,
          subscriptions_attributes: [
                  :subscription_plan_id,
                  :stripe_token
          ]
    )
  end

  def get_variables
    @custom_headings = nil
    @countries = Country.includes(:currency).all_in_order
    @email_frequencies = User::EMAIL_FREQUENCIES
    @subscription_plans = SubscriptionPlan.includes(:currency).for_students.generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid]).all_active.all_in_order

    static_page = StaticPage.find_active_default_for_url(cookies.encrypted[:latest_session_landing_url].gsub("/#{params[:locale]}",''))
    @custom_headings = {
          h1: static_page.try(:student_sign_up_h1),
          sub_head: static_page.try(:student_sign_up_sub_head)
    }
  end

  def assign_anonymous_logs_to_user(user_id)
    model_list = [CourseModuleElementUserLog, UserActivityLog, StudentExamTrack]
    model_list.each do |the_model|
      the_model.assign_user_to_session_guid(user_id, current_session_guid)
    end
  end

end
