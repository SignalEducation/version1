class StudentUserManagementController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(user_management_access))
  end
  before_action :layout_variables, :get_variables


  def edit
    @user_groups = UserGroup.where(student_user: true).where.not(name: 'Complimentary Users')
  end

  def new
    @student_user = User.new
    @student_user.build_student_access(trial_seconds_limit: ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i, trial_days_limit: ENV['FREE_TRIAL_DAYS'].to_i)
  end

  def create
    password = SecureRandom.hex(5)
    @student_user = User.new(allowed_params.merge({password: password, password_confirmation: password, password_change_required: true}))

    @student_user.activate_user
    @student_user.generate_email_verification_code
    @student_user.locale = 'en'
    @student_user.student_access.account_type = 'Trial'


    if @student_user.save
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(email: @student_user.email)
      @student_user.update_attribute(:stripe_customer_id, stripe_customer.id)

      new_referral_code = ReferralCode.new
      new_referral_code.generate_referral_code(@student_user.id)

      MandrillWorker.perform_async(@student_user.id, 'admin_invite', user_verification_url(email_verification_code: @student_user.email_verification_code))
      flash[:success] = I18n.t('controllers.users.create.flash.success')
      redirect_to users_url
    else
      render action: :new
    end
  end

  def update
    @student_user.assign_attributes(allowed_params)
    if @student_user.save
      @student_user.student_access.recalculate_access_from_limits
      flash[:success] = I18n.t('controllers.users.update.flash.success')
      redirect_to users_url
    else
      flash[:error] = I18n.t('controllers.users.update.flash.error')
      render action: :edit
    end
  end

  def convert_to_student
    @user_groups = UserGroup.where(student_user: true).where.not(name: 'Complimentary Users')
    unless @student_user.student_access
      @student_user.build_student_access(trial_seconds_limit: ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i, trial_days_limit: ENV['FREE_TRIAL_DAYS'].to_i)
    end
  end

  def update_to_student
    @student_user.assign_attributes(allowed_params)
    if @student_user.student_access.subscription_id
      @student_user.student_access.account_type = 'Subscription'
    else
      @student_user.student_access.account_type = 'Trial'
    end

    if @student_user.save
      flash[:success] = I18n.t('controllers.users.update.flash.success')
      redirect_to users_url
    else
      flash[:error] = I18n.t('controllers.users.update.flash.error')
      render action: :edit
    end
  end

  def preview_csv_upload
    if params[:upload] && params[:upload].respond_to?(:read)
      @csv_data, @has_errors = User.parse_csv(params[:upload].read)
    else
      flash[:error] = t('controllers.dashboard.preview_csv.flash.error')
      redirect_to users_url
    end
  end

  def import_csv_upload
    if params[:csvdata]

      @new_users, @existing_users = User.bulk_create(params[:csvdata], root_url)

      flash[:success] = t('controllers.dashboard.import_csv.flash.success')
    else
      flash[:error] = t('controllers.dashboard.import_csv.flash.error')
      redirect_to users_url
    end
  end

  protected

  def allowed_params
    params.require(:user).permit(:email, :first_name, :last_name, :user_group_id, :address, :country_id,
                                 :profile_image, :date_of_birth, :description, :student_number,
                                 student_access_attributes: [:id, :trial_seconds_limit, :trial_days_limit, :account_type])
  end

  def get_variables
    @student_user = User.where(id: params[:id]).first
    @user_groups = UserGroup.all_student
    seo_title_maker('Users Management', '', true)
  end

  def layout_variables
    @layout = 'management'
  end

end