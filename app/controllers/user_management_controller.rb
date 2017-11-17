class UserManagementController < ApplicationController


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
    #Admin creating users
    password = SecureRandom.hex(5)
    @user = User.new(allowed_params.merge({password: password,
                                           password_confirmation: password,
                                           password_change_required: true}))

    @user.activate_user
    @user.generate_email_verification_code
    @user.locale = 'en'

    if @user.save
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(
          email: @user.try(:email)
      )
      @user.update_attribute(:stripe_customer_id, stripe_customer.id)
      @user.update_attribute(:free_trial, true) if @user.trial_or_sub_user?
      if @user.trial_or_sub_user?
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
    else
      flash[:error] = I18n.t('controllers.users.update.flash.error')
      render action: :edit
    end
    redirect_to user_management_url(@user)
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
    @subscription = @user.active_subscription if @user.subscriptions.any?
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

  def preview_csv_upload
    if params[:upload] && params[:upload].respond_to?(:read)
      @csv_data, @has_errors = User.parse_csv(params[:upload].read)
    else
      flash[:error] = t('controllers.dashboard.preview_csv.flash.error')
      redirect_to admin_dashboard_url
    end
  end

  def import_csv_upload
    if params[:csvdata]

      @new_users, @existing_users = User.bulk_create(params[:csvdata], root_url)

      flash[:success] = t('controllers.dashboard.import_csv.flash.success')
    else
      flash[:error] = t('controllers.dashboard.import_csv.flash.error')
      redirect_to admin_dashboard_url
    end
  end


  protected

  def allowed_params
    params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :address, :country_id, :profile_image, :date_of_birth, :description, :student_number)
  end


  def get_variables
    @user = User.where(id: params[:id]).first
    @user_groups = UserGroup.all_in_order
    @countries = Country.all_in_order
    seo_title_maker('Users Management', '', true)
  end

  def layout_variables
    @navbar = false
    @footer = false
    @top_margin = false
  end

  def get_user_variables
    @user = User.where(id: params[:user_management_id]).first
    seo_title_maker("#{@user.full_name} - Details", '', true)
  end

end