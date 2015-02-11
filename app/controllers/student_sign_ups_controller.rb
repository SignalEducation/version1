class StudentSignUpsController < ApplicationController

  before_action :logged_out_required
  before_action :get_variables

  def new
    @user = User.new
    @user.subscriptions.build(subscription_plan_id: @subscription_plans.first.id)
  end

  def create
    @user = User.new(allowed_params.merge(user_group_id: 1))
    if @user.save
      @user = User.get_and_activate(@user.account_activation_code)
      UserSession.create(@user)
      assign_anonymous_logs_to_user
      flash[:success] = I18n.t('controllers.student_sign_ups.create.flash.success')
      redirect_to personal_sign_up_complete_url
    else
      extra_needed = nil
      @user.errors.each do |field, _|
        if field.to_s.include?('.')
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
    @countries = Country.includes(:currency).all_in_order
    @email_frequencies = User::EMAIL_FREQUENCIES
    @subscription_plans = SubscriptionPlan.includes(:currency).for_students.all_active.all_in_order
  end

  def assign_anonymous_logs_to_user
    model_list = [CourseModuleElementUserLog, UserActivityLog, StudentExamTrack]
    model_list.each do |the_model|
      the_model.assign_user_to_session_guid(@user.id, current_session_guid)
    end
  end

end
