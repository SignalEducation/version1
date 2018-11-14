# == Schema Information
#
# Table name: paypal_webhooks
#
#  id           :integer          not null, primary key
#  guid         :string
#  event_type   :string
#  payload      :text
#  processed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class PaypalWebhook < ActiveRecord::Base
  serialize :payload, Hash
  # attr-accessible
  attr_accessible :guid, :payload, :processed_at

  # Constants

  # relationships

  # validation
  validates :guid, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :event_type, :payload, presence: true

  # callbacks
  before_destroy :check_dependencies

  # class methods

  # instance methods
  def destroyable?
    false
  end

  private

  def check_dependencies
    unless destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end
end
