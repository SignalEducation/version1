# == Schema Information
#
# Table name: user_activity_logs
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  session_guid    :string(255)
#  signed_in       :boolean          default(FALSE), not null
#  original_uri    :string(255)
#  controller_name :string(255)
#  action_name     :string(255)
#  params          :text
#  alert_level     :integer          default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

class UserActivityLog < ActiveRecord::Base

  include LearnSignalModelExtras
  serialize :params

  # attr-accessible
  attr_accessible :user_id, :session_guid, :signed_in, :original_uri, :controller_name,
                  :action_name, :params, :alert_level

  # Constants
  ALERT_LEVELS = %w(normal warning danger severe)
  # 0=normal, 1=warning, 2=danger, 3=severe

  # relationships
  belongs_to :user

  # validation
  validates :user_id, allow_blank: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :original_uri, presence: true
  validates :controller_name, presence: true
  validates :action_name, presence: true
  validates :alert_level, presence: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0,
                           less_than_or_equal_to: 3}

  # callbacks
  after_create :add_to_rails_logger

  # scopes
  scope :all_in_order, -> { order(:user_id, created_at: :desc) }

  # class methods

  # instance methods
  def destroyable?
    !Rails.env.production?
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
