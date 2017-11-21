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
#  analytics_guid                   :string
#  student_number                   :string
#

class User < ActiveRecord::Base

  include LearnSignalModelExtras

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  # attr-accessible
  attr_accessible :email, :first_name, :last_name, :active,
                  :country_id, :user_group_id, :password_reset_requested_at,
                  :password_reset_token, :password_reset_at,
                  :stripe_customer_id, :password, :password_confirmation,
                  :current_password, :locale, :subscriptions_attributes,
                  :password_change_required, :address,
                  :profile_image, :topic_interest,
                  :email_verification_code, :email_verified_at,
                  :email_verified, :account_activated_at,
                  :account_activation_code, :session_key,
                  :stripe_account_balance, :trial_limit_in_seconds,
                  :free_trial, :trial_limit_in_days,
                  :trial_ended_notification_sent_at, :terms_and_conditions,
                  :date_of_birth, :description, :free_trial_ended_at,
                  :student_number

  # Constants
  LOCALES = %w(en)
  SORT_OPTIONS = %w(created user_group name email)

  # relationships
  belongs_to :country
  has_many :course_module_element_user_logs
  has_many :completed_course_module_element_user_logs, -> {where(element_completed: true)},
           class_name: 'CourseModuleElementUserLog'
  has_many :incomplete_course_module_element_user_logs, -> {where(element_completed: false)},
           class_name: 'CourseModuleElementUserLog'
  has_many :enrollments
  has_and_belongs_to_many :subject_courses
  has_many :invoices
  has_many :quiz_attempts
  has_many :orders
  has_many :subscriptions, -> { order(:id) }, inverse_of: :user
  has_many :subscription_payment_cards
  has_many :subscription_transactions
  has_many :student_exam_tracks
  has_many :subject_course_user_logs
  belongs_to :user_group
  has_many :user_notifications
  has_many :visits
  has_many :ahoy_events, :class_name => 'Ahoy::Event'
  has_one :referral_code
  has_one :student_access
  has_one :referred_signup
  belongs_to :subscription_plan_category
  has_attached_file :profile_image, default_url: '/assets/images/missing_corporate_logo.png'

  accepts_nested_attributes_for :subscriptions
  accepts_nested_attributes_for :student_access

  # validation
  validates :email, presence: true, uniqueness: true, length: {within: 5..50}
  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 30}
  validates :password, presence: true, length: {minimum: 6, maximum: 255}, on: :create
  validates_confirmation_of :password, on: :create
  validates_confirmation_of :password, if: '!password.blank?'
  validates :user_group_id, presence: true
  validates :country_id, presence: true, if: :student_user?
  validates :locale, inclusion: {in: LOCALES}
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation { squish_fields(:email, :first_name, :last_name) }
  before_create :add_guid
  after_create :create_on_intercom

  # scopes
  scope :all_in_order, -> { order(:user_group_id, :last_name, :first_name, :email) }
  scope :search_for, lambda { |search_term| where("email ILIKE :t OR first_name ILIKE :t OR last_name ILIKE :t OR textcat(first_name, textcat(text(' '), last_name)) ILIKE :t", t: '%' + search_term + '%') }
  scope :sort_by_email, -> { order(:email) }
  scope :sort_by_name, -> { order(:last_name, :first_name) }
  scope :sort_by_most_recent, -> { order(created_at: :desc) }
  scope :sort_by_recent_registration, -> { order(created_at: :desc) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :active_this_week, -> { where(last_request_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :all_free_trial, -> { where(free_trial: true).where("trial_limit_in_seconds <= #{ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i}") }

  # class methods
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

  def self.get_and_verify(email_verification_code)
    time_now = Proc.new{Time.now}.call
    user = User.where(email_verification_code: email_verification_code, email_verified_at: nil).first
    if user
      user.update_attributes(email_verified_at: time_now, email_verification_code: nil, email_verified: true)
      user.student_access.update_attributes(trial_start_date: time_now, trial_ending_at_date: time_now + user.student_access.trial_days_limit.days, content_access: true)
      return user
    end
  end

  def self.start_password_reset_process(the_email_address, root_url)
    if the_email_address.to_s.length > 5 # a@b.co
      user = User.where(email: the_email_address.to_s).first
      if user && !user.password_change_required?
        user.update_attributes(password_reset_requested_at: Proc.new{Time.now}.call,password_reset_token: ApplicationController::generate_random_code(20), active: false)
        #Send reset password email from Mandrill
        MandrillWorker.perform_async(user.id, 'password_reset_email', "#{root_url}/reset_password/#{user.password_reset_token}")
      elsif user && user.password_change_required?
        # This is for users that received invite verification emails, clicked on the link which verified their account but they did not enter a PW. Now they are trying to access their account by trying to reset their PW so we send them a link for the set pw form instead of the reset pw form.
        MandrillWorker.perform_async(user.id, 'password_reset_email', "#{root_url}/set_password/#{user.password_reset_token}")
      end
    end
  end

  def self.finish_password_reset_process(reset_token, new_password,
          new_password_confirmation)
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


  ## instance methods

  # UserGroup Access methods
  def student_user?
    self.user_group.try(:student_user)
  end

  def non_student_user?
    !self.user_group.student_user
  end

  def trial_or_sub_user?
    self.user_group.try(:student_user)&& self.user_group.trial_or_sub_required
  end

  def complimentary_user?
    self.user_group.try(:student_user) && !self.user_group.trial_or_sub_required
  end

  def tutor_user?
    self.user_group.tutor
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

  def home_pages_access?
    self.user_group.home_pages_access
  end

  def user_group_management_access?
    self.user_group.user_group_management_access
  end




  def active_subscription
    self.subscriptions.where(active: true).in_created_order.last
  end

  def user_subscription_status
    current_subscription = self.active_subscription
    if current_subscription
      case current_subscription.current_status
        when 'active'
          'Active Subscription'
        when 'past_due'
          'Past Due Subscription'
        when 'canceled-pending'
          'Canceled-pending Subscription'
        when 'canceled'
          'Canceled Subscription'
        when 'unpaid'
          'Unpaid Subscription'
        when 'suspended'
          'Suspended Subscription'
        else
          'Invalid Subscription'
      end
    else
      'Invalid Subscription'
    end
  end

  def user_account_status
    if self.trial_or_sub_user?
      if !self.trial_started?
        'Trial Not Started'
      elsif self.valid_free_member?
        'Valid Free Trial'
      elsif self.expired_free_member?
        'Expired Free Trial'
      elsif self.active_subscription
        self.user_subscription_status
      else
        'Unknown'
      end
    elsif complimentary_user?
      'Comp User'
    else
      self.user_group.name
    end
  end

  def days_or_seconds_valid?
    if free_trial_days_valid? && free_trial_minutes_valid?
      true
    else
      false
    end
  end

  def free_trial_days_valid?
    # 86400 is number of seconds in a day
    trial_limit_days_in_seconds = self.trial_limit_in_days * 86400
    current_date_time = Proc.new { Time.now }.call

    if  current_date_time <= (self.trial_start_date + trial_limit_days_in_seconds)
      true
    else
      false
    end
  end

  def free_trial_minutes_valid?
    #If the Number of seconds watched is less than the allowed free trial time limit then permission is allowed
    if self.trial_limit_in_seconds <= ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i
      true
    else
      false
    end
  end

  def days_left
    # Displayed in the Navbar change to return full sentence string 'X Days Left' or 'Your Trial has Expired'
    free_trial_days = self.trial_limit_in_days.to_i
    if free_trial_days - ((Time.now - self.trial_start_date).to_i.abs / 1.day).to_i > 0
      free_trial_days - ((Time.now - self.trial_start_date).to_i.abs / 1.day)
    else
      '0'
    end
  end

  def trial_start_date
    self.email_verified ? self.email_verified_at : self.created_at
  end

  def trial_started?
    self.email_verified && self.email_verified_at
  end

  def minutes_left
    free_trial_seconds = ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i
    seconds_left = free_trial_seconds - self.trial_limit_in_seconds
    minutes_left = (seconds_left/60)
  end

  def free_member?
    self.trial_or_sub_user? && self.free_trial && !self.subscriptions.any?
  end

  def valid_free_member?
    self.free_member? && self.days_or_seconds_valid? && !self.free_trial_ended_at
  end

  def expired_free_member?
    self.free_member? && !self.days_or_seconds_valid?
  end

  def canceled_member?
    self.trial_or_sub_user? && !self.free_trial? && self.subscriptions.any? && self.active_subscription && self.active_subscription.current_status == 'canceled'
  end

  def canceled_pending?
    self.trial_or_sub_user? && !self.free_trial? && self.subscriptions.any? && self.active_subscription && self.active_subscription.current_status == 'canceled-pending'
  end

  def referred_user
    self.student_user? && self.referred_signup
  end

  def valid_subscription
    true if self.active_subscription && %w(active past_due).include?(self.active_subscription.current_status)
  end

  def valid_order_ids
    order_ids = []
    self.orders.each do |order|
      if %w(paid).include?(order.current_status)
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

  def permission_to_see_content(course)
    if self.trial_or_sub_user? && course.active_enrollment_user_ids.include?(self.id)
      if course.active
        if self.valid_free_member?
          true
        elsif self.expired_free_member?
          false
        elsif self.active_subscription && %w(active past_due canceled-pending).include?(self.active_subscription.current_status)
          true
        else
          false
        end
      else
        false
      end
    elsif self.complimentary_user? && course.active_enrollment_user_ids.include?(self.id)
      true
    elsif self.non_student_user? && course.active_enrollment_user_ids.include?(self.id)
      true
    else
      false
    end
  end

  def change_the_password(options)
    # options = {current_password: '123123123', password: 'new123',
    #            password_confirmation: 'new123'}
    if options[:password] == options[:password_confirmation] &&
            options[:password].to_s != '' &&
            self.valid_password?(options[:current_password].to_s) &&
            options[:current_password].to_s != ''
      self.update_attributes(
              password: options[:password],
              password_confirmation: options[:password_confirmation]
      )
    else
      false
    end
  end

  def activate_user
    self.active = true
    self.account_activated_at = Proc.new{Time.now}.call
    self.account_activation_code = ApplicationController::generate_random_code(20)
  end

  def validate_user
    self.email_verified = true
    self.email_verified_at = Proc.new{Time.now}.call
    self.email_verification_code = nil
  end

  def de_activate_user
    self.active = false
    self.account_activated_at = nil
    self.account_activation_code = ApplicationController::generate_random_code(20)
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

  def this_hour
    self.created_at > Time.now.beginning_of_hour
  end

  def subject_course_user_log_course_ids
    self.subject_course_user_logs.map(&:subject_course_id)
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
    attributes = %w{email id user_account_status visit_campaigns visit_sources visit_landing_pages}
    CSV.generate(options) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
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

  def resubscribe_account(new_plan_id, stripe_token, terms_and_conditions)

    new_subscription_plan = SubscriptionPlan.find_by_id(new_plan_id)
    user = self
    old_sub = user.active_subscription

    # compare the currencies of the old and new plans,
    unless old_sub.subscription_plan.currency_id == new_subscription_plan.currency_id
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.currencies_mismatch'))
    end
    # make sure new plan is active
    unless new_subscription_plan.active?
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.new_plan_is_inactive'))
    end
    # make sure the current subscription is in "good standing"
    unless %w(canceled).include?(old_sub.current_status)
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.this_subscription_cant_be_upgraded'))
    end
    # only student_users are allowed to upgrade their plan
    unless user.trial_or_sub_user?
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade'))
    end

    #### if we're here, then we're good to go.
    stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
    stripe_subscription = stripe_customer.subscriptions.create(plan: new_subscription_plan.stripe_guid, source: stripe_token)

    stripe_subscription.prorate = true
    stripe_subscription.trial_end = 'now'
    result = stripe_subscription.save # saves it on stripe

    #### if we are here, the subscription creation on Stripe was successful
    #### Now we need to create a new Subscription in our DB.
    ActiveRecord::Base.transaction do
      new_sub = Subscription.new(
          user_id: user.id,
          subscription_plan_id: new_subscription_plan.id,
          complimentary: false,
          active: true,
          livemode: (result[:plan][:livemode]),
          current_status: result[:status],
      )
      # mass-assign-protected attributes
      new_sub.stripe_guid = result[:id]
      new_sub.next_renewal_date = Time.at(result[:current_period_end])
      new_sub.terms_and_conditions = terms_and_conditions
      new_sub.stripe_customer_id = user.stripe_customer_id
      new_sub.stripe_customer_data = Stripe::Customer.retrieve(self.stripe_customer_id).to_hash
      new_sub.save(validate: false)

      old_sub.update_attribute(:active, false)
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)

      user.update_attribute(:stripe_account_balance, stripe_customer.account_balance)

      return new_sub
    end
  rescue ActiveRecord::RecordInvalid => exception
    Rails.logger.error("ERROR: Subscription#reactivation - AR.Transaction failed.  Details: #{exception.inspect}")
    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    false
  rescue => e
    Rails.logger.error("ERROR: Subscription#reactivation - failed to create Subscription at Stripe.  Details: #{e.inspect}")
    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    false

  end


  def completed_course_module_element(cme_id)
    cmeuls = self.completed_course_module_element_user_logs.where(course_module_element_id: cme_id)
    cmeuls.any?
  end

  def started_course_module_element(cme_id)
    cmeuls = self.incomplete_course_module_element_user_logs.where(course_module_element_id: cme_id)
    cmeuls.any?
  end

  def self.parse_csv(csv_content)
    csv_data = []
    duplicate_emails = []
    has_errors = false
    if csv_content.lines.count == 1 && csv_content.include?("\r")
      csv_content.strip.split("\r").each do |line|
        line.to_s.strip.split(',').tap do |fields|
          error_msgs = []
          if fields.length == 3
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
      if csv_content.respond_to?(:each_line)
        csv_content.each_line do |line|
          line.strip.split(',').tap do |fields|
            error_msgs = []
            if fields.length == 3
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

    end
    has_errors = true if csv_data.empty?
    return csv_data, has_errors
  end

  def self.bulk_create(csv_data, root_url)
    existing_users = []
    new_users = []
    if csv_data.is_a?(Hash)
      self.transaction do
        csv_data.each do |k,v|
          user = User.where(email: v['email']).first
          similar_user = User.search_for(v['email']).first
          if user && v['email'].empty?
            existing_users = []
            raise ActiveRecord::Rollback
          elsif user
            if user.expired_free_member? && user.stripe_customer_id
              MandrillWorker.perform_async(user.id, 'send_free_trial_over_email', "#{root_url}/users/#{user.id}/new_subscription")
              existing_users << user
            end
          elsif !user && similar_user
            if similar_user.expired_free_member? && similar_user.stripe_customer_id
              MandrillWorker.perform_async(similar_user.id, 'send_free_trial_over_email', "#{root_url}/users/#{similar_user.id}/new_subscription")
              existing_users << similar_user
            end
          else

            CsvImportUserCreationWorker.perform_async(v['email'], v['first_name'], v['last_name'], root_url)
            new_users << v['email']
          end
        end
      end
    end
    return new_users, existing_users
  end

  def self.create_csv_user(email, first_name, last_name, root_url)
    country = Country.find(78) || Country.find(name: 'United Kingdom').last
    password = SecureRandom.hex(5)
    verification_code = ApplicationController::generate_random_code(20)
    time_now = Proc.new{Time.now}.call
    user_group = UserGroup.where(student_user: true, trial_or_sub_required: true).first

    user = self.where(email: email, first_name: first_name, last_name: last_name).first_or_create

    stripe_customer = Stripe::Customer.create(email: user.email)

    user.update_attributes(password: password, password_confirmation: password, country_id: country.id, password_change_required: true, locale: 'en', account_activated_at: time_now, account_activation_code: nil, active: true, email_verified: false, email_verified_at: nil, email_verification_code: verification_code, free_trial: true, user_group_id: user_group.id, stripe_customer_id: stripe_customer.id)

    MandrillWorker.perform_async(user.id, 'csv_webinar_invite', "#{root_url}/user_verification/#{user.email_verification_code}")


  end

  def update_from_stripe
    stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    stripe_subscriptions = stripe_customer.subscriptions[:data]
    if stripe_subscriptions && stripe_subscriptions.count == 1
      stripe_subscription = stripe_customer.subscriptions[:data].first
      if self.active_subscription && stripe_subscription.id == self.active_subscription.stripe_guid
        self.active_subscription.update_from_stripe
      else
        create_subscription_from_stripe(stripe_subscription, stripe_customer)
      end
    end
  end


  def create_subscription_from_stripe(stripe_subscription_object, stripe_customer_object)
    subscription_plan = SubscriptionPlan.where(stripe_guid: stripe_subscription_object.plan.id).first
    if subscription_plan
      subscription = Subscription.new(
          user_id: self.id,
          subscription_plan_id: subscription_plan.id,
          complimentary: false,
          active: true,
          livemode: stripe_subscription_object.plan.livemode,
          current_status: stripe_subscription_object.status,
      )
      subscription.stripe_guid = stripe_subscription_object.id
      subscription.next_renewal_date = Time.at(stripe_subscription_object.current_period_end)
      subscription.stripe_customer_id = stripe_customer_object.id
      subscription.terms_and_conditions = true
      subscription.stripe_customer_data = stripe_customer_object.to_hash.deep_dup
      subscription_saved = subscription.save(validate: false)
      #Callbacks should create SubscriptionTransactions and SubscriptionPaymentCard

      if subscription_saved
        trial_ended_date = self.free_trial_ended_at ? self.free_trial_ended_at : Proc.new{Time.now}.call
        self.update_attributes(free_trial: false, free_trial_ended_at: trial_ended_date)
      end
    end

  end

  def create_free_trial_expiration_worker
    if self.student_user? && self.student_access
      trial_ending_at_date = self.student_access.trial_ending_at_date + 23.hours
      TrialExpirationWorker.perform_at(trial_ending_at_date, self.id)
    end
  end

  protected

  def add_guid
    self.guid ||= ApplicationController.generate_random_code(10)
    Rails.logger.debug "DEBUG: User#add_guid - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}"
  end

  def create_on_intercom
    IntercomCreateUserWorker.perform_async(self.id) unless Rails.env.test?
  end

end
