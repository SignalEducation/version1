# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string(255)
#  api_version   :string(255)
#  payload       :text
#  processed     :boolean          default(FALSE), not null
#  processed_at  :datetime
#  error         :boolean          default(FALSE), not null
#  error_message :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class StripeApiEvent < ActiveRecord::Base

  serialize :payload, Hash

  # attr-accessible
  attr_accessible :guid, :api_version, :payload, :processed, :error

  # Constants

  # relationships

  # validation
  validates :guid, presence: true, uniqueness: true
  validates :api_version, presence: true
  validates :payload, presence: true
  validate :payload_is_valid

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:guid) }

  # class methods

  # instance methods
  def destroyable?
    !self.processed
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def payload_is_valid
    true
  end

end
