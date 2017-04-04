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
#

class UsersController < ApplicationController

  before_action :logged_in_required
  before_action only: [:destroy, :create] do
    ensure_user_is_of_type(%w(admin))
  end
  before_action only: [:index, :new, :edit, :show, :user_personal_details, :user_subscription_status, :user_enrollments_details, :user_purchases_details] do
    ensure_user_is_of_type(%w(admin customer_support_manager))
  end

  before_action :get_variables, only: [:account, :show, :user_personal_details, :user_subscription_status, :user_enrollments_details, :user_purchases_details, :new, :create, :edit, :update, :destroy, :reactivate_account, :reactivate_account_subscription, :reactivation_complete]

  #User account view for all users
  def account
    #user account info page
    @user.create_referral_code unless @user.referral_code
    @valid_order = @user.orders
    @orders = @user.orders
    @footer = true
    #To allow displaying of sign_up_errors and valid params since a redirect is used at the end of student_create because it might have to redirect to home_pages controller
    if session[:user_update_errors] && session[:valid_params]
      session[:user_update_errors].each do |k, v|
        v.each { |err| @user.errors.add(k, err) }
      end
      @user.first_name = session[:valid_params][0]
      @user.last_name = session[:valid_params][1]
      @user.email = session[:valid_params][2]
      @user.date_of_birth = session[:valid_params][3]
      session.delete(:user_update_errors)
      session.delete(:valid_params)
    end
  end

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
    @enrollments = @user.enrollments
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
    @enrollments = Enrollment.where(user_id: @user.try(:id)).all_in_order
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

      if @user.user_group.try(:individual_student) || @user.user_group.try(:blogger)
        new_referral_code = ReferralCode.new
        new_referral_code.generate_referral_code(@user.id)
      end
      MandrillWorker.perform_async(@user.id, 'admin_invite', user_verification_url(email_verification_code: @user.email_verification_code))
      #@user.create_on_discourse
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

  def reactivate_account
    @user = User.where(id: params[:user_id]).first
    @subscription = @user.active_subscription || @user.subscriptions.last
    redirect_to root_url unless @user.individual_student? && @subscription
    redirect_to account_url(anchor: :subscriptions) unless @subscription.current_status == 'canceled'
    currency_id = @subscription.subscription_plan.currency_id
    @country = Country.where(currency_id: currency_id).first
    @subscription_plans = @subscription.reactivation_options
    @new_subscription = Subscription.new
    @navbar = nil
  end

  def reactivate_account_subscription
    redirect_to root_url unless current_user.individual_student?
    ####  User adding a subscription after previously canceling one  #####
    if params[:subscription] && params[:subscription]["subscription_plan_id"] && params[:subscription]["stripe_token"] && params[:subscription]["terms_and_conditions"]
      coupon_code = params[:coupon] unless params[:coupon].empty?
      verified_coupon = verify_coupon(coupon_code, current_user.country.currency_id) if coupon_code
      if coupon_code && verified_coupon == 'bad_coupon'
        redirect_to user_reactivate_account_url(current_user.id)
      else
        #Save Sub in our DB, create sub on stripe, with coupon option and send card to stripe an save in our DB
        @user.resubscribe_account(params[:subscription]["user_id"], params[:subscription]["subscription_plan_id"].to_i, params[:subscription]["stripe_token"], params[:subscription]["terms_and_conditions"], coupon_code)
        redirect_to reactivation_complete_url
      end
    else
      redirect_to account_url
    end
  end

  def reactivation_complete
    @subscription = current_user.active_subscription
    @subject_course_user_logs = current_user.subject_course_user_logs
    @groups = Group.all_active.all_in_order
  end

  def subscription_invoice
    invoice = Invoice.where(id: params[:id]).first
    if invoice
      @invoice = invoice
      description = t("views.general.subscription_in_months.a#{@invoice.subscription.subscription_plan.payment_frequency_in_months}")
      if @invoice.vat_rate
        vat_rate = @invoice.vat_rate.percentage_rate.to_s + '%'
      else
        vat_rate = '0%'
      end
      respond_to do |format|
        format.html
        format.pdf do
          pdf = InvoiceDocument.new(@invoice, view_context, description, vat_rate)
          send_data pdf.render, filename: "invoice_#{@invoice.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf", disposition: "inline"
        end
      end
    end
  end



  #Non-standard actions logged in required

  def change_password
    @user = current_user
    if @user.change_the_password(change_password_params)
      flash[:success] = I18n.t('controllers.users.change_password.flash.success')
    else
      flash[:error] = I18n.t('controllers.users.change_password.flash.error')
    end
    if current_user.admin? || current_user.customer_support_manager?
      redirect_to users_url
    else
      redirect_to account_url
    end
  end

  def create_discourse_user
    @user = current_user
    @user.create_on_discourse
    flash[:success] = "An activation email has just been sent to #{@user.email}. Please follow its instructions to access the Community"
    redirect_to account_url
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

  def get_variables
    @user = params[:id].to_i > 0 && (current_user.admin? || current_user.customer_support_manager?) ?
                  @user = User.where(id: params[:id]).first :
                  current_user

    @user_groups = UserGroup.where(site_admin: false).all_in_order
    @countries = Country.all_in_order
    seo_title_maker('Account Details', '', true)
    @current_subscription = @user.active_subscription
    @orders = @user.orders
    @certs = SubjectCourseUserLog.for_user_or_session(@user.try(:id), current_session_guid).where(completed: true)
    @enrollments = Enrollment.where(user_id: @user.try(:id)).all_in_order
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
  end

  def allowed_params
    if current_user.admin?
      params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :address, :country_id, :profile_image, :date_of_birth, :description)
    else
      params.require(:user).permit(:email, :first_name, :last_name, :address, :employee_guid, :topic_interest, :date_of_birth, :terms_and_conditions)
    end
  end

  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def sign_in_params
    params.require(:user_session).permit(:email, :password)
  end

end
