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
#  trial_limit_in_seconds           :integer          default(0)
#  free_trial                       :boolean          default(FALSE)
#  trial_limit_in_days              :integer          default(0)
#  student_number                   :string
#  terms_and_conditions             :boolean          default(FALSE)
#  student_user_type_id             :integer
#

class UsersController < ApplicationController

  before_action :logged_in_required, except: [:student_create, :student_new, :profile, :profile_index, :new_product_user, :create_product_user, :create_session_product, :new_session_product, :enrollment]
  before_action :logged_out_required, only: [:student_create, :student_new, :new_product_user, :create_session_product, :new_session_product]
  before_action except: [:show, :edit, :update, :change_password, :new_subscription, :profile, :profile_index, :subscription_invoice, :personal_upgrade_complete, :change_plan, :reactivate_account, :reactivate_account_subscription, :reactivation_complete, :student_new, :new_product_user, :student_create, :create_subscription, :create_product_user, :create_session_product, :new_session_product, :enrollment] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables, except: [:student_new, :student_create, :profile, :profile_index, :new_product_user, :create_product_user, :create_session_product, :new_session_product]

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
    if current_user.corporate_manager? || current_user.corporate_customer?
      @corporate_customer = current_user.corporate_customer
      @footer = false
    else
      @footer = true
    end
  end

  def new
    @user = User.new
  end

  def student_new
    redirect_to root_url if current_corporate
    @user = User.new
    @user.country_id = IpAddress.get_country(request.remote_ip).try(:id)
    #@user.country_id = 105
    @topic_interests = Group.all_active.all_in_order.for_public
    @navbar = false
    @footer = false
  end

  def student_create
    #Duplicate in HomePages controller
    if current_user
      redirect_to root_url
    else
      @navbar = false
      @footer = false
      @topic_interests = Group.all_active.all_in_order.for_public
      @user = User.new(student_allowed_params)
      @user.student_user_type_id = StudentUserType.default_sub_user_type.try(:id)
      @user.user_group_id = UserGroup.default_student_user_group.try(:id)
      @user.country_id = IpAddress.get_country(request.remote_ip).try(:id) || Country.where(iso_code: 'IE').first.id
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
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(
          email: @user.try(:email)
      )
      @user.stripe_customer_id = stripe_customer.id
      @user.free_trial = true

      if @user.valid? && @user.save
        @subscription_plan = SubscriptionPlan.in_currency(@user.country.currency_id).where(payment_frequency_in_months: 1).where(subscription_plan_category_id: nil).first
        # Send User Activation email through Mandrill
        MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))
        # Checks for our referral cookie in the users browser and creates a ReferredSignUp associated with this user
        if cookies.encrypted[:referral_data]
          code, referrer_url = cookies.encrypted[:referral_data].split(';')
          if code
            referral_code = ReferralCode.find_by_code(code)
            @user.create_referred_signup(referral_code_id: referral_code.id, referrer_url: referrer_url) if referral_code
            cookies.delete(:referral_data)
          end
        end
        @user.assign_anonymous_logs_to_user(current_session_guid)
        user = User.get_and_activate(@user.account_activation_code)
        @user.create_referral_code
        UserSession.create(user)
        redirect_to personal_sign_up_complete_url
      else
        render action: :student_new
      end
    end
  end

  def new_product_user
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    @product = Product.where(subject_course_id: @course.id).first
    @user = User.new
    @user.country_id = IpAddress.get_country(request.remote_ip).try(:id) || 105
    @topic_interests = Group.all_active.all_in_order.for_public
    @navbar = false
    @footer = false
  end

  def new_session_product
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    @product = Product.where(subject_course_id: @course.id).first
    @user_session = UserSession.new
    @navbar = false
    @footer = false
  end

  def create_product_user
    if current_user
      redirect_to root_url
    else
      @course = SubjectCourse.find(params[:user][:subject_course_id])
      @product = Product.where(subject_course_id: @course.id).first
      @navbar = false
      @footer = false
      @topic_interests = Group.all_active.all_in_order.for_public
      @user = User.new(student_allowed_params)
      @user.user_group_id = UserGroup.default_product_student_user_group.try(:id)
      @user.student_user_type_id = StudentUserType.default_product_user_type.try(:id)
      @user.country_id = IpAddress.get_country(request.remote_ip).try(:id) || 105
      @user.account_activation_code = SecureRandom.hex(10)
      @user.email_verification_code = SecureRandom.hex(10)
      @user.password_confirmation = @user.password
      # Check for CrushOffers cookie and assign it to the User
      if cookies.encrypted[:crush_offers]
        @user.crush_offers_session_id = cookies.encrypted[:crush_offers]
        cookies.delete(:crush_offers)
      end
      # Create the customer object on stripe
      stripe_customer = Stripe::Customer.create(
          email: @user.try(:email)
      )
      @user.stripe_customer_id = stripe_customer.id
      @user.free_trial = false
      @user.trial_limit_in_days = 0

      if @user.valid? && @user.save
        #TODO The Email needs to be replaced welcome to Course X at LearnSignal, ACCA Requirements Enroll in Course X email campaign
        MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))

        user = User.get_and_activate(@user.account_activation_code)
        UserSession.create(user)
        redirect_to users_new_order_url(@course.name_url)
      else
        render action: :new_product_user
      end
    end
  end

  def create_session_product
    @navbar = nil
    @footer = nil
    @course = SubjectCourse.find_by_id(params[:user_session][:subject_course_id])
    @product = Product.where(subject_course_id: @course.id).first
    @user_session = UserSession.new(sign_in_params)
    if @user_session.save
      @user_session.user.assign_anonymous_logs_to_user(current_session_guid)
      @user_session.user.update_attribute(:session_key, session[:session_id])
      flash[:error] = nil
      redirect_to users_new_order_url(@course.name_url)
    else
      render action: :new_session_product
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
      if @user.corporate_manager? || @user.corporate_student?
        MandrillWorker.perform_async(@user.id, 'corporate_invite', user_verification_url(email_verification_code: @user.email_verification_code))
      else
        MandrillWorker.perform_async(@user.id, 'admin_invite', user_verification_url(email_verification_code: @user.email_verification_code))
      end
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

  def enrollment
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    if @user.update_attributes(allowed_params)
      redirect_to new_enrollment_url(@course.name_url)
    else
      redirect_to library_special_link(@course.name_url)
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

  def new_subscription
    redirect_to account_url if current_user.subscriptions.any?
    @navbar = false
    @user = User.where(id: params[:user_id]).first
    @user.subscriptions.build
    currency_id = @user.country.currency_id
    @subscription_plans = SubscriptionPlan
                          .where('price > 0.0')
                          .includes(:currency)
                          .for_students
                          .in_currency(currency_id)
                          .generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid])
                          .all_active
                          .all_in_order
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

  def create_subscription
    ####  User creating their first subscription  #####

    # Checks that all necessary params are present, then calls the upgrade_from_free_plan method in the Subscription Model
    if current_user && current_user.individual_student?
      if !current_user.subscriptions.any? &&
         params[:user] && params[:user][:subscriptions_attributes] && params[:user][:subscriptions_attributes]["0"] && params[:user][:subscriptions_attributes]["0"]["subscription_plan_id"] && params[:user][:subscriptions_attributes]["0"]["stripe_token"]
        user = User.find(params[:user_id])
        subscription_params = params[:user][:subscriptions_attributes]["0"]
        subscription_plan = SubscriptionPlan.find(subscription_params["subscription_plan_id"].to_i)
        coupon_code = params[:coupon] unless params[:coupon].empty?
        verified_coupon = verify_coupon(coupon_code) if coupon_code
        if coupon_code && verified_coupon == 'bad_coupon'
          redirect_to user_new_subscription_url(current_user.id)
        else
          stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
          stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan.stripe_guid, coupon: verified_coupon, trial_end: 'now', source: subscription_params["stripe_token"])
          stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
          if stripe_customer && stripe_subscription
            subscription = Subscription.new(
                user_id: user.id,
                subscription_plan_id: subscription_plan.id,
                complimentary: false,
                active: true,
                livemode: stripe_subscription[:plan][:livemode],
                current_status: stripe_subscription.status,
            )
            # mass-assign-protected attributes
            subscription.stripe_guid = stripe_subscription.id
            subscription.next_renewal_date = Time.at(stripe_subscription.current_period_end)
            subscription.stripe_customer_id = stripe_customer.id
            subscription.stripe_customer_data = stripe_customer.to_hash.deep_dup
            upgrade = subscription.save(validate: false)
          end

          if upgrade
            current_user.referred_signup.update_attribute(:payed_at, Proc.new{Time.now}.call) if current_user.referred_user
            current_user.update_user_for_create_sub
            redirect_to personal_upgrade_complete_url
          else
            redirect_to user_new_subscription_url(current_user.id)
            flash[:error] = 'Sorry! Your card was declined. Please check that it is valid.'
          end
        end
      else
        redirect_to user_new_subscription_url(current_user.id)
        #TODO need to add notification here for me
        flash[:error] = 'Sorry! Your request was declined. Please check that all details are valid and try again. Or contact us for assistance.'
      end

    else
      redirect_to account_url
    end
  end

  def reactivate_account
    @user = User.where(id: params[:user_id]).first
    redirect_to root_url unless @user.individual_student?
    @subscription = @user.subscriptions.last
    redirect_to account_url unless @subscription.current_status == 'canceled'
    @valid_card = @user.subscription_payment_cards.all_default_cards.last.check_valid_dates
    currency_id = @subscription.subscription_plan.currency_id
    @country = Country.where(currency_id: currency_id).first
    @subscription_plans = @subscription.reactivation_options
    @new_subscription = Subscription.new
    @navbar = nil
  end

  def reactivate_account_subscription
    redirect_to root_url unless current_user.individual_student?
    ####  User adding a subscription after previously canceling one  #####
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
    @subscription = current_user.active_subscription
  end

  def reactivation_complete
    @subscription = current_user.active_subscription
  end

  def change_plan
    @current_subscription = @user.active_subscription
  end

  def verify_coupon(coupon)
    @user_currency = @user.country.currency
    verified_coupon = Stripe::Coupon.retrieve(coupon)
    unless verified_coupon.valid
      flash[:error] = 'Sorry! The coupon code you entered has expired'
      verified_coupon = 'bad_coupon'
      return verified_coupon
    end
    if verified_coupon.currency && verified_coupon.currency != @user_currency.iso_code.downcase
      flash[:error] = 'Sorry! The coupon code you entered is not in the correct currency'
      verified_coupon = 'bad_coupon'
      return verified_coupon
    end
    return verified_coupon
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
    @countries = Country.all_in_order
    if (action_name == 'show' || action_name == 'edit' || action_name == 'update') && @user.admin?
      @user_groups = UserGroup.all_in_order
    else
      @user_groups = UserGroup.where(site_admin: false).all_in_order
    end
    seo_title_maker('Account Details', '', true)
    @current_subscription = @user.active_subscription
    @valid_order = @user.valid_order?
    @orders = @user.orders
    @corporate_customers = CorporateCustomer.all_in_order
    @certs = SubjectCourseUserLog.for_user_or_session(@user.try(:id), current_session_guid).where(completed: true)
    @enrollments = Enrollment.where(user_id: @user.try(:id))
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
  end

  def allowed_params
    if current_user.admin?
      params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :corporate_customer_id, :address, :country_id, :first_description, :second_description, :wistia_url, :personal_url, :name_url, :qualifications, :profile_image, :student_number)
    else
      params.require(:user).permit(:email, :first_name, :last_name, :address, :country_id, :employee_guid, :first_description, :second_description, :wistia_url, :personal_url, :qualifications, :profile_image, :topic_interest, :subject_course_id, :student_number, :terms_and_conditions)
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
        :topic_interest, :student_number,
        :terms_and_conditions
    )
  end

  def sign_in_params
    params.require(:user_session).permit(:email, :password)
  end

end
