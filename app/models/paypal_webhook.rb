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
#  verified     :boolean          default(TRUE)
#

class PaypalWebhook < ActiveRecord::Base
  serialize :payload, Hash

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
    true
  end

  def process_sale_completed
    if (invoice = Invoice.build_from_paypal_data(payload)) && invoice.valid?
      invoice.update!(paid: true, payment_closed: true)
      PaypalService.new.update_next_billing_date(invoice.subscription)
      update!(processed_at: Time.now)
      invoice.subscription.update!(paypal_status: 'Active') unless invoice.subscription.paypal_status == 'Active'
    else
      update!(verified: false)
    end
  end

  def process_sale_denied
    if invoice = Invoice.build_from_paypal_data(payload)
      invoice.update!(paid: false, payment_closed: false)
      invoice.increment!(:attempt_count)
      update!(processed_at: Time.now)
      subscription = Subscription.find_by(paypal_subscription_guid: payload['resource']['billing_agreement_id'])
      subscription.record_error!
    else
      update!(verified: false)
    end
  end

  def process_subscription_cancelled
    if subscription = Subscription.find_by(paypal_subscription_guid: payload['resource']['id'])
      subscription.schedule_paypal_cancellation
    else
      update!(verified: false)
    end
  end

  private

  def check_dependencies
    unless destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end
end
