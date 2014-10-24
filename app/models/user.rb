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
  attr_accessible :email, :first_name, :last_name, :active, :address, :country_id, :user_group_id, :password_reset_requested_at, :password_reset_token, :password_reset_at, :stripe_customer_id, :corporate_customer_id, :corporate_customer_user_group_id, :operational_email_frequency, :study_plan_notifications_email_frequency, :falling_behind_email_alert_frequency, :marketing_email_frequency, :marketing_email_permission_given_at, :blog_notification_email_frequency, :forum_notification_email_frequency

  # Constants
  EMAIL_FREQUENCIES = %w(off daily weekly monthly)

  # relationships
  # todo belongs_to :corporate_customer
  # todo belongs_to :corporate_customer_user_group
  # todo belongs_to :country
  # todo belongs_to :stripe_customer
  # todo belongs_to :user_group

  # validation
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 30}
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :crypted_password, presence: true
  validates :password_salt, presence: true
  validates :persistence_token, presence: true
  validates :perishable_token, presence: true
  validates :single_access_token, presence: true
  validates :login_count, presence: true
  validates :failed_login_count, presence: true
  validates :last_request_at, presence: true
  validates :current_login_at, presence: true
  validates :last_login_at, presence: true
  validates :current_login_ip, presence: true
  validates :last_login_ip, presence: true
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
  before_validation :de_activate_user, on: :create
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:email) }

  # class methods

  # instance methods
  def destroyable?
    true
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
    self.account_activation_code = ApplicationController::generate_random_code(20)
  end

end
