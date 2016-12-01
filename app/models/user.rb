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
#  discourse_user                   :boolean          default(FALSE)
#

class User < ActiveRecord::Base

  include LearnSignalModelExtras

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  # attr-accessible
  attr_accessible :email, :first_name, :last_name, :active,
                  :country_id, :user_group_id, :password_reset_requested_at,
                  :password_reset_token, :password_reset_at, :stripe_customer_id,
                  :corporate_customer_id, :password,
                  :password_confirmation, :current_password, :locale,
                  :subscriptions_attributes, :employee_guid, :password_change_required,
                  :address, :first_description, :second_description, :wistia_url, :personal_url,
                  :name_url, :qualifications, :profile_image, :topic_interest, :email_verification_code,
                  :email_verified_at, :email_verified, :account_activated_at, :account_activation_code,
                  :session_key, :stripe_account_balance, :trial_limit_in_seconds, :free_trial,
                  :trial_limit_in_days, :trial_ended_notification_sent_at, :student_number,
                  :terms_and_conditions, :student_user_type_id

  # Constants
  EMAIL_FREQUENCIES = %w(off daily weekly monthly)
  LOCALES = %w(en)
  SORT_OPTIONS = %w(created user_group name email)
  USER_STATUS = %w(valid_free_member expired_free_member valid_paying_member canceled_paying_member expired_paying_member other_user)

  # relationships
  belongs_to :corporate_customer
             # employed by the corporate customer
  belongs_to :country
  belongs_to :student_user_type
  has_many :course_modules, foreign_key: :tutor_id
  has_many :completion_certificates
  has_many :course_module_element_user_logs
  has_many :enrollments
  has_many :subject_courses, foreign_key: :tutor_id
  has_many :invoices
  has_many :quiz_attempts
  has_many :question_banks
  has_many :orders
  has_many :subscriptions, -> { order(:id) }, inverse_of: :user
  has_many :subscription_payment_cards
  has_many :subscription_transactions
  has_many :student_exam_tracks
  has_many :subject_course_user_logs
  has_many :user_exam_sittings
  belongs_to :user_group
  has_many :user_notifications
  has_one :referral_code
  has_one :referred_signup
  belongs_to :subscription_plan_category
  has_and_belongs_to_many :corporate_groups
  has_attached_file :profile_image, default_url: '/assets/images/missing_corporate_logo.png'

  accepts_nested_attributes_for :subscriptions

  # validation
  validates :email, presence: true, uniqueness: true, length: {within: 7..50}
  validates :first_name, presence: true, length: {minimum: 1, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 1, maximum: 30}
  validates :password, presence: true, length: {minimum: 6, maximum: 255}, on: :create
  validates_confirmation_of :password, on: :create
  validates_confirmation_of :password, if: '!password.blank?'
  validates :user_group_id, presence: true
  validates :student_user_type_id, presence: true, if: :individual_student?
  validates :country_id, presence: true, if: :individual_student?
  validates :corporate_customer_id,
            numericality: { unless: -> { corporate_customer_id.nil? }, only_integer: true, greater_than: 0 },
            presence: { if: -> { ug = UserGroup.find_by_id(user_group_id); ug.try(:corporate_customer) || ug.try(:corporate_student) } }
  validates :locale, inclusion: {in: LOCALES}
  #validates :employee_guid, allow_nil: true,
  #          uniqueness: { scope: :corporate_customer_id }
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation { squish_fields(:email, :first_name, :last_name) }
  before_create :add_guid
  after_create :set_trial_limit_in_days, :create_on_discourse
  after_create :create_on_discourse

  # scopes
  scope :all_in_order, -> { order(:user_group_id, :last_name, :first_name, :email) }
  scope :search_for, lambda { |search_term| where("email ILIKE :t OR first_name ILIKE :t OR last_name ILIKE :t OR textcat(first_name, textcat(text(' '), last_name)) ILIKE :t", t: '%' + search_term + '%') }
  scope :sort_by_email, -> { order(:email) }
  scope :sort_by_name, -> { order(:last_name, :first_name) }
  scope :sort_by_recent_registration, -> { order(created_at: :desc) }

  # class methods
  def self.all_admins
    includes(:user_group).references(:user_groups).where('user_groups.site_admin = ?', true)
  end

  def self.all_tutors
    includes(:user_group).references(:user_groups).where('user_groups.tutor = ?', true)
  end

  def self.get_and_activate(activation_code)
    user = User.where.not(active: true).where(account_activation_code: activation_code, account_activated_at: nil).first
    duplicate_users = User.where(email: user.email)
    if duplicate_users.count > 1
      duplicate_user = duplicate_users.last
      duplicate_user.active = false
      duplicate_user.email = duplicate_user.email.prepend('copy-')
      duplicate_user.save!
    else
      user.account_activated_at = Proc.new{Time.now}.call
      user.account_activation_code = nil
      user.active = true
      user.save!
    end
    return user
  end

  def self.get_and_verify(email_verification_code)
    user = User.where(email_verification_code: email_verification_code, email_verified_at: nil).first
    if user
      user.email_verified_at = Proc.new{Time.now}.call
      user.email_verification_code = nil
      user.email_verified = true
      user.save!
    end
    return user
  end

  def self.start_password_reset_process(the_email_address, root_url)
    if the_email_address.to_s.length > 5 # a@b.co
      user = User.where(email: the_email_address.to_s).first
      if user
        user.update_attributes(password_reset_requested_at: Proc.new{Time.now}.call,password_reset_token: ApplicationController::generate_random_code(20), active: false)
        #Send reset password email from Mandrill
        if user.corporate_customer_id
          MandrillWorker.perform_async(user.id, 'corporate_password_reset_email', "#{root_url}/reset_password/#{user.password_reset_token}")
        else
          MandrillWorker.perform_async(user.id, 'password_reset_email', "#{root_url}/reset_password/#{user.password_reset_token}")
        end
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


  # instance methods
  def admin?
    self.user_group.try(:site_admin)
  end

  def process_free_trial_limit_reached
    text = "We just wanted to let you know that you have reached the free trial limit of #{ENV["free_trial_limit_in_seconds"].to_i/60} minutes!"
    MandrillWorker.perform_async(user.id, "send_free_trial_ended_email", url_helpers.user_new_subscription_url(user_id: self.id, host: 'www.learnsignal.com'), text) if Rails.env.production?
    if self.student_user_type_id == StudentUserType.default_free_trial_user_type.id
      new_user_type_id = StudentUserType.default_no_access_user_type.id
    elsif self.student_user_type_id == StudentUserType.default_free_trial_and_product_user_type.id
      new_user_type_id = StudentUserType.default_product_user_type.id
    else
      new_user_type_id = self.student_user_type_id
    end
    self.update_attributes(free_trial: false, trial_ended_notification_sent_at: Time.now, student_user_type_id: new_user_type_id)
  end

  def user_status
    if self.individual_student?
      if self.student_user_type_id == StudentUserType.default_free_trial_user_type.id
        if self.free_trial && !self.subscriptions.any? && self.days_or_seconds_valid?
          return 'valid_free_member'
        else
          return 'expired_free_member'
        end
      elsif self.student_user_type_id == StudentUserType.default_sub_user_type.id
        if !self.free_trial && self.subscriptions.any?
          if self.valid_subscription
            return 'valid_sub_member'
          elsif self.canceled_member?
            return 'canceled_sub_member'
          elsif self.canceled_pending?
            return 'cancel_pending_sub_member'
          elsif self.active_subscription && self.active_subscription.current_status == 'past_due'
            return 'failed_payment_sub_member'
          end
        else
          return ''
        end
      elsif self.student_user_type_id == StudentUserType.default_product_user_type.id
        if self.valid_orders?
          return 'product_order_member'
        else
          return ''
        end
      elsif self.student_user_type_id == StudentUserType.default_sub_and_product_user_type.id
        if !self.free_trial && self.subscriptions.any? && self.valid_orders?
          if self.valid_subscription
            return 'valid_sub_product_member'
          elsif self.canceled_member?
            return 'canceled_sub_product_member'
          elsif self.canceled_pending?
            return 'cancel_pending_sub_product_member'
          elsif self.active_subscription && self.active_subscription.current_status == 'past_due'
            return 'failed_payment_sub_product_member'
          end
        else
          return ''
        end
      elsif self.student_user_type_id == StudentUserType.default_free_trial_and_product_user_type.id
        if self.free_trial && !self.subscriptions.any? && self.days_or_seconds_valid? && self.valid_orders?
          return 'valid_free_product_member'
        else
          return ''
        end
      elsif self.student_user_type_id == StudentUserType.default_no_access_user_type.id
        if self.free_trial && !self.subscriptions.any? && self.days_or_seconds_valid?
          return 'valid_free_member'
        elsif !self.subscriptions.any? && !self.days_or_seconds_valid?
          return 'expired_free_member'
        elsif !self.free_trial && self.subscriptions.any?
          if self.valid_subscription
            return 'valid_sub_member'
          elsif self.canceled_member?
            return 'canceled_sub_member'
          elsif self.canceled_pending?
            return 'cancel_pending_sub_member'
          elsif self.active_subscription && self.active_subscription.current_status == 'past_due'
            return 'failed_payment_sub_member'
          else
            return 'no_access_member'
          end
        else
          return 'no_access_member'
        end
      end
    else
      return 'non_student_member'
    end
  end

  def user_subscription_status
    if self.user_status == 'valid_free_member'
      status =  'Free Trial Member'
    elsif self.user_status == 'expired_free_member'
      status =  'Free Trial Expired'
    elsif self.user_status == 'valid_sub_member' || self.user_status == 'valid_sub_product_member'
      status =  'Valid Subscription'
    elsif self.user_status == 'canceled_sub_member'
      status =  'Canceled Subscription'
    elsif self.user_status == 'cancel_pending_sub_member'
      status =  'Subscription Set to Cancel'
    elsif self.user_status == 'failed_payment_sub_member'
      status =  'Failed Payment'
    elsif self.user_status == 'product_order_member' && self.subscriptions.any?
      status =  'Canceled Subscription'
    else
      status =  'Unknown'
    end
    return status
  end

  def days_or_seconds_valid?
    if free_trial_days_expired? || free_trial_minutes_expired?
      false
    else
      true
    end
  end

  def free_trial_days_expired?
    #If the Number of days since the user was created is greater than the allowed free trial days then permission is denied
    if (Time.now - self.created_at).to_i.abs / 1.day >= self.trial_limit_in_days
      true
    else
      false
    end
  end

  def free_trial_minutes_expired?
    #If the Number of seconds watched is less than the allowed free trial time limit then permission is allowed
    if self.trial_limit_in_seconds <= ENV['free_trial_limit_in_seconds'].to_i
      false
    else
      true
    end
  end

  def days_left
    # Displayed in the Navbar change to return full sentence string 'X Days Left' or 'Your Trial has Expired'
    free_trial_days = self.trial_limit_in_days.to_i
    if free_trial_days - ((Time.now - self.created_at).to_i.abs / 1.day).to_i > 0
      free_trial_days - ((Time.now - self.created_at).to_i.abs / 1.day)
    else
      '0'
    end
  end

  def check_and_free_trial_status
    if self.no_subscription_user && !self.days_or_seconds_valid?
      self.update_attributes(free_trial: false, trial_ended_notification_sent_at: Time.now)
    elsif self.no_subscription_user && self.days_or_seconds_valid?
      self.update_attributes(free_trial: true, trial_ended_notification_sent_at: nil)
    end
  end

  def free_member?
    self.user_status == 'valid_free_member'
  end

  def expired_free_member?
    self.user_status == 'expired_free_member'
  end

  def no_subscription_user
    if !self.subscriptions.any? && self.student_user_type_id == (StudentUserType.default_product_user_type.id || StudentUserType.default_no_access_user_type.id)
      true
    else
      false
    end
  end

  def canceled_member?
    !self.free_trial? && self.subscriptions.any? && self.active_subscription && self.active_subscription.current_status == 'canceled'
  end

  def canceled_pending?
    !self.free_trial? && self.subscriptions.any? && self.active_subscription && self.active_subscription.current_status == 'canceled-pending'
  end

  def referred_user
    self.referred_signup
  end

  def valid_subscription
    true if self.active_subscription && %w(active past_due).include?(self.active_subscription.current_status)
  end

  def valid_subject_course_ids
    subject_course_ids = []
    self.orders.each do |order|
      if %w(paid).include?(order.current_status)
        subject_course_ids << order.subject_course_id
      end
    end
    return subject_course_ids
  end

  def valid_orders?
    self.valid_subject_course_ids.any?
  end

  def active_subscription
    self.subscriptions.where(active: true).last
  end

  def one_active_subscription?
    if self.subscriptions.any?
      self.subscriptions.all_active.count == 1
    end
  end

  def permission_to_see_content(course)
    if self.corporate_user?
      if course.restricted && self.corporate_customer_id != course.corporate_customer_id
        return false
      else
        if self.corporate_student?
          if self.restricted_subject_course_ids.include?(course.id)
            return false
          else
            return true
          end
        elsif self.corporate_customer? || self.corporate_manager?
          return true
        else
          return false
        end
      end
    elsif self.complimentary_user?
      if course.subscription
        return true
      else
        return true
      end
    elsif self.individual_student?

      if course.subscription
        if self.free_trial && self.free_trial_student?
          return true
        elsif self.subscription_student? && self.active_subscription && ('active past_due canceled-pending').include?(self.active_subscription.current_status)
          return true
        else
          return false
        end
      elsif course.product
        if self.product_order_student? && valid_subject_course_ids.include?(course.id)
          return true
        else
          return false
        end
      end
    else
      return true
    end
  end

  def assign_anonymous_logs_to_user(session_guid)
    model_list = [CourseModuleElementUserLog, StudentExamTrack, SubjectCourseUserLog]
    model_list.each do |the_model|
      the_model.assign_user_to_session_guid(self.id, session_guid)
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

  def blogger?
    self.user_group.try(:blogger)
  end

  def content_manager?
    self.user_group.try(:content_manager)
  end

  def corporate_customer?
    self.user_group.try(:corporate_customer)
  end

  def corporate_manager?
    self.user_group.try(:corporate_manager)
  end

  def corporate_student?
    self.user_group.try(:corporate_student)
  end

  def corporate_tutor?
    self.user_group.try(:corporate_tutor) && !self.user_group.try(:corporate_customer)
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
    !self.admin? &&
        self.course_modules.empty? &&
        self.course_module_element_user_logs.empty? &&
        self.invoices.empty? &&
        self.quiz_attempts.empty? &&
        self.student_exam_tracks.empty? &&
        self.subscriptions.empty? &&
        self.subscription_payment_cards.empty? &&
        self.subscription_transactions.empty? &&
        self.user_notifications.empty?
  end

  def full_name
    self.first_name.titleize + ' ' + self.last_name.gsub('O\'','O\' ').titleize.gsub('O\' ','O\'')
  end

  def individual_student?
    self.user_group.try(:individual_student) && self.corporate_customer_id.to_i == 0
  end

  def complimentary_user?
    self.user_group.try(:complimentary) && self.corporate_customer_id.to_i == 0
  end

  def corporate_user?
    self.user_group.try(:corporate_customer) || self.user_group.try(:corporate_student) || self.user_group.try(:corporate_manager)
  end

  def exam_sittings
    user_exam_sittings.map(&:exam_sitting_id)
  end

  def exam_sitting_courses
    user_exam_sittings.map(&:subject_course_id)
  end

  #######################################################
  #StudentUserTypes
  #######################################################
  def free_trial_student?
    self.student_user_type.try(:free_trial)
  end

  def subscription_student?
    self.student_user_type.try(:subscription)
  end

  def product_order_student?
    self.student_user_type.try(:product_order)
  end

  def no_product_or_sub_student?
    #User that created an account through purchase product process but didn't complete purchase or has an expired free trial so has an account but no access to any content
    !self.student_user_type.try(:product_order) && !self.student_user_type.try(:subscription) && !self.student_user_type.try(:free_trial)
  end

  def tutor?
    self.user_group.try(:tutor)
  end

  #######################################################
  #CorporateAccountMethods
  #######################################################

  def compulsory_group_ids
    @compulsory_group_ids ||=
      corporate_student? ? corporate_groups.map { |cg| cg.compulsory_group_ids }.flatten.uniq : []
  end

  def restricted_group_ids
    @restricted_group_ids ||=
      corporate_student? ?
        (corporate_groups.map { |cg| cg.restricted_group_ids }.flatten.uniq - compulsory_group_ids) : []
  end

  def compulsory_subject_course_ids
    @compulsory_subject_course_ids ||=
      corporate_student? ? corporate_groups.map { |cg| cg.compulsory_subject_course_ids }.flatten.uniq : []
  end

  def restricted_subject_course_ids
    @restricted_subject_course_ids ||=
      corporate_student? ?
        (corporate_groups.map { |cg| cg.restricted_subject_course_ids }.flatten.uniq - compulsory_subject_course_ids) : []
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
            error_msgs << I18n.t('models.users.existing_emails') if User.where(email: fields[0].strip).count > 0
            error_msgs << I18n.t('models.users.not_valid_email') unless fields[0].include?('@')

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
              error_msgs << I18n.t('models.users.existing_emails') if User.where(email: fields[0].strip).count > 0
              error_msgs << I18n.t('models.users.not_valid_email') unless fields[0].include?('@')

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

  def self.bulk_create(csv_data, corporate_manager)
    users = []
    used_emails = []
    if csv_data.is_a?(Hash)
      self.transaction do
        csv_data.each do |k,v|
          user = User.where(email: v['email']).first
          if user || v['email'].empty?
            users = []
            raise ActiveRecord::Rollback
          end
          password = SecureRandom.hex(5)
          verification_code = ApplicationController::generate_random_code(20)
          time_now = Proc.new{Time.now}.call
          user = self.where(email: v['email'], first_name: v['first_name'], last_name: v['last_name']).first_or_create
          user.update_attributes(password: password, password_confirmation: password, user_group_id: UserGroup.where(corporate_student: true).first.id, country_id: corporate_manager.country_id, password_change_required: true, corporate_customer_id: corporate_manager.corporate_customer_id, locale: 'en', account_activated_at: time_now, account_activation_code: nil, active: true, email_verified: false, email_verified_at: nil, email_verification_code: verification_code)
          if used_emails.include?(v['email']) || !user.valid?
            users = []
            raise ActiveRecord::Rollback
          end
          users << user
          used_emails << user.email
        end
      end
    end
    users
  end

  # Should only be used from the console, it is to fix issues where free_trial subscriptions were canceled but no new plan was created
  def create_free_trial_subscription
    if self.subscriptions.first.free_trial? && self.subscriptions.first.current_status == 'canceled'
      previous_free_trial_sub = self.subscriptions.first
      currency = previous_free_trial_sub.subscription_plan.currency_id
      subscription_plan = SubscriptionPlan.in_currency(currency).where(price: 0.0).last
      new_sub = self.subscriptions.new(subscription_plan_id: subscription_plan.id, stripe_customer_id: self.stripe_customer_id, user_id: self.id)
      new_sub.save
    end
  end

  #User reactivating their account by adding a new subscription and card
  def resubscribe_account(user_id, new_plan_id, stripe_token, reactivate_account_url = nil, coupon_code)
    new_subscription_plan = SubscriptionPlan.find_by_id(new_plan_id)
    user = User.find_by_id(user_id)
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
    # only individual students are allowed to upgrade their plan
    unless user.individual_student?
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade'))
    end

    #### if we're here, then we're good to go.
    stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
    stripe_subscription = stripe_customer.subscriptions.create(plan: new_subscription_plan.stripe_guid, source: stripe_token)

    stripe_subscription.prorate = true
    stripe_subscription.coupon = coupon_code if coupon_code
    stripe_subscription.trial_end = 'now'
    result = stripe_subscription.save # saves it on stripe

    #### if we are here, the subscription creation on Stripe was successful
    #### Now we need to create a new Subscription in our DB.
    ActiveRecord::Base.transaction do
      new_sub = Subscription.new(
          user_id: user_id,
          corporate_customer_id: user.corporate_customer_id,
          subscription_plan_id: new_subscription_plan.id,
          complimentary: false,
          active: true,
          livemode: (result[:plan][:livemode]),
          current_status: result[:status],
      )
      # mass-assign-protected attributes
      new_sub.stripe_guid = result[:id]
      new_sub.next_renewal_date = Time.at(result[:current_period_end])
      new_sub.stripe_customer_id = user.stripe_customer_id
      new_sub.stripe_customer_data = Stripe::Customer.retrieve(self.stripe_customer_id).to_hash
      new_sub.save(validate: false)

      old_sub.update_attribute(:active, false)
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)

      if user.student_user_type_id == StudentUserType.default_no_access_user_type.id
        new_user_type_id = StudentUserType.default_sub_user_type.id
      elsif user.student_user_type_id == StudentUserType.default_product_user_type.id
        new_user_type_id = StudentUserType.default_sub_and_product_user_type.id
      else
        new_user_type_id = user.student_user_type_id
      end
      user.update_attributes(stripe_account_balance: stripe_customer.account_balance, student_user_type_id: new_user_type_id)

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

  #User reactivating their account by adding a new subscription and no card
  def resubscribe_account_without_token(user_id, new_plan_id, reactivate_account_url = nil)
    new_subscription_plan = SubscriptionPlan.find_by_id(new_plan_id)
    user = User.find_by_id(user_id)
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
    # only individual students are allowed to upgrade their plan
    unless user.individual_student?
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade'))
    end

    #### if we're here, then we're good to go.
    stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
    stripe_subscription = stripe_customer.subscriptions.create(plan: new_subscription_plan.stripe_guid)

    stripe_subscription.prorate = true
    stripe_subscription.trial_end = 'now'
    result = stripe_subscription.save # saves it on stripe

    #### if we are here, the subscription creation on Stripe was successful
    #### Now we need to create a new Subscription in our DB.
    ActiveRecord::Base.transaction do
      new_sub = Subscription.new(
          user_id: user_id,
          corporate_customer_id: user.corporate_customer_id,
          subscription_plan_id: new_subscription_plan.id,
          complimentary: false,
          active: true,
          livemode: (result[:plan][:livemode]),
          current_status: result[:status],
      )
      # mass-assign-protected attributes
      new_sub.stripe_guid = result[:id]
      new_sub.next_renewal_date = Time.at(result[:current_period_end])
      new_sub.stripe_customer_id = user.stripe_customer_id
      new_sub.stripe_customer_data = Stripe::Customer.retrieve(self.stripe_customer_id).to_hash
      new_sub.save(validate: false)

      old_sub.update_attribute(:active, false)
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
      if user.student_user_type_id == StudentUserType.default_no_access_user_type.id
        new_user_type_id = StudentUserType.default_sub_user_type.id
      elsif user.student_user_type_id == StudentUserType.default_product_user_type.id
        new_user_type_id = StudentUserType.default_sub_and_product_user_type.id
      else
        new_user_type_id = user.student_user_type_id
      end
      user.update_attributes(stripe_account_balance: stripe_customer.account_balance, student_user_type_id: new_user_type_id)

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

  def create_on_discourse
    if Rails.env.production? && !self.discourse_user
      username = self.first_name.to_s.downcase << ApplicationController.generate_random_number(3)
      DiscourseCreateUserWorker.perform_async(self.id, username, self.email, self.password) if self.individual_student?
    end
  end

  protected

  def add_guid
    self.guid ||= ApplicationController.generate_random_code(10)
    Rails.logger.debug "DEBUG: User#add_guid - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}"
  end

  def set_trial_limit_in_days
    if self.subscription_plan_category_id && self.subscription_plan_category.trial_period_in_days
      free_trial_days = self.subscription_plan_category.trial_period_in_days.to_i
    else
      free_trial_days = ENV["free_trial_days"].to_i
    end
    self.update_attributes(trial_limit_in_days: free_trial_days)
  end

end
