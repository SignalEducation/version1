# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :logged_in_required
  before_action(except: :update_hubspot) { ensure_user_has_access_rights(%w[user_management_access]) }
  before_action :management_layout
  before_action :get_variables, except: %i[user_personal_details user_subscription_status
                                           user_activity_details user_purchases_details
                                           user_courses_status user_referral_details
                                           preview_csv_upload user_messages_details]
  before_action :get_user_variables, only: %i[user_personal_details user_subscription_status
                                              user_activity_details user_purchases_details
                                              user_courses_status user_referral_details user_messages_details]
  skip_before_action :verify_authenticity_token, only: :update_hubspot

  def index
    @users = User.includes(:preferred_exam_body).
               page(params[:page]).
               search(params[:search_term]).
               sort_by_most_recent
  end

  def show
    @user_sessions_count        = @user.login_count
    @enrollments                = @user.enrollments.all_in_order
    @subscriptions              = @user.subscriptions
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
    @default_card               = @subscription_payment_cards.all_default_cards.last
    @invoices                   = @user.invoices

    seo_title_maker("#{@user.full_name} - Details", '', true)
  end

  def edit; end

  def new
    @user = User.new
  end

  def create
    password = SecureRandom.hex(5)
    @user    = User.new(allowed_params.merge(password: password,
                                             password_confirmation: password,
                                             password_change_required: true))

    @user.activate_user
    @user.generate_email_verification_code
    @user.locale = 'en'

    if @user.save
      @user.create_stripe_customer
      @user.activate_user

      Message.create(
        process_at: Time.zone.now,
        user_id: @user.id,
        kind: :account,
        template: 'admin_invite',
        template_params: {
          url: user_verification_url(email_verification_code: @user.email_verification_code)
        }
      )
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

  def search
    @users = User.includes(:preferred_exam_body).
               search(params[:search_term]).
               page(params[:page]).
               sort_by_most_recent

    respond_to do |format|
      format.js
    end
  end

  def preview_csv_upload
    @user_groups = UserGroup.all_in_order

    if params[:upload]&.respond_to?(:read)
      @users      = User.parse_csv(params[:upload].read)
      @has_errors = csv_parsed_errors?(@users)
    else
      flash[:error] = t('controllers.dashboard.preview_csv.flash.error')
      redirect_to users_url
    end
  end

  def import_csv_upload
    if params[:csvdata].present? && params[:user_group_id].present?
      @new_users = User.bulk_create(params[:csvdata], params[:user_group_id], root_url)
      flash[:success] = t('controllers.dashboard.import_csv.flash.success')
    else
      flash[:error] = t('controllers.dashboard.import_csv.flash.error')
      redirect_to users_url
    end
  end

  def user_personal_details; end

  def user_subscription_status
    @subscriptions              = @user.subscriptions.in_reverse_created_order
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
    @default_card               = @subscription_payment_cards.all_default_cards.last
    @invoices                   = @user.invoices.subscriptions.all_in_order
  end

  def user_activity_details
    @sculs = @user.course_logs
  end

  def course_log_details
    @scul         = CourseLog.find(params[:scul_id])
    @latest_cmeul = @scul.course_step_logs.includes(:course_step).order(:created_at).first
  end

  def user_purchases_details
    @orders   = @user.orders
    @invoices = @user.invoices.orders.all_in_order
  end

  def user_referral_details
    @referral_code = @user.referral_code
  end

  def user_messages_details
    @messages = @user.messages
  end

  def user_courses_status
    # This is for seeing a tutors courses
    @courses = Course.all_active.all_in_order
    all_courses      = @courses.each_slice((@courses.size / 2.0).round).to_a
    @first_courses   = all_courses.first
    @second_courses  = all_courses.last
  end

  def update_courses
    @user = User.find(params[:user_id]) rescue nil
    @user.course_ids = params[:user] ? params[:user][:course_ids] : []

    flash[:success] = I18n.t('controllers.users.update_subjects.flash.success')
    redirect_to users_url
  end

  def update_hubspot
    course = Course.find(params[:custom_data][:course_id])
    user = User.find(params[:user_id])
    return if Rails.env.test? || !course && !user

    user.update_attribute(:onboarding_course, course)
    response =
      HubSpot::Contacts.new.batch_create(
        Array(params[:user_id]),
        format_hubspot_properties(params[:custom_data]).first
      )

    render json: { message: response.body }, status: response.code.to_i
  end

  protected

  def allowed_params
    params.require(:user).permit(:email, :first_name, :last_name, :user_group_id, :address, :country_id,
                                 :profile_image, :date_of_birth, :description, :student_number, :name_url,
                                 :tutor_link, :stripe_account_balance, :preferred_exam_body_id, :currency_id,
                                 :video_player, onboarding_process_attributes: [:id, :active])
  end

  def get_variables
    @user        = User.find_by(id: params[:id])
    @user_groups = UserGroup.all_not_admin
    @countries   = Country.all_in_order

    seo_title_maker('Users Management', '', true)
  end

  def get_user_variables
    @user = User.find_by(id: params[:user_id])

    seo_title_maker("#{@user.full_name} - Details", '', true)
  end

  def format_hubspot_properties(data)
    data&.to_unsafe_h&.map { |k, v| { property: k, value: v } }
  end

  def csv_parsed_errors?(users)
    users.map { |u| u.errors.keys }.flatten.uniq.
      any? { |e| %i[email first_names last_name].include?(e) }
  end
end
