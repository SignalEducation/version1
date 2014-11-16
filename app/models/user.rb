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
#

class User < ActiveRecord::Base

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  # attr-accessible
  attr_accessible :email, :first_name, :last_name, :active, :address,
                  :country_id, :user_group_id, :password_reset_requested_at,
                  :password_reset_token, :password_reset_at, :stripe_customer_id,
                  :corporate_customer_id, :corporate_customer_user_group_id,
                  :operational_email_frequency,
                  :study_plan_notifications_email_frequency,
                  :falling_behind_email_alert_frequency, :marketing_email_frequency,
                  :marketing_email_permission_given_at,
                  :blog_notification_email_frequency,
                  :forum_notification_email_frequency, :password,
                  :password_confirmation, :current_password

  # Constants
  EMAIL_FREQUENCIES = %w(off daily weekly monthly)

  # relationships
  # todo belongs_to :corporate_customer
  # todo belongs_to :corporate_customer_user_group
  # todo belongs_to :country
  has_many :course_modules, foreign_key: :tutor_id
  has_many :course_module_element_user_logs
  has_many :course_module_element_videos, foreign_key: :tutor_id
  has_many :quiz_attempts
  has_many :institution_users
  has_many :subscriptions
  has_many :subscription_payment_cards
  has_many :subscription_transactions
  has_many :student_exam_tracks
  has_many :user_exam_level
  has_many :user_notifications
  belongs_to :user_group

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

  # callbacks
  before_validation :de_activate_user, on: :create, if: '!Rails.env.test?'
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_group_id, :last_name, :first_name, :email) }

  # class methods
  def self.find_and_activate(activation_code)
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
        OperationalMailer.reset_your_password(user).deliver
      end
    end
  end

  def self.finish_password_reset_process(reset_token, new_password, new_password_confirmation)
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
    if options[:password] == options[:password_confirmation] && options[:password].to_s != '' && self.valid_password?(options[:current_password].to_s) && options[:current_password].to_s != ''
      self.update_attributes(
              password: options[:password],
              password_confirmation: options[:password_confirmation]
      )
    else
      false
    end
  end

  def destroyable?
    !self.admin? && self.course_module_element_user_logs.empty? && self.course_module_element_videos.empty? && self.institution_users.empty? && self.course_modules.empty? && self.subscriptions.empty? && self.subscription_payment_cards.empty? && self.subscription_transactions.empty? && self.quiz_attempts.empty? && self.student_exam_tracks.empty? && self.user_exam_level.empty? && self.user_notifications.empty?
  end

  def full_name
    self.first_name.titleize + ' ' + self.last_name.gsub('O\'','O\' ').titleize.gsub('O\' ','O\'')
  end

  def tutor
    self.user_group.try(:tutor)
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def de_activate_user
    self.active = false
    self.account_activated_at = nil
    self.account_activation_code = ApplicationController::generate_random_code(20)
  end

end
