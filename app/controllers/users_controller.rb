# == Schema Information
#
# Table name: users
#
#  id                               :integer          not null, primary key
#  email                            :string
#  first_name                       :string
#  last_name                        :string
#  address                          :text
#  country_id                       :integer
#  crypted_password                 :string(128)      default(""), not null
#  password_salt                    :string(128)      default(""), not null
#  persistence_token                :string
#  perishable_token                 :string(128)
#  single_access_token              :string
#  login_count                      :integer          default(0)
#  failed_login_count               :integer          default(0)
#  last_request_at                  :datetime
#  current_login_at                 :datetime
#  last_login_at                    :datetime
#  current_login_ip                 :string
#  last_login_ip                    :string
#  account_activation_code          :string
#  account_activated_at             :datetime
#  active                           :boolean          default(FALSE), not null
#  user_group_id                    :integer
#  password_reset_requested_at      :datetime
#  password_reset_token             :string
#  password_reset_at                :datetime
#  stripe_customer_id               :string
#  created_at                       :datetime
#  updated_at                       :datetime
#  locale                           :string
#  guid                             :string
#  trial_ended_notification_sent_at :datetime
#  crush_offers_session_id          :string
#  subscription_plan_category_id    :integer
#  password_change_required         :boolean
#  session_key                      :string
#  name_url                         :string
#  profile_image_file_name          :string
#  profile_image_content_type       :string
#  profile_image_file_size          :integer
#  profile_image_updated_at         :datetime
#  topic_interest                   :string
#  email_verification_code          :string
#  email_verified_at                :datetime
#  email_verified                   :boolean          default(FALSE), not null
#  stripe_account_balance           :integer          default(0)
#  trial_limit_in_seconds           :integer          default(0)
#  free_trial                       :boolean          default(FALSE)
#  trial_limit_in_days              :integer          default(0)
#  terms_and_conditions             :boolean          default(FALSE)
#  discourse_user                   :boolean          default(FALSE)
#  date_of_birth                    :date
#  description                      :text
#  free_trial_ended_at              :datetime
#  analytics_guid                   :string
#  student_number                   :string
#

class UsersController < ApplicationController

  before_action :logged_in_required
  before_action only: [:destroy] do
    ensure_user_is_of_type(%w(admin))
  end
  before_action only: [:index, :new, :edit, :create, :show, :user_personal_details, :user_subscription_status, :user_enrollments_details, :user_purchases_details, :user_courses_status] do
    ensure_user_is_of_type(%w(admin customer_support_manager))
  end
  before_action only: [:reactivate_account, :reactivate_account_subscription, :reactivation_complete] do
    ensure_user_is_of_type(%w(individual_student admin customer_support_manager))
  end

  before_action :get_variables, only: [:account, :show, :user_personal_details, :user_subscription_status, :user_enrollments_details, :user_purchases_details, :new, :create, :edit, :update, :destroy, :reactivate_account, :reactivate_account_subscription, :reactivation_complete]

  #User account view for all users

  #Admin & CustomerSupport Manager views under dashboard tabs
  def index
    @users = params[:search_term].to_s.blank? ?
             @users = User.sort_by_recent_registration.paginate(per_page: 50, page: params[:page]) :
             @users = User.sort_by_recent_registration.search_for(params[:search_term].to_s).
                     paginate(per_page: 50, page: params[:page])
  end

  def show #(Admin Overview)
    @user = User.find(params[:id])
    @user_sessions_count = @user.login_count
    @enrollments = @user.enrollments.all_in_order
    seo_title_maker("#{@user.full_name} - Details", '', true)
  end

  def user_personal_details
    @user = User.find(params[:user_id])
    render 'users/admin_view/user_personal_details'
  end

  def user_subscription_status
    @user = User.find(params[:user_id])
    @subscription = @user.active_subscription if @user.subscriptions.any?
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
    @default_card = @subscription_payment_cards.all_default_cards.last
    render 'users/admin_view/user_subscription_status'
  end

  def user_enrollments_details
    @user = User.find(params[:user_id])
    @enrollments = @user.enrollments.all_in_admin_order
    render 'users/admin_view/user_enrollments_details'
  end

  def user_purchases_details
    @user = User.find(params[:user_id])
    @orders = @user.orders
    render 'users/admin_view/user_purchases_details'
  end

  def user_courses_status
    #This is for seeing a tutors courses
    @user = User.find(params[:user_id])
    @subject_courses = SubjectCourse.all_active.all_in_order
    all_courses = @subject_courses.each_slice( (@subject_courses.size/2.0).round ).to_a
    @first_courses = all_courses.first
    @second_courses = all_courses.last
    render 'users/admin_view/user_courses_status'
  end

  #Admin & CustomerSupport Manager user actions
  def new
    @user_groups = UserGroup.where(site_admin: false).all_in_order
    @user = User.new
  end

  def edit
  end

  def create
    #Admin creating users
    if Rails.env.production?
      password = SecureRandom.hex(5)
    else
      password = '123123123'
    end
    @user = User.new(allowed_params.merge({password: password,
                                           password_confirmation: password,
                                           password_change_required: true}))

    @user.activate_user
    @user.generate_email_verification_code
    @user.locale = 'en'

    if @user.user_group.try(:site_admin) == false && @user.save
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(
          email: @user.try(:email)
      )
      @user.update_attribute(:stripe_customer_id, stripe_customer.id)
      @user.update_attribute(:free_trial, true) if @user.user_group.try(:individual_student)
      if @user.user_group.try(:individual_student) || @user.user_group.try(:blogger)
        new_referral_code = ReferralCode.new
        new_referral_code.generate_referral_code(@user.id)
      end
      MandrillWorker.perform_async(@user.id, 'admin_invite', user_verification_url(email_verification_code: @user.email_verification_code))
      flash[:success] = I18n.t('controllers.users.create.flash.success')
      redirect_to users_url
    else
      render action: :new
    end
  end

  def update
    if @user.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.users.update.flash.success')
      if current_user.admin? || current_user.customer_support_manager?
        if @user.individual_student? && @user.stripe_customer_id && @user.subscriptions.count == 0
          @user.update_attribute(:free_trial, true)
        end
        redirect_to users_url
      else
        redirect_to account_url
      end
    else
      if current_user.admin? || current_user.customer_support_manager?
        render action: :edit
      else
        session[:user_update_errors] = @user.errors unless @user.errors.empty?
        session[:valid_params] = [@user.first_name, @user.last_name, @user.email, @user.date_of_birth] unless @user.errors.empty?

        redirect_to account_url(anchor: 'personal-details-modal')
      end
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = I18n.t('controllers.users.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.users.destroy.flash.error')
    end
    redirect_to users_url
  end




  #Non-standard actions logged in required

  def update_courses
    @user = User.find(params[:user_id]) rescue nil
    if params[:user]
      @user.subject_course_ids = params[:user][:subject_course_ids]
    else
      @user.subject_course_ids = []
    end

    flash[:success] = I18n.t('controllers.users.update_subjects.flash.success')
    redirect_to users_url
  end


  protected

  def get_variables
    @user = params[:id].to_i > 0 && (current_user.admin? || current_user.customer_support_manager?) ?
                  @user = User.where(id: params[:id]).first :
                  current_user

    @user_groups = UserGroup.where(site_admin: false).all_in_order
    @countries = Country.all_in_order
    seo_title_maker('Account Details', '', true)
    @current_subscription = @user.active_subscription
    @orders = @user.orders
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
  end

  def allowed_params
    if current_user.admin? || current_user.customer_support_manager?
      params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :address, :country_id, :profile_image, :date_of_birth, :description, :student_number)
    else
      params.require(:user).permit(:email, :first_name, :last_name, :address, :employee_guid, :topic_interest, :date_of_birth, :terms_and_conditions, :student_number)
    end
  end


  def sign_in_params
    params.require(:user_session).permit(:email, :password)
  end

end
