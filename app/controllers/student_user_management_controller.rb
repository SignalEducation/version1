class StudentUserManagementController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(user_management_access))
  end
  before_action :layout_variables


  def edit
  end

  def new
    @user = User.new
    @user.build_student_access
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

      new_referral_code = ReferralCode.new
      new_referral_code.generate_referral_code(@user.id)

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
      redirect_to user_management_index_url
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
    @layout = 'management'
  end

end