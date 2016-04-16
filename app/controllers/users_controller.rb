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
#  corporate_customer_id            :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  locale                           :string
#  guid                             :string
#  trial_ended_notification_sent_at :datetime
#  crush_offers_session_id          :string
#  subscription_plan_category_id    :integer
#  employee_guid                    :string
#  password_change_required         :boolean
#  session_key                      :string
#  first_description                :text
#  second_description               :text
#  wistia_url                       :text
#  personal_url                     :text
#  name_url                         :string
#  qualifications                   :text
#  profile_image_file_name          :string
#  profile_image_content_type       :string
#  profile_image_file_size          :integer
#  profile_image_updated_at         :datetime
#  phone_number                     :string
#  topic_interest                   :string
#  email_verification_code          :string
#  email_verified_at                :datetime
#  email_verified                   :boolean          default(FALSE), not null
#  stripe_account_balance           :integer          default(0)
#

class UsersController < ApplicationController

  before_action :logged_in_required, except: [:create_account, :new, :profile, :profile_index]
  before_action :logged_out_required, only: [:create_account, :new]
  before_action except: [:show, :edit, :new, :update, :change_password, :new_paid_subscription, :upgrade_from_free_trial, :profile, :profile_index, :subscription_invoice, :personal_upgrade_complete, :change_plan, :reactivate_account, :reactivate_account_subscription, :reactivation_complete, :create_account] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables, except: [:create_account, :new, :profile, :profile_index]

  def index
    @users = params[:search_term].to_s.blank? ?
             @users = User.paginate(per_page: 50, page: params[:page]) :
             @users = User.search_for(params[:search_term].to_s).
                     paginate(per_page: 50, page: params[:page])
    @users = params[:sort_by].to_s.blank? ?
             @users.all_in_order :
             @users = @users.sort_by(params[:sort_by].to_s)
    @sort_choices = User::SORT_OPTIONS.map { |x| [x.humanize.camelcase, x] }
  end

  def show
    # account page
    if @user.referral_code.nil?
      @user.create_referral_code
    end

    if params[:update].to_s.length > 0
      case params[:update]
        when 'invoices'
          Invoice.get_updates_for_user(@user.stripe_customer_id)
        when 'cards'
          SubscriptionPaymentCard.get_updates_for_user(@user.stripe_customer_id)
        when 'subscriptions'
          Rails.logger.debug 'DEBUG: start a call to Subscription#get_updates_for_user'
          Subscription.get_updates_for_user(@user.stripe_customer_id)
        else
          # do nothing
      end
      @user.reload
    end
    if current_user.corporate_customer?
      @corporate_customer = current_user.corporate_customer
    end

  end

  def new
    @user = User.new
    @user.country_id = IpAddress.get_country(request.remote_ip).try(:id)
    @topic_interests = @topic_interests = Group.all_active.all_in_order.for_public
  end

  def create_account
    if current_user
      redirect_to dashboard_url
    else
      currency = IpAddress.get_country(request.remote_ip).try(:currency_id) || Currency.where(iso_code: 'USD').first
      subscription_plan = SubscriptionPlan.in_currency(currency).where(price: 0.0).last
      if subscription_plan
        @user = User.new(student_allowed_params.merge({"subscriptions_attributes" => { "0" => { "subscription_plan_id" =>  subscription_plan.id } }}))
        @user.user_group_id = UserGroup.default_student_user_group.try(:id)
        @user.country_id = IpAddress.get_country(request.remote_ip).try(:id)
        @user.account_activation_code = SecureRandom.hex(10)
        @user.email_verification_code = SecureRandom.hex(10)
        @user.password_confirmation = @user.password
        # Check for CrushOffers cookie and assign it to the User
        if cookies.encrypted[:crush_offers]
          @user.crush_offers_session_id = cookies.encrypted[:crush_offers]
          cookies.delete(:crush_offers)
        end
        # Checks for SubscriptionPlanCategory cookie to see if the user should get specific subscription plans instead of the general plans
        if cookies.encrypted[:latest_subscription_plan_category_guid]
          subscription_plan_category = SubscriptionPlanCategory.where(guid: cookies.encrypted[:latest_subscription_plan_category_guid]).first
          @user.subscription_plan_category_id = subscription_plan_category.try(:id)
        end
        if @user.valid? && @user.save
          # Send User Activation email through Intercom
          IntercomVerificationMessageWorker.perform_at(1.minute.from_now, @user.id, user_verification_url(email_verification_code: @user.email_verification_code)) unless Rails.env.test?
          # Checks for our referral cookie in the users browser and creates a ReferredSignUp associated with this user
          if cookies.encrypted[:referral_data]
            code, referrer_url = cookies.encrypted[:referral_data].split(';')
            if code
              referral_code = ReferralCode.find_by_code(code)
              @user.create_referred_signup(referral_code_id: referral_code.id, subscription_id: @user.subscriptions.first.id, referrer_url: referrer_url) if referral_code
              cookies.delete(:referral_data)
            end
          end
          @user.assign_anonymous_logs_to_user(current_session_guid)
          user = User.get_and_activate(@user.account_activation_code)
          @user.create_referral_code
          UserSession.create(user)
          redirect_to personal_sign_up_complete_url
        else
          render action: :new
        end
      else
        render action: :new
      end
    end
  end

  def edit
  end

  # Admins new tutors, content managers or admins
  def create
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
      if @user.user_group.try(:individual_student) || @user.user_group.try(:blogger)
        new_referral_code = ReferralCode.new
        new_referral_code.generate_referral_code(@user.id)
      end
      #Send create user event to intercom
      IntercomCreateUserWorker.perform_async(@user.id) unless Rails.env.test?
      #Send invite email to user from intercom, delayed for 1 minute to ensure the intercom create user event has finished
      IntercomUserInviteEmailWorker.perform_at(1.minute.from_now, @user.email, user_verification_url(email_verification_code: @user.email_verification_code)) unless Rails.env.test?
      flash[:success] = I18n.t('controllers.users.create.flash.success')
      redirect_to users_url
    else
      render action: :new
    end
  end

  def update
    if @user.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.users.update.flash.success')
      if current_user.admin?
        redirect_to users_url
      else
        redirect_to account_url
      end
    else
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

  # non-standard methods

  def change_password
    @user = current_user
    if @user.change_the_password(change_password_params)
      flash[:success] = I18n.t('controllers.users.change_password.flash.success')
      #Mailers::OperationalMailers::YourPasswordHasChangedWorker.perform_async(@user.id)
    else
      flash[:error] = I18n.t('controllers.users.change_password.flash.error')
    end
    if current_user.admin?
      redirect_to users_url
    else
      redirect_to account_url
    end
  end

  def new_paid_subscription
    redirect_to account_url if current_user.subscriptions.count > 1
    @user = User.where(id: params[:user_id]).first
    currency_id = @user.subscriptions.first.subscription_plan.currency_id
    @country = Country.where(currency_id: currency_id).first
    if @user.subscriptions.first.subscription_plan == SubscriptionPlan.where(id: 51).first
      @subscription_plans = SubscriptionPlan
                                .where('price > 0.0')
                                .for_students
                                .in_currency(1)
                                .generally_available
                                .all_active
                                .all_in_order
    else
      @subscription_plans = SubscriptionPlan
                            .where('price > 0.0')
                            .includes(:currency)
                            .for_students
                            .in_currency(@user.subscriptions.first.subscription_plan.currency_id)
                            .generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid])
                            .all_active
                            .all_in_order
    end
  end

  def profile
    #/profile/id
    @tutor = User.all_tutors.where(id: params[:id]).first
    if @tutor
      @courses = SubjectCourse.where(tutor_id: @tutor.id)
      seo_title_maker(@tutor.full_name, @tutor.first_description, nil)
    else
      redirect_to root_url
    end
  end

  def profile_index
    #/profiles
    @tutors = User.all_tutors.where.not(profile_image_file_name: nil)
    seo_title_maker('Our Lecturers', 'Learn from industry experts that create LearnSignal’s online courses.', nil)
  end

  def upgrade_from_free_trial
    # Checks that all necessary params are present, then calls the upgrade_from_free_plan method in the Subscription Model
    if current_user.subscriptions.count == 1 && current_user.subscriptions[0].free_trial? &&
       params[:user] && params[:user][:subscriptions_attributes] && params[:user][:subscriptions_attributes]["0"] && params[:user][:subscriptions_attributes]["0"]["subscription_plan_id"] && params[:user][:subscriptions_attributes]["0"]["stripe_token"]
      subscription_params = params[:user][:subscriptions_attributes]["0"]
      current_subscription = current_user.subscriptions[0]
      coupon_code = params[:coupon] unless params[:coupon].empty?
      verified_coupon = verify_coupon(coupon_code) if coupon_code
      if coupon_code && verified_coupon == 'bad_coupon'
        redirect_to user_new_paid_subscription_url(current_user.id)
      else
        current_subscription.upgrade_from_free_plan(subscription_params["subscription_plan_id"].to_i, subscription_params["stripe_token"], coupon_code)
        current_user.referred_signup.update_attribute(:payed_at, Proc.new{Time.now}.call) if current_user.referred_user
        redirect_to personal_upgrade_complete_url
      end
    else
      redirect_to account_url
    end
  end

  def reactivate_account
    @user = User.where(id: params[:user_id]).first
    @subscription = @user.subscriptions.last
    redirect_to account_url unless @subscription.current_status == 'canceled'
    @valid_card = @user.subscription_payment_cards.all_default_cards.last.check_valid_dates
    currency_id = @subscription.subscription_plan.currency_id
    @country = Country.where(currency_id: currency_id).first
    @subscription_plans = @subscription.reactivation_options
    @new_subscription = Subscription.new
  end

  def reactivate_account_subscription
    if params[:subscription] && params[:subscription]["subscription_plan_id"] && params[:subscription]["stripe_token"]
      coupon_code = params[:coupon] unless params[:coupon].empty?
      verified_coupon = verify_coupon(coupon_code) if coupon_code
      if coupon_code && verified_coupon == 'bad_coupon'
        redirect_to user_reactivate_account_url(current_user.id)
      else
        #Save Sub in our DB, create sub on stripe, with coupon option and send card to stripe an save in our DB
        @user.resubscribe_account(params[:subscription]["user_id"], params[:subscription]["subscription_plan_id"].to_i, params[:subscription]["stripe_token"], coupon_code)
        redirect_to reactivation_complete_url
      end
    elsif params[:subscription] && params[:subscription]["subscription_plan_id"] && !params[:subscription]["stripe_token"]
      @user.resubscribe_account_without_token(params[:subscription]["user_id"], params[:subscription]["subscription_plan_id"].to_i)
      redirect_to reactivation_complete_url
    else
      redirect_to account_url
    end
  end

  def personal_upgrade_complete
    @subscription = current_user.subscriptions.all_of_status('active').last
  end

  def reactivation_complete
    @subscription = current_user.subscriptions.all_of_status('active').last
  end

  def change_plan
    @current_subscription = @user.subscriptions.all_in_order.last
  end

  def verify_coupon(coupon)
    @user_sub_currency_code = @current_subscription.subscription_plan.currency.iso_code
    verified_coupon = Stripe::Coupon.retrieve(coupon)
    unless verified_coupon.valid
      flash[:error] = 'Sorry! The coupon code you entered has expired'
      verified_coupon = 'bad_coupon'
      return verified_coupon
    end
    if verified_coupon.currency && verified_coupon.currency != @user_sub_currency_code.downcase
      flash[:error] = 'Sorry! The coupon code you entered is not in the correct currency'
      verified_coupon = 'bad_coupon'
      return verified_coupon
    end
  rescue => e
    flash[:error] = 'The coupon code entered is not valid'
    verified_coupon = 'bad_coupon'
    Rails.logger.error("ERROR: UsersController#verify_coupon - failed to apply Stripe Coupon.  Details: #{e.inspect}")
    return verified_coupon
  end

  def subscription_invoice
    invoice = Invoice.where(id: params[:id]).first
    Payday::Config.default.invoice_logo = "#{Rails.root}/app/assets/images/invoice-logo.svg"
    Payday::Config.default.company_name = "LearnSignal"
    Payday::Config.default.company_details = "27 South Frederick Street, Dublin 2, Ireland"

    if current_user.id == invoice.user_id
      @invoice = invoice
      respond_to do |format|
        format.html
        format.pdf do
          user = @invoice.user
          Payday::Config.default.currency = "#{@invoice.currency.iso_code.downcase}"
          sub_plan = @invoice.subscription.subscription_plan
          pdf = Payday::Invoice.new(invoice_number: @invoice.id, bill_to: "#{user.full_name}")
          pdf.line_items << Payday::LineItem.new(price: @invoice.total, quantity: 1, description: t("views.general.subscription_in_months.a#{sub_plan.payment_frequency_in_months}"))
          send_data pdf.render_pdf, filename: "invoice_#{@invoice.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf", disposition: 'inline'
        end
      end
    else
      redirect_to account_url
    end
  end


  protected

  def get_variables
    @user = params[:id].to_i > 0 && current_user.admin? ?
                  @user = User.where(id: params[:id]).first :
                  current_user
    @email_frequencies = User::EMAIL_FREQUENCIES
    @countries = Country.all_in_order
    if (action_name == 'show' || action_name == 'edit' || action_name == 'update') && @user.admin?
      @user_groups = UserGroup.all_in_order
    else
      @user_groups = UserGroup.where(site_admin: false).all_in_order
    end
    seo_title_maker(@user.try(:full_name), '', true)
    @current_subscription = @user.subscriptions.all_in_order.last
    @corporate_customers = CorporateCustomer.all_in_order
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
  end

  def allowed_params
    if current_user.admin?
      params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :corporate_customer_id, :address, :country_id, :first_description, :second_description, :wistia_url, :personal_url, :name_url, :qualifications, :profile_image)
    else
      params.require(:user).permit(:email, :first_name, :last_name, :address, :country_id, :employee_guid, :first_description, :second_description, :wistia_url, :personal_url, :qualifications, :profile_image, :topic_interest)
    end
  end

  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def student_allowed_params
    params.require(:user).permit(
        :email, :first_name, :last_name,
        :country_id, :locale,
        :password, :password_confirmation,
        :topic_interest
    )
  end

end
