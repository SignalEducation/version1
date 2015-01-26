# == Schema Information
#
# Table name: user_activity_logs
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  session_guid     :string(255)
#  signed_in        :boolean          default(FALSE), not null
#  original_uri     :text
#  controller_name  :string(255)
#  action_name      :string(255)
#  params           :text
#  alert_level      :integer          default(0)
#  created_at       :datetime
#  updated_at       :datetime
#  ip_address       :string(255)
#  browser          :string(255)
#  operating_system :string(255)
#  phone            :boolean          default(FALSE), not null
#  tablet           :boolean          default(FALSE), not null
#  computer         :boolean          default(FALSE), not null
#  guid             :string(255)
#

class UserActivityLog < ActiveRecord::Base

  include LearnSignalModelExtras
  serialize :params

  # attr-accessible
  attr_accessible :user_id, :session_guid, :signed_in, :original_uri, :controller_name,
                  :action_name, :params, :ip_address, :alert_level,
                  :browser, :operating_system, :phone, :tablet, :computer, :http_user_agent,
                  :guid

  # Constants
  ALERT_LEVELS = %w(normal warning danger severe)
  # 0=normal, 1=warning, 2=danger, 3=severe

  # relationships
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

  def http_user_agent=(agent)
    # todo: Dan's mac / Safari:
    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/600.2.5 (KHTML, like Gecko) Version/8.0.2 Safari/600.2.5
    # todo: Dan's mac / Opera:
    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36 OPR/26.0.1656.60
    # todo: Dan's mac / Chrome:
    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36
    # todo: Dan's mac / Firefox:
    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:33.0) Gecko/20100101 Firefox/33.0
    # todo: Dan's iPhone / Safari
    # Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B440 Safari/600.1.4
    # todo: Dan's iPad2 / Safari
    # Mozilla/5.0 (iPad; CPU OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B410 Safari/600.1.4

    # result =~ /Safari/

    self.browser ||= truncate(agent, length: 255)
    self.operating_system ||= truncate(agent, length: 255)
    self.phone ||=
    self.tablet ||=
    self.computer ||= false
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

end
