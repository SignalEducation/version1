# == Schema Information
#
# Table name: users
#
#  id                                       :integer          not null, primary key
#  email                                    :string(255)
#  first_name                               :string(255)
#  last_name                                :string(255)
#  address                                  :text
#  country_id                               :integer
#  crypted_password                         :string(128)      default(""), not null
#  password_salt                            :string(128)      default(""), not null
#  persistence_token                        :string(255)
#  perishable_token                         :string(128)
#  single_access_token                      :string(255)
#  login_count                              :integer          default(0)
#  failed_login_count                       :integer          default(0)
#  last_request_at                          :datetime
#  current_login_at                         :datetime
#  last_login_at                            :datetime
#  current_login_ip                         :string(255)
#  last_login_ip                            :string(255)
#  account_activation_code                  :string(255)
#  account_activated_at                     :datetime
#  active                                   :boolean          default(FALSE), not null
#  user_group_id                            :integer
#  password_reset_requested_at              :datetime
#  password_reset_token                     :string(255)
#  password_reset_at                        :datetime
#  stripe_customer_id                       :string(255)
#  corporate_customer_id                    :integer
#  corporate_customer_user_group_id         :integer
#  operational_email_frequency              :string(255)
#  study_plan_notifications_email_frequency :string(255)
#  falling_behind_email_alert_frequency     :string(255)
#  marketing_email_frequency                :string(255)
#  marketing_email_permission_given_at      :datetime
#  blog_notification_email_frequency        :string(255)
#  forum_notification_email_frequency       :string(255)
#  created_at                               :datetime
#  updated_at                               :datetime
#  locale                                   :string(255)
#  guid                                     :string(255)
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
                  :corporate_customer_id, :corporate_customer_user_group_id,
                  :operational_email_frequency,
                  :study_plan_notifications_email_frequency,
                  :falling_behind_email_alert_frequency, :marketing_email_frequency,
                  :marketing_email_permission_given_at,
                  :blog_notification_email_frequency,
                  :forum_notification_email_frequency, :password,
                  :password_confirmation, :current_password, :locale,
                  :subscriptions_attributes,
                  :login_count, :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip, :account_activated_at, :account_activation_code, :address, :guid # todo see ticket 277

  # Constants
  EMAIL_FREQUENCIES = %w(off daily weekly monthly)
  LOCALES = %w(en)

  # relationships
  belongs_to :corporate_customer
             # employed by the corporate customer
  has_many :owned_corporate_accounts,
           class_name: 'CorporateCustomer', foreign_key: :owner_id
           # owns these corporate accounts (usually one, but can be more)
  # todo belongs_to :corporate_customer_user_group
  belongs_to :country
  has_many :course_modules, foreign_key: :tutor_id
  has_many :course_module_element_user_logs
  has_many :forum_posts
  has_many :forum_post_concerns
  has_many :forum_topic_users
  has_many :institution_users
  has_many :invoices
  has_many :quiz_attempts
  has_many :created_static_pages, class_name: 'StaticPage', foreign_key: :created_by
  has_many :updated_static_pages, class_name: 'StaticPage', foreign_key: :updated_by
  has_many :subscriptions
  has_many :subscription_payment_cards
  has_many :subscription_transactions
  has_many :student_exam_tracks
  has_many :user_activity_logs
  belongs_to :user_group
  has_many :user_exam_level
  has_many :user_likes
  has_many :user_notifications

  accepts_nested_attributes_for :subscriptions

  # validation
  validates :email, presence: true, uniqueness: true,
            length: {within: 7..40}#,
            #format: {with:  /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i,
            #         message: 'must be a valid email address.'}

  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 30}
  validates :password, presence: true, length: {minimum: 6}, on: :create
  validates_confirmation_of :password, on: :create
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_group_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_user_group_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :operational_email_frequency,
            inclusion: {in: EMAIL_FREQUENCIES}
  validates :study_plan_notifications_email_frequency,
            inclusion: {in: EMAIL_FREQUENCIES}
  validates :falling_behind_email_alert_frequency,
            inclusion: {in: EMAIL_FREQUENCIES}
  validates :marketing_email_frequency,
            inclusion: {in: EMAIL_FREQUENCIES}
  validates :blog_notification_email_frequency,
            inclusion: {in: EMAIL_FREQUENCIES}
  validates :forum_notification_email_frequency,
            inclusion: {in: EMAIL_FREQUENCIES}
  validates :locale, inclusion: {in: LOCALES}

  # callbacks
  before_validation :set_defaults, on: :create
  before_validation { squish_fields(:email, :first_name, :last_name) }
  # before_validation :de_activate_user, on: :create, if: '!Rails.env.test?'
  before_create :add_guid
  after_create :set_stripe_customer_id

  # scopes
  scope :all_in_order, -> { order(:user_group_id, :last_name, :first_name, :email) }

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

  def self.start_password_reset_process(the_email_address)
    if the_email_address.to_s.length > 5 # a@b.co
      user = User.where(email: the_email_address.to_s).first
      if user
        user.update_attributes(password_reset_requested_at: Proc.new{Time.now}.call,        password_reset_token: ApplicationController::generate_random_code(20), active: false)
        Mailers::OperationalMailers::ResetYourPasswordWorker.perform_async(user.id)
      end
    end
  end

  def self.finish_password_reset_process(reset_token, new_password,
          new_password_confirmation)
    if reset_token.to_s.length == 20 && new_password.to_s.length > 5 && new_password_confirmation.to_s.length > 5 && new_password.to_s == new_password_confirmation.to_s
      user = User.where(password_reset_token: reset_token.to_s, active: false).first
      if user
        if user.update_attributes(password: new_password.to_s, password_confirmation: new_password_confirmation.to_s, active: true, password_reset_token: nil, password_reset_requested_at: nil, password_reset_at: Proc.new{Time.now}.call)
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

  # instance methods
  def admin?
    self.user_group.try(:site_admin)
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
        self.forum_posts.empty? &&
        self.forum_post_concerns.empty? &&
        self.forum_topic_users.empty? &&
        self.institution_users.empty? &&
        self.invoices.empty? &&
        self.owned_corporate_accounts.empty? &&
        self.quiz_attempts.empty? &&
        self.student_exam_tracks.empty? &&
        self.subscriptions.empty? &&
        self.subscription_payment_cards.empty? &&
        self.subscription_transactions.empty? &&
        self.user_exam_level.empty? &&
        self.user_likes.empty? &&
        self.user_notifications.empty? &&
        self.created_static_pages.empty? &&
        self.updated_static_pages.empty? &&
        self.user_activity_logs.empty?
  end

  def frequent_forum_user?
    self.forum_posts.count > 100
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

  protected

  def add_guid
    self.guid = ApplicationController.generate_random_code(10)
  end

  def set_defaults
    self.marketing_email_permission_given_at ||= Proc.new{Time.now}.call
    self.operational_email_frequency ||= 'weekly'
    self.study_plan_notifications_email_frequency ||= 'off'
    self.falling_behind_email_alert_frequency ||= 'off'
    self.marketing_email_frequency ||= 'off'
    self.blog_notification_email_frequency ||= 'off'
    self.forum_notification_email_frequency ||= 'off'
  end

  def set_stripe_customer_id
    if self.subscriptions.length > 0
      self.update_attribute(:stripe_customer_id, self.subscriptions.first.stripe_customer_id)
    end
  end

end
