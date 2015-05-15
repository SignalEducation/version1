class StudentSignUpsController < ApplicationController

  before_action :logged_out_required, except: :show
  before_action :logged_in_required, only: :show
  before_action :get_variables, except: :show

  def show
    # this is the 'thank you for registering' page
    @user = User.find_by(guid: params[:id])
    if @user && @user.subscriptions.count == 1
      @subscription = @user.subscriptions.first
    else
      redirect_to profile_url
    end
  end

  def new
    @user = User.new
    @user.country_id = IpAddress.get_country(request.remote_ip).try(:id)
    if @user.country
      @user.subscriptions.build(subscription_plan_id: @subscription_plans.in_currency(@user.country.currency_id).first.try(:id))
    else
      @user.subscriptions.build(subscription_plan_id: @subscription_plans.first.try(:id))
    end
  end

  def create
    @user = User.new(allowed_params)
    @user.user_group_id = UserGroup.default_student_user_group.try(:id)
    if @user.valid? && @user.save
      MixpanelUserAliasWorker.perform_async(current_session_guid, @user.id)
      MixpanelUserSignUpWorker.perform_async(
        @user.id,
        I18n.t("views.student_sign_ups.form.payment_frequency_in_months.a#{@user.subscriptions.first.subscription_plan.payment_frequency_in_months}")
      )
      @user = User.get_and_activate(@user.account_activation_code)
      UserSession.create(@user)
      @user.assign_anonymous_logs_to_user(current_session_guid)
      # Mailers::OperationalMailers::SignupCompletedWorker.perform_async(@user.id)
      flash[:success] = I18n.t('controllers.student_sign_ups.create.flash.success')
      redirect_to personal_sign_up_complete_url(@user.guid)
    else
      if @user.subscriptions.first.try(:errors)
        @user.subscriptions.first.errors.each { |cat, msg| @user.errors.add(cat, msg) }
      end
      extra_needed = nil
      @user.errors.dup.each do |field, message|
        if field.to_s.include?('credit_card')
          @user.errors.delete(field)
          @user.errors.add(:base, message)
        elsif field.to_s.include?('.')
          Rails.logger.warn "WARN: StudentSignupsController#create failed to create a user nested attribute.  Error: #{field}-#{message}. @user=#{@user.inspect}"
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
    seo_title_maker('Sign up', I18n.t('views.student_sign_ups.new.seo_description'), false)
  end

end
