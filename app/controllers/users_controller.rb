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
  before_action do
    ensure_user_has_access_rights(%w(user_management_access))
  end
  before_action :layout_variables
  before_action :get_variables, except: [:user_personal_details, :user_subscription_status, :user_enrollments_details, :user_purchases_details, :user_courses_status]
  before_action :get_user_variables, only: [:user_personal_details, :user_subscription_status, :user_enrollments_details, :user_purchases_details, :user_courses_status]


  def index
    if params[:search_term].to_s.blank?
      @users = @users = User.sort_by_most_recent.paginate(per_page: 50, page: params[:page])
    else
      @users = User.sort_by_most_recent.search_for(params[:search_term].to_s).paginate(per_page: 50, page: params[:page])
    end
  end

  def show
    @user_sessions_count = @user.login_count
    @enrollments = @user.enrollments.all_in_order
    seo_title_maker("#{@user.full_name} - Details", '', true)
  end

  def edit
  end

  def new
    @user = User.new
  end

  def create
    password = SecureRandom.hex(5)
    @user = User.new(allowed_params.merge({password: password,
                                           password_confirmation: password,
                                           password_change_required: true}))

    @user.activate_user
    @user.generate_email_verification_code
    @user.locale = 'en'

    if @user.save
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(email: @user.email)
      @user.update_attribute(:stripe_customer_id, stripe_customer.id)

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
      redirect_to users_url
    else
      flash[:error] = I18n.t('controllers.users.update.flash.error')
      render action: :edit
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

  def user_personal_details
  end

  def user_subscription_status
    @subscription = @user.current_subscription if @user.subscriptions.any?
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
    @default_card = @subscription_payment_cards.all_default_cards.last
  end

  def user_enrollments_details
    @enrollments = @user.enrollments.all_in_admin_order
  end

  def user_purchases_details
    @orders = @user.orders
  end

  def user_courses_status
    #This is for seeing a tutors courses
    @subject_courses = SubjectCourse.all_active.all_in_order
    all_courses = @subject_courses.each_slice( (@subject_courses.size/2.0).round ).to_a
    @first_courses = all_courses.first
    @second_courses = all_courses.last
  end

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

  def allowed_params
    params.require(:user).permit(:email, :first_name, :last_name, :user_group_id, :address, :country_id, :profile_image, :date_of_birth, :description, :student_number)
  end


  def get_variables
    @user = User.where(id: params[:id]).first
    @user_groups = UserGroup.all_not_student
    @countries = Country.all_in_order
    seo_title_maker('Users Management', '', true)
  end

  def layout_variables
    @layout = 'management'
  end

  def get_user_variables
    @user = User.where(id: params[:user_id]).first
    seo_title_maker("#{@user.full_name} - Details", '', true)
  end

end
