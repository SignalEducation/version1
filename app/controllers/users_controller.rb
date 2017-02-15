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
#  terms_and_conditions             :boolean          default(FALSE)
#  student_user_type_id             :integer
#  discourse_user                   :boolean          default(FALSE)
#  date_of_birth                    :date
#

class UsersController < ApplicationController

  before_action :logged_in_required, except: [:student_new, :student_create, :new_product_user, :create_product_user, :new_session_product, :create_session_product, :profile, :profile_index]
  before_action :logged_out_required, only: [:student_new, :student_create, :new_product_user, :create_product_user, :new_session_product, :create_session_product]
  before_action only: [:destroy, :create] do
    ensure_user_is_of_type(['admin'])
  end
  before_action only: [:index, :new, :edit, :show, :user_personal_details, :user_subscription_status, :user_enrollments_details, :user_purchases_details] do
    ensure_user_is_of_type(['admin', 'customer_support_manager'])
  end

  before_action :get_variables, only: [:account, :show, :user_personal_details, :user_subscription_status, :user_enrollments_details, :user_purchases_details, :edit, :update, :destroy, :new_subscription, :create_subscription, :reactivate_account, :reactivate_account_subscription, :personal_upgrade_complete, :reactivation_complete, :change_plan, :subscription_invoice]

  #User account view for all users
  def account
    #user account info page
    @user.create_referral_code unless @user.referral_code
    @valid_order = @user.orders
    @orders = @user.orders
    @product_orders = @orders.where.not(subject_course_id: nil).all_in_order
    @mock_exam_orders = @orders.where.not(mock_exam_id: nil).all_in_order

    if current_user.corporate_manager? || current_user.corporate_customer?
      @corporate_customer = current_user.corporate_customer
      @footer = false
    else
      @footer = true
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
    render 'users/admin_view/user_enrollments_details'
  end

  def user_purchases_details
    @user = User.find(params[:user_id])
    @orders = @user.orders
    @product_orders = @orders.where.not(subject_course_id: nil).all_in_order
    @mock_exam_orders = @orders.where.not(mock_exam_id: nil).all_in_order
    render 'users/admin_view/user_purchases_details'
  end



  #Admin & CustomerSupport Manager user actions
  def new
    @user = User.new
  end

  def edit
  end

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
      if current_user.admin? || current_user.customer_support_manager?
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

  #Logged Out actions to create account/session for sub account and product accounts
  def student_new
    redirect_to root_url if current_corporate
    @user = User.new
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
    @topic_interests = Group.all_active.all_in_order.for_public
    #To allow displaying of sign_up_errors and valid params since a redirect is used at the end of student_create because it might have to redirect to home_pages controller
    if session[:sign_up_errors] && session[:valid_params]
      session[:sign_up_errors].each do |k, v|
        v.each { |err| @user.errors.add(k, err) }
      end
      @user.first_name = session[:valid_params][0]
      @user.last_name = session[:valid_params][1]
      @user.email = session[:valid_params][2]
      session.delete(:sign_up_errors)
      session.delete(:valid_params)
    end
    @navbar = false
    @footer = false
  end

  def student_create
    if current_user
      redirect_to root_url
    else
      @navbar = false
      @footer = false
      @topic_interests = Group.all_active.all_in_order.for_public

      @user = User.new(student_allowed_params)
      @user.student_user_type_id = StudentUserType.default_free_trial_user_type.try(:id)
      @user.user_group_id = UserGroup.default_student_user_group.try(:id)
      ip_country = IpAddress.get_country(request.remote_ip)
      @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
      @user.country_id = @country.id
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
        @user.create_referral_code
        redirect_to personal_sign_up_complete_url(@user.account_activation_code)
      else
        session[:sign_up_errors] = @user.errors unless @user.errors.empty?
        session[:valid_params] = [@user.first_name, @user.last_name, @user.email] unless @user.errors.empty?
        redirect_to request.referrer
      end
    end
  end

  def new_product_user
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    @user = User.new
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
    @currency_id = @country.currency_id
    @product = @course.products.in_currency(@currency_id).last
    @topic_interests = Group.all_active.all_in_order.for_public
    @navbar = false
    @footer = false
  end

  def create_product_user
    redirect_to root_url if current_user
    @navbar = false
    @footer = false
    @topic_interests = Group.all_active.all_in_order.for_public

    @course = SubjectCourse.find(params[:user][:subject_course_id])
    @product = Product.where(subject_course_id: @course.id).first
    @user = User.new(student_allowed_params)
    @user.user_group_id = UserGroup.default_student_user_group.try(:id)
    @user.student_user_type_id = StudentUserType.default_product_user_type.try(:id)
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
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
      MandrillWorker.perform_async(@user.id, 'send_verification_email', user_verification_url(email_verification_code: @user.email_verification_code))

      user = User.get_and_activate(@user.account_activation_code)
      UserSession.create(user)
      redirect_to users_new_order_url(@course.name_url)
    else
      render action: :new_product_user
    end
  end

  def new_session_product
    @course = SubjectCourse.find_by_name_url(params[:subject_course_name_url])
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @currency_id = @country.currency_id
    @product = @course.products.in_currency(@currency_id).last
    @user_session = UserSession.new
    @navbar = false
    @footer = false
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


  #Logged In actions to create subscriptions and associated objects(invoices, coupons)
  def new_subscription
    redirect_to account_url(anchor: :subscriptions) unless current_user.individual_student?
    @navbar = false
    @user = User.where(id: params[:user_id]).first
    @user.subscriptions.build
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : @user.country
    @currency_id = @country.currency_id


    @subscription_plans = SubscriptionPlan
                              .where('price > 0.0')
                              .includes(:currency)
                              .for_students
                              .in_currency(@currency_id)
                              .generally_available_or_for_category_guid(cookies.encrypted[:latest_subscription_plan_category_guid])
                              .all_active
                              .all_in_order
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

          stripe_subscription = create_on_stripe(stripe_customer, subscription_plan, verified_coupon, subscription_params)

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
            subscription.terms_and_conditions = subscription_params["terms_and_conditions"]
            subscription.stripe_customer_data = stripe_customer.to_hash.deep_dup
            upgrade = subscription.save(validate: false)
          end

          if upgrade
            user.referred_signup.update_attribute(:payed_at, Proc.new{Time.now}.call) if current_user.referred_user

            if user.student_user_type_id == StudentUserType.default_free_trial_user_type.id
              new_user_type_id = StudentUserType.default_sub_user_type.id
            elsif user.student_user_type_id == StudentUserType.default_no_access_user_type.id
              new_user_type_id = StudentUserType.default_sub_user_type.id

            elsif user.student_user_type_id == StudentUserType.default_product_user_type.id
              new_user_type_id = StudentUserType.default_sub_and_product_user_type.id
            else
              new_user_type_id = user.student_user_type_id
            end

            current_user.update_attributes(free_trial: false, student_user_type_id: new_user_type_id)
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

  def create_on_stripe(stripe_customer, subscription_plan, verified_coupon, subscription_params)
    begin
      stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan.stripe_guid, coupon: verified_coupon, trial_end: 'now', source: subscription_params["stripe_token"])
      return stripe_subscription
    rescue Stripe::CardError => e
      # Since it's a decline, Stripe::CardError will be caught
      body = e.json_body
      err  = body[:error]
      puts "Status is: #{e.http_status}"
      puts "Type is: #{err[:type]}"
      puts "Code is: #{err[:code]}"
      # param is '' in this case
      puts "Param is: #{err[:param]}"
      puts "Message is: #{err[:message]}"
    rescue Stripe::RateLimitError => e
      # Too many requests made to the API too quickly
    rescue Stripe::InvalidRequestError => e
      # Invalid parameters were supplied to Stripe's API
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      # (maybe you changed API keys recently)
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send
      # yourself an email
    rescue => e
      # Something else happened, completely unrelated to Stripe
    end
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
      verified_coupon = verify_coupon(coupon_code) if coupon_code
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

  def personal_upgrade_complete
    @subscription = current_user.active_subscription
  end

  def reactivation_complete
    @subscription = current_user.active_subscription
    @subject_course_user_logs = current_user.subject_course_user_logs
    @groups = Group.for_public.all_active.all_in_order
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



  #Non-standard actions logged in required

  def change_password
    @user = current_user
    if @user.change_the_password(change_password_params)
      flash[:success] = I18n.t('controllers.users.change_password.flash.success')
      #Mailers::OperationalMailers::YourPasswordHasChangedWorker.perform_async(@user.id)
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



  #Public facing standard views for tutors (TODO move this footer_pages controller)
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
    @corporate_customers = CorporateCustomer.all_in_order
    @certs = SubjectCourseUserLog.for_user_or_session(@user.try(:id), current_session_guid).where(completed: true)
    @enrollments = Enrollment.where(user_id: @user.try(:id)).all_in_order
    @subscription_payment_cards = SubscriptionPaymentCard.where(user_id: @user.id).all_in_order
  end

  def allowed_params
    if current_user.admin?
      params.require(:user).permit(:email, :first_name, :last_name, :active, :user_group_id, :corporate_customer_id, :address, :country_id, :first_description, :second_description, :wistia_url, :personal_url, :name_url, :qualifications, :profile_image, :date_of_birth, :student_user_type_id)
    else
      params.require(:user).permit(:email, :first_name, :last_name, :address, :country_id, :employee_guid, :first_description, :second_description, :wistia_url, :personal_url, :qualifications, :profile_image, :topic_interest, :subject_course_id, :date_of_birth, :terms_and_conditions)
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
        :topic_interest, :date_of_birth,
        :terms_and_conditions
    )
  end

  def sign_in_params
    params.require(:user_session).permit(:email, :password)
  end

end
