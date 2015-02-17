# == Schema Information
#
# Table name: user_activity_logs
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  session_guid              :string(255)
#  signed_in                 :boolean          default(FALSE), not null
#  original_uri              :text
#  controller_name           :string(255)
#  action_name               :string(255)
#  params                    :text
#  alert_level               :integer          default(0)
#  created_at                :datetime
#  updated_at                :datetime
#  ip_address                :string(255)
#  browser                   :string(255)
#  operating_system          :string(255)
#  phone                     :boolean          default(FALSE), not null
#  tablet                    :boolean          default(FALSE), not null
#  computer                  :boolean          default(FALSE), not null
#  guid                      :string(255)
#  ip_address_id             :integer
#  browser_version           :string(255)
#  raw_user_agent            :string(255)
#  session_landing_page      :string(255)
#  post_sign_up_redirect_url :string(255)
#

class UserActivityLog < ActiveRecord::Base

  include LearnSignalModelExtras
  serialize :params, Hash

  # attr-accessible
  attr_accessible :user_id, :session_guid, :signed_in, :original_uri,
                  :controller_name,
                  :action_name, :params, :ip_address, :alert_level,
                  :browser, :operating_system, :phone, :tablet, :computer,
                  :guid, :raw_user_agent

  # Constants
  ALERT_LEVELS = %w(normal warning danger severe)
  # 0=normal, 1=warning, 2=danger, 3=severe

  # relationships
  belongs_to :tracked_ip_address, class_name: 'IpAddress',
             foreign_key: :ip_address_id
  belongs_to :user

  # validation
  validates :user_id, allow_blank: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, presence: true
  validates :original_uri, presence: true
  validates :controller_name, presence: true
  validates :action_name, presence: true
  validates :ip_address, presence: true
  validates :alert_level, presence: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0,
                           less_than_or_equal_to: 3}
  validates :guid, presence: true, uniqueness: true

  # callbacks
  before_validation :process_user_agent
  before_validation :track_ip_address
  after_create :add_to_rails_logger

  # scopes
  scope :all_in_order, -> { order(created_at: :desc) }
  scope :for_session_guid, lambda { |the_guid| where(session_guid: the_guid) }
  scope :for_unknown_users, -> { where(user_id: nil) }

  # class methods
  def self.assign_user_to_session_guid(the_user_id, the_session_guid)
    # activate this with the following:
    # UserActivityLog.assign_user_to_session_guid(123, 'abcde123')
    UserActivityLog.for_session_guid(the_session_guid).for_unknown_users.update_all(user_id: the_user_id)
  end

  def self.for_user_or_session(the_user_id, the_session_guid)
    if the_user_id
      where(user_id: the_user_id)
    else
      where(session_guid: the_session_guid, user_id: nil)
    end
  end

  # instance methods
  def destroyable?
    !Rails.env.production?
  end

  def display_class
    ['success','info','warning','danger'][self.alert_level]
  end

  def process_user_agent
    browser = Browser.new(ua: self.raw_user_agent.to_s[0..255])
    self.browser = browser.name
    self.browser_version = browser.version
    self.operating_system =
      if browser.mac?
        'Macintosh'
      elsif browser.windows?
        'Windows'
      elsif browser.name == 'iPad' || browser.name == 'iPhone'
        browser.name
      elsif browser.platform == :linux && (browser.mobile? || browser.tablet?)
        'Android'
      else
        browser.platform.to_s
      end
    self.browser = 'Safari' if self.browser == 'iPhone' || self.browser == 'iPad'
    self.phone = browser.mobile?
    self.tablet = browser.tablet?
    self.computer = browser.mac? || browser.windows?
    self.alert_level += 1 if self.operating_system == 'other'
    self.alert_level += 1 unless browser.known?
  end

  protected

  def add_to_rails_logger
    # 0=normal, 1=warning, 2=danger, 3=severe
    message = "UserActivity alert:#{ALERT_LEVELS[self.alert_level]}. ID: #{self.id}. See: /user_activity_logs/#{self.id} for details"
    case self.alert_level
    when 0
      Rails.logger.debug message
    when 1
      Rails.logger.warn message
    when 2
      Rails.logger.error message
    else # where 3 or above
      Rails.logger.fatal message
    end
  end

  def track_ip_address
    self.ip_address_id = IpAddress.where(ip_address: self.ip_address).first_or_create.id
  end

end
