# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string(255)
#  first_name                      :string(255)
#  last_name                       :string(255)
#  address                         :text
#  country_id                      :integer
#  crypted_password                :string(128)      default(""), not null
#  password_salt                   :string(128)      default(""), not null
#  persistence_token               :string(255)
#  perishable_token                :string(128)
#  single_access_token             :string(255)
#  login_count                     :integer          default("0")
#  failed_login_count              :integer          default("0")
#  last_request_at                 :datetime
#  current_login_at                :datetime
#  last_login_at                   :datetime
#  current_login_ip                :string(255)
#  last_login_ip                   :string(255)
#  account_activation_code         :string(255)
#  account_activated_at            :datetime
#  active                          :boolean          default("false"), not null
#  user_group_id                   :integer
#  password_reset_requested_at     :datetime
#  password_reset_token            :string(255)
#  password_reset_at               :datetime
#  stripe_customer_id              :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  locale                          :string(255)
#  guid                            :string(255)
#  subscription_plan_category_id   :integer
#  password_change_required        :boolean
#  session_key                     :string
#  name_url                        :string
#  profile_image_file_name         :string
#  profile_image_content_type      :string
#  profile_image_file_size         :integer
#  profile_image_updated_at        :datetime
#  email_verification_code         :string
#  email_verified_at               :datetime
#  email_verified                  :boolean          default("false"), not null
#  stripe_account_balance          :integer          default("0")
#  free_trial                      :boolean          default("false")
#  terms_and_conditions            :boolean          default("false")
#  date_of_birth                   :date
#  description                     :text
#  analytics_guid                  :string
#  student_number                  :string
#  unsubscribed_from_emails        :boolean          default("false")
#  communication_approval          :boolean          default("false")
#  communication_approval_datetime :datetime
#  preferred_exam_body_id          :bigint
#  currency_id                     :bigint
#  tutor_link                      :string
#  video_player                    :integer          default("0"), not null
#  subscriptions_revenue           :decimal(, )      default("0")
#  orders_revenue                  :decimal(, )      default("0")
#  home_page_id                    :integer
#  verify_remembered_at            :datetime
#  onboarding_course_id            :bigint
#

class User < ApplicationRecord
  include LearnSignalModelExtras
  include UserAccessable

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  # Constants

  enum video_player: { vimeo: 0, dacast: 1 }

  LOCALES = %w[en].freeze
  SORT_OPTIONS = %w[created user_group name email].freeze

  attr_accessor :hutk, :hs_form_id, :page_uri, :page_name

  belongs_to :country, optional: true
  belongs_to :currency, optional: true
  belongs_to :preferred_exam_body, class_name: 'ExamBody', optional: true
  belongs_to :onboarding_course, class_name: 'Course', optional: true
  belongs_to :subscription_plan_category, optional: true
  belongs_to :user_group
  belongs_to :home_page, optional: true

  has_one :referral_code, dependent: :destroy
  has_one :referred_signup, dependent: :destroy
  has_one :onboarding_process, dependent: :destroy

  has_many :course_step_logs, dependent: :destroy
  has_many :completed_course_step_logs, lambda {
    where(element_completed: true)
  }, class_name: 'CourseStepLog'
  has_many :incomplete_course_step_logs, lambda {
    where(element_completed: false)
  }, class_name: 'CourseStepLog'
  has_many :course_tutors
  has_many :exam_body_user_details
  has_many :enrollments
  has_many :invoices
  has_many :quiz_attempts
  has_many :orders
  has_many :subscriptions, inverse_of: :user
  has_many :subscription_payment_cards
  has_many :subscriptions_cancelled, class_name: 'Subscription', foreign_key: 'cancelled_by_id', inverse_of: :cancelled_by
  has_many :course_lesson_logs
  has_many :course_section_logs
  has_many :course_logs
  has_many :ahoy_visits, class_name: 'Ahoy::Visit'
  has_many :charges
  has_many :refunds
  has_many :messages
  has_many :ahoy_events, class_name: 'Ahoy::Event'
  has_many :exercises, inverse_of: :user
  has_many :corrections, foreign_key: :corrector_id, class_name: 'Exercise'

  has_attached_file :profile_image, default_url: 'images/missing_image.jpg'

  accepts_nested_attributes_for :exam_body_user_details, reject_if: ->(c) { c[:student_number].blank? }
  accepts_nested_attributes_for :onboarding_process

  # validation
  validates :email, presence: true, length: { within: 5..50 }, uniqueness: { case_sensitive: false }, format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 20 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 30 }
  validates :password, presence: true, length: { minimum: 6, maximum: 255 }, on: :create
  validates :preferred_exam_body_id, presence: true, on: :create, if: :standard_student_user?
  validates :terms_and_conditions, presence: true, on: :create, unless: :password_change_required?
  validates :user_group_id, presence: true
  validates :name_url, presence: true, uniqueness: { case_sensitive: false }, if: :tutor_user?
  validates :tutor_link, presence: true, uniqueness: { case_sensitive: false }, if: :tutor_user?
  validates :password, confirmation: true, on: :create
  validates :password, confirmation: true, unless: proc { |u| u.password.blank? }
  validates :locale, inclusion: { in: LOCALES }
  validates_attachment_content_type :profile_image, content_type: %r{\Aimage\/.*\Z}

  # callbacks
  before_validation { squish_fields(:email, :first_name, :last_name) }
  before_create :add_guid
  before_create :set_additional_user_attributes
  before_create :creating_hubspot_user
  after_create :create_referral_code_record
  after_update :update_stripe_customer
  after_save :update_hub_spot_data
  after_save :create_segment_user
  after_destroy :delete_stripe_customer

  # scopes
  scope :all_in_order,                -> { order(:user_group_id, :last_name, :first_name, :email) }
  scope :sort_by_email,               -> { order(:email) }
  scope :sort_by_name,                -> { order(:last_name, :first_name) }
  scope :sort_by_most_recent,         -> { order(created_at: :desc) }
  scope :sort_by_recent_registration, -> { order(created_at: :desc) }
  scope :this_month,                  -> { where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month) }
  scope :this_week,                   -> { where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week) }
  scope :active_this_week,            -> { where(last_request_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week) }
  scope :with_course_tutors,          -> { joins(:course_tutors) }
  scope :paid_that_month,             ->(date) { joins(:subscriptions).includes(:subscriptions).where('subscriptions.created_at > ? AND subscriptions.created_at < ?', date.beginning_of_month, date.end_of_month).where.not(subscriptions: { state: :pending }) }

  ### class methods
  def self.search(term)
    left_outer_joins(:subscriptions).
      where('email ILIKE :t OR first_name ILIKE :t OR last_name ILIKE :t OR users.stripe_customer_id ILIKE :t ' \
            "OR textcat(first_name, textcat(text(' '), last_name)) ILIKE :t " \
            'OR subscriptions.paypal_subscription_guid ILIKE :t', t: "%#{term}%").
      group(:id)
  end

  def self.all_students
    includes(:user_group).references(:user_groups).where('user_groups.student_user = ?', true)
  end

  def self.all_trial_or_sub_students
    includes(:user_group).references(:user_groups).where('user_groups.student_user = ?', true).where('user_groups.trial_or_sub_required = ?', true)
  end

  def self.all_tutors
    includes(:user_group).references(:user_groups).where('user_groups.tutor = ?', true)
  end

  def self.get_and_verify(email_verification_code, country_id)
    return unless (user = User.find_by(email_verification_code: email_verification_code))

    HubSpot::Contacts.new.batch_create(user.id, { property: 'onboarding_process', value: user.onboarding_state }) unless Rails.env.test?
    user.verify(country_id)
  end

  def self.start_password_reset_process(email)
    return { json: { message: 'Invalid email format.' }, status: :unprocessable_entity } unless email.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)

    user = User.find_by(email: email.to_s)
    return { json: { message: 'No registered user using this email.' }, status: :not_found } if user.nil?

    if user.email_verified.nil?
      status  = :unprocessable_entity
      message = 'User not yet verified, please check your email.'
    elsif !user.password_change_required?
      user.update(password_reset_requested_at: proc { Time.zone.now }.call, password_reset_token: ApplicationController.generate_random_code(20))

      # Send reset password email from Mandrill
      url = UrlHelper.instance.reset_password_url(id: user.password_reset_token, host: LEARNSIGNAL_HOST)
      send_reset_password_email(user, 'password_reset_email', url)

      status  = :ok
      message = "Check your mailbox for further instructions. If you don't receive an email from learnsignal within a couple of minutes, check your spam folder."
    elsif user.password_change_required?
      user.update(password_reset_token: ApplicationController.generate_random_code(20))

      # This is for users that received invite verification emails, clicked on the link which verified their account but they did not enter a PW. Now they are trying to access their account by trying to reset their PW so we send them a link for the set pw form instead of the reset pw form.
      url = UrlHelper.instance.set_password_url(id: user.password_reset_token, host: LEARNSIGNAL_HOST)
      send_reset_password_email(user, 'send_set_password_email', url)

      status  = :ok
      message = "Check your mailbox for further instructions. If you don't receive an email from learnsignal within a couple of minutes, check your spam folder."
    end

    { json: { message: message }, status: status }
  end

  def self.send_reset_password_email(user, template, url)
    Message.create(process_at: Time.zone.now, user_id: user&.id, kind: :account, template: template,
                   template_params: { url: url })
  end

  def self.resend_pw_reset_email(user_id, _)
    return unless (user = User.find(user_id))

    if user.active && user.email_verified && user.password_reset_requested_at &&
       user.password_reset_token && !user.password_change_required?
      Message.create(process_at: Time.zone.now, user_id: user&.id, kind: :account, template: 'password_reset_email', template_params: { url: UrlHelper.instance.reset_password_url(id: user.password_reset_token) })
    end

    user
  end

  def self.finish_password_reset_process(reset_token, new_password, new_password_confirmation)
    if reset_token.to_s.length == 20 && new_password.to_s.length > 5 && new_password_confirmation.to_s.length > 5 && new_password.to_s == new_password_confirmation.to_s
      user = User.where(password_reset_token: reset_token.to_s).first
      if user
        if user.update_attributes(password: new_password.to_s,
                                  password_confirmation: new_password_confirmation.to_s,
                                  password_reset_token: nil,
                                  password_reset_requested_at: nil,
                                  password_reset_at: Time.now,
                                  active: true)
          user # return this
        else
          false
        end
      else
        false
      end
    else
      false # return false
    end
  end

  def self.sort_by(choice)
    return all_in_order unless SORT_OPTIONS.include?(choice)

    case choice
    when 'name', 'email'
      send("sort_by_#{choice}")
    when 'created'
      sort_by_recent_registration
    else # also covers 'user_group'
      all_in_order
    end
  end

  def self.to_csv(options = {}, attributes = %w[first_name last_name email id student_number])
    CSV.generate(options) do |csv|
      csv << attributes

      find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  def self.to_csv_with_enrollments(options = {})
    to_csv(options, %w[first_name last_name email student_number date_of_birth enrolled_courses valid_enrolled_courses])
  end

  def self.to_csv_with_visits(options = {})
    to_csv(options, %w[email id visit_campaigns visit_sources visit_landing_pages])
  end

  def paid_that_month
    subscriptions.last_month.where.not(state: :pending).any?
  end

  def self.parse_csv(csv_content)
    users = []
    csv   = CSV.new(csv_content)

    csv.each do |row|
      exam_body = ExamBody.find_by(name: row[3])
      user = new(email: row[0], first_name: row[1], last_name: row[2], preferred_exam_body: exam_body)
      user.valid?

      users << user
    end

    users
  end

  def self.bulk_create(csv_data, user_group_id, root_url)
    new_users = []
    transaction do
      csv_data.each do |_k, v|
        user = User.find_by(email: v['email'])
        next if user

        CsvImportUserCreationWorker.perform_async(v['email'], v['first_name'], v['last_name'], v['preferred_exam_body_id'], user_group_id, root_url)
        new_users << v['email']
      end
    end

    new_users
  end

  def self.create_csv_user(email, first_name, last_name, preferred_exam_body_id, user_group_id, root_url)
    country = Country.find(78) || Country.find(name: 'United Kingdom').last
    password = SecureRandom.hex(5)
    verification_code = ApplicationController::generate_random_code(20)
    time_now = Proc.new{Time.now}.call
    user_group = UserGroup.find(user_group_id)

    user = User.new(email: email, first_name: first_name, last_name: last_name, preferred_exam_body_id: preferred_exam_body_id)

    user.assign_attributes(password: password, password_confirmation: password,
                           country_id: country.id, password_change_required: true,
                           locale: 'en', account_activated_at: time_now, account_activation_code: nil,
                           active: true, email_verified: false, email_verified_at: nil,
                           email_verification_code: verification_code, free_trial: true,
                           user_group_id: user_group.id)

    return unless user.valid? && user.save

    stripe_customer = Stripe::Customer.create(email: user.email)
    user.update_column(:stripe_customer_id, stripe_customer.id)

    Message.create(process_at: Time.zone.now, user_id: user&.id, kind: :account, template: 'csv_webinar_invite',
                   template_params: { url: UrlHelper.instance.user_verification_url(email_verification_code: user.email_verification_code, host: LEARNSIGNAL_HOST) })
  end

  ### INSTANCE METHODS =========================================================

  def verify(country_id)
    time_now = proc { Time.zone.now }.call
    activate_user(time_now) unless active?
    update(email_verified_at: time_now, email_verified: true, country_id: country_id) unless email_verified
    self
  end

  def can_view_content?(exam_body_id, group_id, course_id = nil)
    valid_access_for_exam_body?(exam_body_id, group_id) ||
      valid_access_for_course?(course_id) ||
      user_group.site_admin || complimentary_user?
  end

  def check_country(ip_address)
    UserCountryWorker.perform_async(id, ip_address)
  end

  def currency_locked?
    subscriptions.where.not(stripe_guid: nil).any? ||
      orders.where.not(stripe_customer_id: nil).any? ||
      subscription_payment_cards.any?
  end

  def name
    [first_name, last_name].join(' ')
  end

  def default_card
    subscription_payment_cards.find_by(is_default_card: true, status: 'card-live')
  end

  def subscriptions_for_exam_body(exam_body_id)
    subscriptions.includes(:subscription_plan).for_exam_body(exam_body_id).all_in_order
  end

  def active_subscriptions_for_exam_body(exam_body_id)
    subscriptions.for_exam_body(exam_body_id).all_active
  end

  def viewable_subscriptions
    last_subscription_per_exam.where.not(state: :pending)
  end

  def active_subscription_for_exam_body?(exam_body_id)
    active_subscriptions_for_exam_body(exam_body_id).any?
  end

  def valid_subscription_for_exam_body?(exam_body_id)
    active_subscriptions_for_exam_body(exam_body_id).all_valid.any?
  end

  def valid_access_for_exam_body?(exam_body_id, group_id = nil)
    valid_subscription_for_exam_body?(exam_body_id) || lifetime_subscriber?(group_id)
  end

  def valid_access_for_course?(course_id)
    program_access?(course_id)
  end

  def valid_subscription?
    subscriptions.all_valid.any?
  end

  def subscription_action_required?
    viewable_subscriptions.map(&:state).include?('pending_3d_secure')
  end

  def actionable_invoice
    invoices.where(payment_attempted: true).where.not(next_payment_attempt_at: nil).last
  end

  def analytics_exam_body_plan_data(user_plans = +'', plans_type = +'', plans_status = +'')
    last_subscription_per_exam.each_with_index do |sub, counter|
      user_plans   << sub.subscription_plan.interval_name + (counter == 1 ? '' : ' - ')
      plans_type   << sub.subscription_plan.exam_body.name + (counter == 1 ? '' : ' - ')
      plans_status << sub.state + (counter == 1 ? '' : ' - ')
    end

    [user_plans, plans_type, plans_status]
  end

  def enrolled_course?(course_id)
    # Returns true if an active enrollment exists for this user/course

    enrollments.all_active.map(&:course_id).include?(course_id)
  end

  def enrolled_in_course?(course_id)
    # Returns true if a non-expired active enrollment exists for this user/course

    enrollments.all_valid.map(&:course_id).include?(course_id)
  end

  def subscriber_type
    if subscriptions.all_valid.any?
      'Subscriber'
    elsif subscriptions.cancelled.any?
      'Cancelled Subscriber'
    else
      'Basic'
    end
  end

  # Orders/Products
  def valid_order_ids
    order_ids = []
    orders.each do |order|
      order_ids << order.id if ['paid'].include?(order.stripe_status)
    end

    order_ids
  end

  def valid_orders?
    valid_order_ids.any?
  end

  def purchased_products
    return unless valid_orders?

    ids         = valid_order_ids
    orders      = Order.where(id: ids)
    product_ids = orders.map(&:product_id)
    products    = Product.where(id: product_ids)
    products
  end

  def purchased_cbe?(cbe_id)
    orders.cbe_by_user(id, cbe_id).any?
  end

  def change_the_password(options)
    if options[:password] == options[:password_confirmation] &&
       options[:password].to_s != '' &&
       valid_password?(options[:current_password].to_s) &&
       options[:current_password].to_s != ''
      update(
        password: options[:password],
        password_confirmation: options[:password_confirmation]
      )
    else
      false
    end
  end

  def send_verification_email(url)
    return if Rails.env.test?

    Message.create(process_at: Time.zone.now, user_id: id, kind: :account, template: 'send_verification_email', template_params: { url: url })
  end

  def create_stripe_customer
    StripeCustomerCreationWorker.perform_async(id)
  end

  def set_analytics(ga_ref)
    update(analytics_guid: ga_ref) if ga_ref
  end

  # Checks for our referral cookie in the users browser and creates a
  # ReferredSignUp associated with this user
  def validate_referral(cookie)
    code, referrer_url = cookie.split(';') if cookie
    if code && (referral_code = ReferralCode.find_by_code(code))
      create_referred_signup(
        referral_code_id: referral_code.id,
        referrer_url: referrer_url
      )
    end
  end

  def activate_user(time_now = nil)
    update(active: true, account_activated_at: (time_now || proc { Time.zone.now }.call),
           account_activation_code: nil)
  end

  def validate_user
    self.email_verified           = true
    self.email_verified_at        = proc { Time.zone.now }.call
    self.email_verification_code = nil
  end

  def generate_email_verification_code
    self.email_verified = false
    self.email_verified_at = nil
    self.email_verification_code = ApplicationController.generate_random_code(20)
  end

  def destroyable?
    course_step_logs.empty? &&
      invoices.empty? &&
      quiz_attempts.empty? &&
      course_lesson_logs.empty? &&
      subscriptions.empty? &&
      subscription_payment_cards.empty? &&
      orders.empty?
  end

  def full_name
    first_name.titleize + ' ' + last_name.gsub('O\'', 'O\' ').gsub('O\' ', 'O\'')
  end

  def get_currency(country)
    return currency if currency_id.present?

    sub_or_order_currency || country.currency
  end

  def sub_or_order_currency
    if (existing_sub = subscriptions.all_stripe.not_pending.first)
      existing_sub.subscription_plan&.currency
    elsif (existing_order = orders.all_stripe.first)
      existing_order.product&.currency
    end
  end

  def enrolled_courses
    course_names = []
    enrollments.each do |enrollment|
      course_names << enrollment.course.name if enrollment.course
    end
    course_names
  end

  def valid_enrolled_courses
    course_names = []
    enrollments.all_valid.each do |enrollment|
      course_names << enrollment.course.name if enrollment.course
    end
    course_names
  end

  def visit_elements(attr)
    ahoy_visits.map { |visit| visit.send(attr) }
  end

  def visit_campaigns
    visit_elements(:utm_campaign)
  end

  def visit_sources
    visit_elements(:utm_source)
  end

  def visit_landing_pages
    visit_elements(:landing_page)
  end

  def valid_enrollments_in_sitting_order
    enrollments.for_active_course.by_sitting_date
  end

  def expired_enrollments_in_sitting_order
    enrollments.for_active_course.by_sitting_date
  end

  def active_enrollments_in_sitting_order
    enrollments.all_active.by_sitting_date
  end

  def next_enrollment
    valid_enrollments_in_sitting_order.first
  end

  def next_exam_date
    next_enrollment.days_until_exam
  end

  def completed_course_step(cme_id)
    cmeuls = completed_course_step_logs.where(course_step_id: cme_id)
    cmeuls.any?
  end

  def started_course_step(cme_id)
    cmeuls = incomplete_course_step_logs.where(course_step_id: cme_id)
    cmeuls.any?
  end

  def current_subscription?
    (subscriptions.map(&:state) & %w[active past_due pending_cancellation]).present?
  end

  def last_subscription
    subscriptions.
      where(state: %i[incomplete active past_due canceled cancelled canceled-pending pending_cancellation]).
      in_reverse_created_order.
      first
  end

  def last_purchased_course
    orders.where(state: %i[complete]).where.not(course_id: nil).order(created_at: :asc).last
  end

  def onboarding_state
    if !onboarding_process
      'Not Started'
    elsif onboarding_process&.active
      'Active'
    elsif !onboarding_process&.active
      'Complete'
    end
  end

  def analytics_onboarding_state
    if !onboarding_process
      'Not Started'
    elsif onboarding_process&.content_remaining?
      'Active'
    elsif !onboarding_process&.content_remaining?
      'Complete'
    end
  end

  def analytics_onboarding_valid
    onboarding_process&.content_remaining?
  end

  def analytics_onboarding_valid?
    if onboarding_process
      analytics_onboarding_state == 'Active'
    else
      # This is to ensure that the first course step analytics events (loaded & started)
      # have onboarding set to true because the OnboardingProcess record does not exist yet
      course_step_logs.none?
    end
  end

  def preferred_group_id
    Group.find_by(exam_body_id: preferred_exam_body_id)
  end

  def total_revenue
    subscriptions_revenue + orders_revenue
  end

  def user_registration_calbacks(form_params)
    self.hutk       = form_params[:hutk]
    self.hs_form_id = form_params[:hs_form_id]
    self.page_uri   = form_params[:page_uri]
    self.page_name  = form_params[:page_name]
  end

  def handle_post_user_creation(url)
    activate_user
    create_stripe_customer

    send_verification_email(url)
  end

  # days since created minus 7
  def verify_remain_days
    remain_days = DAYS_TO_VERIFY_EMAIL - (Date.current - created_at.to_date).to_i

    [remain_days, 0].max
  end

  def show_verify_email_message?
    return false if email_verified

    if verify_remembered_at.nil? || verify_remembered_at != current_login_at
      update(verify_remembered_at: current_login_at)
      true
    else
      false
    end
  end

  private

  def add_guid
    self.guid ||= ApplicationController.generate_random_code(10)
    Rails.logger.debug "DEBUG: User#add_guid - FINISH at #{proc { Time.zone.now }.call.strftime('%H:%M:%S.%L')}"
  end

  def create_referral_code_record
    create_referral_code
  end

  def set_additional_user_attributes
    self.communication_approval_datetime = Time.zone.now if communication_approval
    self.account_activation_code = SecureRandom.hex(10)
    self.email_verification_code = SecureRandom.hex(10)
  end

  def creating_hubspot_user
    return if Rails.env.test?

    data = { first_name: first_name,
             last_name: last_name,
             email: email,
             hutk: hutk,
             page_uri: page_uri,
             page_name: page_name,
             hs_form_id: hs_form_id,
             consent: terms_and_conditions }

    HubSpotFormContactsWorker.perform_async(data)
  end

  def create_segment_user
    return if saved_changes.include?(:last_request_at)

    SegmentService.new.identify_user(self)
  end

  def update_stripe_customer
    return if Rails.env.test? || !saved_change_to_email?

    stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
    stripe_customer.email = email
    stripe_customer.save
  end

  def delete_stripe_customer
    return if Rails.env.test?

    return unless stripe_customer_id

    Stripe::Customer.delete(stripe_customer_id)
  end

  def update_hub_spot_data
    return if saved_changes.include?(:last_request_at) || Rails.env.test?

    HubSpotContactWorker.perform_at(2.minutes, id)
  end

  def last_subscription_per_exam
    ids = subscriptions.where.not(state: :pending).joins(:exam_body).group('exam_bodies.name').maximum(:id).values
    subscriptions.includes(subscription_plan: :exam_body).where(id: ids)
  end
end
