# == Schema Information
#
# Table name: users
#
#  id                              :integer          not null, primary key
#  email                           :string
#  first_name                      :string
#  last_name                       :string
#  address                         :text
#  country_id                      :integer
#  crypted_password                :string(128)      default(""), not null
#  password_salt                   :string(128)      default(""), not null
#  persistence_token               :string
#  perishable_token                :string(128)
#  single_access_token             :string
#  login_count                     :integer          default(0)
#  failed_login_count              :integer          default(0)
#  last_request_at                 :datetime
#  current_login_at                :datetime
#  last_login_at                   :datetime
#  current_login_ip                :string
#  last_login_ip                   :string
#  account_activation_code         :string
#  account_activated_at            :datetime
#  active                          :boolean          default(FALSE), not null
#  user_group_id                   :integer
#  password_reset_requested_at     :datetime
#  password_reset_token            :string
#  password_reset_at               :datetime
#  stripe_customer_id              :string
#  created_at                      :datetime
#  updated_at                      :datetime
#  locale                          :string
#  guid                            :string
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
#  email_verified                  :boolean          default(FALSE), not null
#  stripe_account_balance          :integer          default(0)
#  free_trial                      :boolean          default(FALSE)
#  terms_and_conditions            :boolean          default(FALSE)
#  date_of_birth                   :date
#  description                     :text
#  analytics_guid                  :string
#  student_number                  :string
#  unsubscribed_from_emails        :boolean          default(FALSE)
#  communication_approval          :boolean          default(FALSE)
#  communication_approval_datetime :datetime
#  preferred_exam_body_id          :bigint(8)
#

class User < ActiveRecord::Base
  include LearnSignalModelExtras

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  delegate :account_type, :to => :student_access

  # Constants
  LOCALES = %w(en)
  SORT_OPTIONS = %w(created user_group name email)

  belongs_to :country, optional: true
  belongs_to :preferred_exam_body, class_name: 'ExamBody', optional: true
  belongs_to :subscription_plan_category, optional: true
  belongs_to :user_group

  has_one :referral_code
  has_one :student_access
  has_one :referred_signup

  has_many :course_module_element_user_logs
  has_many :completed_course_module_element_user_logs, -> {
    where(element_completed: true)
  }, class_name: 'CourseModuleElementUserLog'
  has_many :incomplete_course_module_element_user_logs, -> {
    where(element_completed: false)
  }, class_name: 'CourseModuleElementUserLog'
  has_many :course_tutor_details
  has_many :exam_body_user_details
  has_many :enrollments
  has_many :invoices
  has_many :quiz_attempts
  has_many :orders
  has_many :subscriptions, -> { order(:id) }, inverse_of: :user
  has_many :subscription_payment_cards
  has_many :subscription_transactions
  has_many :student_exam_tracks
  has_many :course_section_user_logs
  has_many :subject_course_user_logs
  has_many :visits
  has_many :charges
  has_many :refunds
  has_many :ahoy_events, :class_name => 'Ahoy::Event'

  has_attached_file :profile_image, default_url: 'images/missing_image.jpg'

  accepts_nested_attributes_for :student_access
  accepts_nested_attributes_for :exam_body_user_details, :reject_if => lambda { |c| c[:student_number].blank? }

  # validation
  validates :email, presence: true, length: {within: 5..50}, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 30}
  validates :password, presence: true, length: {minimum: 6, maximum: 255}, on: :create
  validates_confirmation_of :password, on: :create
  validates_confirmation_of :password, unless: Proc.new { |u| u.password.blank? }
  validates :locale, inclusion: {in: LOCALES}
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation { squish_fields(:email, :first_name, :last_name) }
  before_create :add_guid
  before_create :set_additional_user_attributes
  after_create :create_referral_code_record
  after_update :update_stripe_customer

  # scopes
  scope :all_in_order, -> { order(:user_group_id, :last_name, :first_name, :email) }
  scope :search_for, lambda { |search_term| where("email ILIKE :t OR first_name ILIKE :t OR last_name ILIKE :t OR stripe_customer_id ILIKE :t OR textcat(first_name, textcat(text(' '), last_name)) ILIKE :t", t: '%' + search_term + '%') }
  scope :sort_by_email, -> { order(:email) }
  scope :sort_by_name, -> { order(:last_name, :first_name) }
  scope :sort_by_most_recent, -> { order(created_at: :desc) }
  scope :sort_by_recent_registration, -> { order(created_at: :desc) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :active_this_week, -> { where(last_request_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :with_course_tutor_details, -> { joins(:course_tutor_details) }

  def date_of_birth_is_possible?
    return if self.date_of_birth.blank?
    tens_years_ago = 10.years.ago
    if self.date_of_birth > tens_years_ago
      errors.add(:date_of_birth, 'is invalid')
    end
  end

  ### class methods
  def self.all_students
    includes(:user_group).references(:user_groups).where('user_groups.student_user = ?', true)
  end

  def self.all_trial_or_sub_students
    includes(:user_group).references(:user_groups).where('user_groups.student_user = ?', true).where('user_groups.trial_or_sub_required = ?', true)
  end

  def self.all_tutors
    includes(:user_group).references(:user_groups).where('user_groups.tutor = ?', true)
  end

  def self.get_and_activate(activation_code)
    user = User.where(active: false).where(account_activation_code: activation_code, account_activated_at: nil).first
    time_now = Proc.new{Time.now}.call
    user.update_attributes(account_activated_at: time_now, account_activation_code: nil, active: true) if user
    return user
  end

  def self.get_and_verify(email_verification_code, country_id)
    time_now = Proc.new{Time.now}.call
    user = User.where(email_verification_code: email_verification_code, email_verified_at: nil).first
    if user
      user.update_attributes(account_activated_at: time_now, account_activation_code: nil, active: true) unless user.active
      user.update_attributes(email_verified_at: time_now, email_verification_code: nil, email_verified: true, country_id: country_id)
      return user
    end
  end

  def self.start_password_reset_process(the_email_address, root_url)
    if the_email_address.to_s.length > 5 # a@b.co
      user = User.where(email: the_email_address.to_s).first
      if user && !user.password_change_required?
        user.update_attributes(password_reset_requested_at: Proc.new{Time.now}.call,password_reset_token: ApplicationController::generate_random_code(20))
        #Send reset password email from Mandrill
        MandrillWorker.perform_async(user.id, 'password_reset_email', "#{root_url}/reset_password/#{user.password_reset_token}") unless Rails.env.test?
      elsif user && user.email_verified && user.password_change_required?
        # This is for users that received invite verification emails, clicked on the link which verified their account but they did not enter a PW. Now they are trying to access their account by trying to reset their PW so we send them a link for the set pw form instead of the reset pw form.
        user.update_attribute(:password_reset_token, ApplicationController::generate_random_code(20))
        MandrillWorker.perform_async(user.id, 'send_set_password_email', "#{root_url}/set_password/#{user.password_reset_token}") unless Rails.env.test?
      end
    end
  end

  def self.resend_pw_reset_email(user_id, root_url)
    user = User.where(id: user_id).first
    if user && user.active && user.email_verified && user.password_reset_requested_at && user.password_reset_token && !user.password_change_required?
      #Send reset password email from Mandrill
      MandrillWorker.perform_async(user.id, 'password_reset_email', "#{root_url}/reset_password/#{user.password_reset_token}")
    else

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
    if SORT_OPTIONS.include?(choice)
      case choice
        when 'name'
          sort_by_name
        when 'email'
          sort_by_email
        when 'created'
          sort_by_recent_registration
        else # also covers 'user_group'
          all_in_order
      end
    else
      all_in_order
    end
  end

  def self.to_csv(options = {})
    attributes = %w{first_name last_name email id student_number}
    CSV.generate(options) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def self.to_csv_with_enrollments(options = {})
    attributes = %w{first_name last_name email student_number date_of_birth enrolled_courses valid_enrolled_courses}
    CSV.generate(options) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def self.to_csv_with_visits(options = {})
    attributes = %w{email id visit_campaigns visit_sources visit_landing_pages}
    CSV.generate(options) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def self.parse_csv(csv_content)
    csv_data = []
    duplicate_emails = []
    has_errors = false
    if csv_content.respond_to?(:each_line)
      csv_content.each_line do |line|
        line.strip.split(',').tap do |fields|
          error_msgs = []
          existing_user = User.where(email: fields[0]).first

          if fields.length == 3

            error_msgs << I18n.t('models.users.existing_emails') if existing_user

            error_msgs << I18n.t('models.users.duplicated_emails') if duplicate_emails.include?(fields[0])

            error_msgs << I18n.t('models.users.email_must_have_at_symbol') unless fields[0].include?('@')

            error_msgs << I18n.t('models.users.email_must_have_dot') unless fields[0].include?('.')
            error_msgs << I18n.t('models.users.email_too_short') unless fields[0].length >= 5

            error_msgs << I18n.t('models.users.first_name_too_short') unless fields[1].length >= 2
            error_msgs << I18n.t('models.users.first_name_too_long') unless fields[1].length <= 20

            error_msgs << I18n.t('models.users.last_name_too_short') unless fields[2].length <= 30
            error_msgs << I18n.t('models.users.last_name_too_long') unless fields[2].length >= 2

            duplicate_emails << fields[0]
          else
            error_msgs << I18n.t('models.users.invalid_field_count')
          end
          has_errors = true unless error_msgs.empty?
          csv_data << { values: fields, error_messages: error_msgs }
        end
      end
    else
      has_errors = true
    end
    has_errors = true if csv_data.empty?
    return csv_data, has_errors
  end

  def self.bulk_create(csv_data, user_group_id, root_url)
    existing_users = []
    new_users = []
    if csv_data.is_a?(Hash)
      self.transaction do
        csv_data.each do |k,v|
          user = User.where(email: v['email']).first
          if user
            raise ActiveRecord::Rollback
          else
            CsvImportUserCreationWorker.perform_async(v['email'], v['first_name'], v['last_name'], user_group_id, root_url)
            new_users << v['email']
          end
        end
      end
    end
    return new_users, existing_users
  end

  def self.create_csv_user(email, first_name, last_name, user_group_id, root_url)
    country = Country.find(78) || Country.find(name: 'United Kingdom').last
    password = SecureRandom.hex(5)
    verification_code = ApplicationController::generate_random_code(20)
    time_now = Proc.new{Time.now}.call
    user_group = UserGroup.find(user_group_id)

    user = User.new(email: email, first_name: first_name, last_name: last_name)

    user.assign_attributes(password: password, password_confirmation: password,
                           country_id: country.id, password_change_required: true,
                           locale: 'en', account_activated_at: time_now, account_activation_code: nil,
                           active: true, email_verified: false, email_verified_at: nil,
                           email_verification_code: verification_code, free_trial: true,
                           user_group_id: user_group.id)


    if user.valid? && user.save
      stripe_customer = Stripe::Customer.create(email: user.email)
      user.update_column(:stripe_customer_id, stripe_customer.id)
      MandrillWorker.perform_async(user.id, 'csv_webinar_invite', "#{root_url}/user_verification/#{user.email_verification_code}")
    else

    end

  end

  ### instance methods

  ## UserGroup Access methods
  def student_user?
    self.user_group.try(:student_user)
  end

  def non_student_user?
    !self.user_group.student_user
  end

  def standard_student_user?
    self.student_user? && self.user_group.trial_or_sub_required
  end

  def complimentary_user?
    self.user_group.try(:student_user) && !self.user_group.trial_or_sub_required
  end

  def blocked_user?
    self.user_group.blocked_user
  end

  def system_requirements_access?
    self.user_group.system_requirements_access
  end

  def content_management_access?
    self.user_group.content_management_access
  end

  def stripe_management_access?
    self.user_group.stripe_management_access
  end

  def user_management_access?
    self.user_group.user_management_access
  end

  def developer_access?
    self.user_group.developer_access
  end

  def marketing_resources_access?
    self.user_group.marketing_resources_access
  end

  def user_group_management_access?
    self.user_group.user_group_management_access
  end

  ## StudentAccess methods

  def make_student_access
    build_student_access(
      account_type: 'Trial'
    )
  end


  def default_card
    self.subscription_payment_cards.where(is_default_card: true, status: 'card-live').first if self.student_access.subscription_id
  end

  def subscriptions_for_exam_body(exam_body_id)
    subscriptions.joins(:subscription_plan).where("subscription_plans.exam_body_id = ?", exam_body_id)
  end

  def active_subscriptions_for_exam_body(exam_body_id)
    subscriptions.joins(:subscription_plan).where("subscription_plans.exam_body_id = ?", exam_body_id).all_active
  end

  def active_subscription_for_exam_body?(exam_body_id)
    active_subscriptions_for_exam_body(exam_body_id).any?
  end

  def valid_subscription_for_exam_body?(exam_body_id)
    active_subscriptions_for_exam_body(exam_body_id).all_valid.any?
  end

  def enrolled_course?(course_id)
    #Returns true if an active enrollment exists for this user/course

    self.enrollments.all_active.map(&:subject_course_id).include?(course_id)
  end

  def enrolled_in_course?(course_id)
    #Returns true if a non-expired active enrollment exists for this user/course

    self.enrollments.all_valid.map(&:subject_course_id).include?(course_id)
  end

  def referred_user?
    student_user? && referred_signup
  end

  # Orders/Products
  def valid_order_ids
    order_ids = []
    self.orders.each do |order|
      if %w(paid).include?(order.stripe_status)
        order_ids << order.id
      end
    end
    return order_ids
  end

  def valid_orders?
    self.valid_order_ids.any?
  end

  def purchased_products
    if self.valid_orders?
      ids = self.valid_order_ids
      orders = Order.where(id: ids)
      product_ids = orders.map(&:product_id)
      products = Product.where(id: product_ids)
      products
    end
  end

  def change_the_password(options)
    if options[:password] == options[:password_confirmation] &&
            options[:password].to_s != '' &&
            self.valid_password?(options[:current_password].to_s) &&
            options[:current_password].to_s != ''
      update(
        password: options[:password],
        password_confirmation: options[:password_confirmation]
      )
    else
      false
    end
  end

  def pre_creation_setup
    make_student_access
  end

  def send_verification_email(url)
    MandrillWorker.perform_async(
      id,
      'send_verification_email',
      url
    ) unless Rails.env.test?
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

  def activate_user
    self.active = true
    self.account_activated_at = Proc.new{Time.now}.call
    self.account_activation_code = nil
  end

  def validate_user
    self.email_verified = true
    self.email_verified_at = Proc.new{Time.now}.call
    self.email_verification_code = nil
  end

  def generate_email_verification_code
    self.email_verified = false
    self.email_verified_at = nil
    self.email_verification_code = ApplicationController::generate_random_code(20)
  end

  def create_referral
    unless self.referral_code
      new_referral_code = ReferralCode.new
      new_referral_code.generate_referral_code(self.id)
    end
  end

  def destroyable?
      self.course_module_element_user_logs.empty? &&
      self.invoices.empty? &&
      self.quiz_attempts.empty? &&
      self.student_exam_tracks.empty? &&
      self.subscriptions.empty? &&
      self.subscription_payment_cards.empty? &&
      self.subscription_transactions.empty?
  end

  def full_name
    self.first_name.titleize + ' ' + self.last_name.gsub('O\'','O\' ').titleize.gsub('O\' ','O\'')
  end

  def get_currency(country)
    if existing_sub = subscriptions.not_pending.all_active.first
      existing_sub.subscription_plan&.currency || country.currency
    else
      country.currency
    end
  end

  def this_hour
    self.created_at > Time.now.beginning_of_hour
  end

  def subject_course_user_log_course_ids
    self.subject_course_user_logs.map(&:subject_course_id)
  end

  def enrolled_courses
    course_names = []
    self.enrollments.each do |enrollment|
      course_names << enrollment.subject_course.name if enrollment.subject_course
    end
    course_names
  end

  def valid_enrolled_courses
    course_names = []
    self.enrollments.all_valid.each do |enrollment|
      course_names << enrollment.subject_course.name if enrollment.subject_course
    end
    course_names
  end

  def visit_campaigns
    visits = []
    self.visits.each do |visit|
      visits << visit.utm_campaign
    end
    visits
  end

  def visit_sources
    visits = []
    self.visits.each do |visit|
      visits << visit.utm_source
    end
    visits
  end

  def visit_landing_pages
    visits = []
    self.visits.each do |visit|
      visits << visit.landing_page
    end
    visits
  end

  def enrolled_course_ids
    self.enrollments.map(&:subject_course_id)
  end

  #TODO - valid enrollments ??
  def valid_enrollments_in_sitting_order
    self.enrollments.all_active.by_sitting_date
  end

  #TODO - invalid enrollments ??
  def expired_enrollments_in_sitting_order
    self.enrollments.all_active.by_sitting_date
  end

  def active_enrollments_in_sitting_order
    self.enrollments.all_active.by_sitting_date
  end

  def next_enrollment
    self.valid_enrollments_in_sitting_order.first
  end

  def next_exam_date
    self.next_enrollment.days_until_exam
  end

  def completed_course_module_element(cme_id)
    cmeuls = self.completed_course_module_element_user_logs.where(course_module_element_id: cme_id)
    cmeuls.any?
  end

  def started_course_module_element(cme_id)
    cmeuls = self.incomplete_course_module_element_user_logs.where(course_module_element_id: cme_id)
    cmeuls.any?
  end

  private

  def add_guid
    self.guid ||= ApplicationController.generate_random_code(10)
    Rails.logger.debug "DEBUG: User#add_guid - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}"
  end

  def create_referral_code_record
    self.create_referral_code
  end

  def set_additional_user_attributes
    self.communication_approval_datetime = Time.zone.now if communication_approval
    self.account_activation_code = SecureRandom.hex(10)
    self.email_verification_code = SecureRandom.hex(10)
  end

  def update_stripe_customer
    unless Rails.env.test?
      if self.saved_change_to_email?
        Rails.logger.debug "DEBUG: Updating stripe customer object #{self.stripe_customer_id}"
        stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
        stripe_customer.email = self.email
        stripe_customer.save
      end
    end
  end
end
