# == Schema Information
#
# Table name: users
#
#  id                                       :integer          not null, primary key
#  email                                    :string
#  first_name                               :string
#  last_name                                :string
#  address                                  :text
#  country_id                               :integer
#  crypted_password                         :string(128)      default(""), not null
#  password_salt                            :string(128)      default(""), not null
#  persistence_token                        :string
#  perishable_token                         :string(128)
#  single_access_token                      :string
#  login_count                              :integer          default(0)
#  failed_login_count                       :integer          default(0)
#  last_request_at                          :datetime
#  current_login_at                         :datetime
#  last_login_at                            :datetime
#  current_login_ip                         :string
#  last_login_ip                            :string
#  account_activation_code                  :string
#  account_activated_at                     :datetime
#  active                                   :boolean          default(FALSE), not null
#  user_group_id                            :integer
#  password_reset_requested_at              :datetime
#  password_reset_token                     :string
#  password_reset_at                        :datetime
#  stripe_customer_id                       :string
#  corporate_customer_id                    :integer
#  operational_email_frequency              :string
#  study_plan_notifications_email_frequency :string
#  falling_behind_email_alert_frequency     :string
#  marketing_email_frequency                :string
#  marketing_email_permission_given_at      :datetime
#  blog_notification_email_frequency        :string
#  forum_notification_email_frequency       :string
#  created_at                               :datetime
#  updated_at                               :datetime
#  locale                                   :string
#  guid                                     :string
#  trial_ended_notification_sent_at         :datetime
#  crush_offers_session_id                  :string
#  subscription_plan_category_id            :integer
#  employee_guid                            :string
#  password_change_required                 :boolean
#  session_key                              :string
#  first_description                        :text
#  second_description                       :text
#  wistia_url                               :string
#  personal_url                             :string
#  name_url                                 :string
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
                  :address, :first_description, :second_description, :wistia_url, :personal_url, :name_url

  # Constants
  EMAIL_FREQUENCIES = %w(off daily weekly monthly)
  LOCALES = %w(en)
  SORT_OPTIONS = %w(user_group name email created)

  # relationships
  belongs_to :corporate_customer
             # employed by the corporate customer
  belongs_to :country
  has_many :course_modules, foreign_key: :tutor_id
  has_many :course_module_element_user_logs
  has_many :subject_courses, foreign_key: :tutor_id
  has_many :invoices
  has_many :quiz_attempts
  has_many :question_banks
  has_many :created_static_pages, class_name: 'StaticPage', foreign_key: :created_by
  has_many :updated_static_pages, class_name: 'StaticPage', foreign_key: :updated_by
  has_many :subscriptions, -> { order(:id) }, inverse_of: :user
  has_many :subscription_payment_cards
  has_many :subscription_transactions
  has_many :student_exam_tracks
  has_many :user_activity_logs
  belongs_to :user_group
  has_many :user_notifications
  has_one :referral_code
  has_one :referred_signup
  belongs_to :subscription_plan_category
  has_and_belongs_to_many :corporate_groups

  accepts_nested_attributes_for :subscriptions

  # validation
  validates :email, presence: true, uniqueness: true,
            length: {within: 7..40}
            #TODO
            #format: {with:  /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i,
            #         message: 'must be a valid email address.'}
  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 30}
  validates :password, presence: true, length: {minimum: 6, maximum: 255}, on: :create
  validates_confirmation_of :password, on: :create
  validates_confirmation_of :password, if: '!password.blank?'
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_group_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_id,
            numericality: { unless: -> { corporate_customer_id.nil? }, only_integer: true, greater_than: 0 },
            presence: { if: -> { ug = UserGroup.find_by_id(user_group_id); ug.try(:corporate_customer) || ug.try(:corporate_student) } }
  validates :locale, inclusion: {in: LOCALES}
  validates :employee_guid, allow_nil: true,
            uniqueness: { scope: :corporate_customer_id }

  # callbacks
  before_validation :set_defaults, on: :create
  before_validation { squish_fields(:email, :first_name, :last_name) }
  # before_validation :de_activate_user, on: :create, if: '!Rails.env.test?'
  before_create :add_guid
  after_create :set_stripe_customer_id, :alias_on_mixpanel
  after_save :create_on_mixpanel, if: '!Rails.env.test?'

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
    if user
      user.account_activated_at = Proc.new{Time.now}.call
      user.account_activation_code = nil
      user.active = true
      user.save!
    end
    return user
  end

  def self.start_password_reset_process(the_email_address, root_url)
    if the_email_address.to_s.length > 5 # a@b.co
      user = User.where(email: the_email_address.to_s).first
      if user
        user.update_attributes(
                password_reset_requested_at: Proc.new{Time.now}.call,
                password_reset_token: ApplicationController::generate_random_code(20),
                active: false)
        MandrillWorker.perform_async(user.id, 'send_password_reset_email', "#{root_url}/reset_password/#{user.password_reset_token}")
      end
    end
  end

  def self.finish_password_reset_process(reset_token, new_password,
          new_password_confirmation)
    if reset_token.to_s.length == 20 && new_password.to_s.length > 5 && new_password_confirmation.to_s.length > 5 && new_password.to_s == new_password_confirmation.to_s
      user = User.where(password_reset_token: reset_token.to_s, active: false).first
      if user
        if user.update_attributes(password: new_password.to_s,
                                  password_confirmation: new_password_confirmation.to_s,
                                  active: true, password_reset_token: nil,
                                  password_reset_requested_at: nil,
                                  password_reset_at: Time.now)
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

  def assign_anonymous_logs_to_user(session_guid)
    model_list = [CourseModuleElementUserLog, UserActivityLog, StudentExamTrack]
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

  def corporate_student?
    self.user_group.try(:corporate_student)
  end

  def de_activate_user
    self.active = false
    self.account_activated_at = nil
    self.account_activation_code = ApplicationController::generate_random_code(20)
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
        self.user_notifications.empty? &&
        self.created_static_pages.empty? &&
        self.updated_static_pages.empty? &&
        self.user_activity_logs.empty?
  end

  def full_name
    self.first_name.titleize + ' ' + self.last_name.gsub('O\'','O\' ').titleize.gsub('O\' ','O\'')
  end

  def individual_student?
    self.user_group.try(:individual_student) && self.corporate_customer_id.to_i == 0
  end

  def tutor?
    self.user_group.try(:tutor)
  end

  def set_original_mixpanel_alias_id(mixpanel_alias_id)
    @mixpanel_alias_id = mixpanel_alias_id
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

  protected

  def add_guid
    self.guid ||= ApplicationController.generate_random_code(10)
    Rails.logger.debug "DEBUG: User#add_guid - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}"
  end

  def create_on_mixpanel
    plan_name = 'none'
    if self.subscriptions.last
      if ['canceled', 'canceled-pending'].include?(self.subscriptions.last.current_status)
        plan_name = 'Cancelled'
      else
        plan_name = self.subscriptions.last.subscription_plan.description.strip.gsub("\r\n",', ')
      end
    end
    MixpanelUserUpdateWorker.perform_async(
      self.id, self.first_name, self.last_name, self.email,
      self.user_group.try(:name),
      plan_name,
      self.guid, self.country.iso_code
    )
  end

  def set_defaults
    Rails.logger.debug "DEBUG: User#set_defaults - START at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}"
    self.marketing_email_permission_given_at ||= Proc.new{Time.now}.call
    self.operational_email_frequency ||= 'weekly'
    self.study_plan_notifications_email_frequency ||= 'off'
    self.falling_behind_email_alert_frequency ||= 'off'
    self.marketing_email_frequency ||= 'off'
    self.blog_notification_email_frequency ||= 'off'
    self.forum_notification_email_frequency ||= 'off'
    Rails.logger.debug "DEBUG: User#set_defaults - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}}"
  end

  def set_stripe_customer_id
    Rails.logger.debug "DEBUG: User#set_stripe_customer_id - START at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}}"
    if self.subscriptions.length > 0
      self.update_attribute(:stripe_customer_id, self.subscriptions.first.stripe_customer_id)
    end
    Rails.logger.debug "DEBUG: User#set_stripe_customer_id - FINISH at #{Proc.new{Time.now}.call.strftime('%H:%M:%S.%L')}}"
  end

  def alias_on_mixpanel
    return unless @mixpanel_alias_id
    tracker = Mixpanel::Tracker.new(ENV['mixpanel_key'])
    tracker.alias(self.id, @mixpanel_alias_id)
    # Alias is synchronous call and, as suggested by Mixpanel support team, we should
    # wait after calling alias with other calls to Mixpanel that will use new user id.
    # Since this model calls Mixpanel on each change in order to prevent data mess onblur
    # Mixpanel side we are waiting 1 second here before we go on.
    sleep(1)
  end
end
