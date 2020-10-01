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
#  verified     :boolean          default("true")
#

class PaypalWebhook < ApplicationRecord
  serialize :payload, Hash

  validates :guid, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :event_type, :payload, presence: true

  before_destroy :check_dependencies

  def destroyable?
    true
  end

  def process_sale_completed
    if (invoice = Invoice.build_from_paypal_data(payload)) && invoice.valid?
      invoice.update!(paid: true, payment_closed: true)
      PaypalSubscriptionsService.new(invoice.subscription).update_next_billing_date
      update!(processed_at: Time.zone.now)
      invoice.subscription.update!(paypal_status: 'Active') unless invoice.subscription.paypal_status == 'Active'
    else
      update!(verified: false)
    end
  end

  def process_sale_denied
    if (invoice = Invoice.build_from_paypal_data(payload))
      invoice.update!(paid: false, payment_closed: false)
      invoice.increment!(:attempt_count)
      update!(processed_at: Time.zone.now)
      update_failed_subscription
    else
      update!(verified: false)
    end
  end

  def verify_subscription(guid)
    if (subscription = Subscription.find_by(paypal_subscription_guid: guid))
      update!(verified: true)
      yield(subscription) if block_given?
    else
      update!(verified: false)
    end
  end

  def process_subscription_cancelled
    verify_subscription(payload['resource']['id']) do |subscription|
      subscription.schedule_paypal_cancellation unless subscription.pending_cancellation?
    end
  end

  def process_subscription_suspended
    verify_subscription(payload['resource']['id']) do |subscription|
      subscription.paypal_suspended unless subscription.paused?
    end
  end

  def reprocess
    PaypalWebhookReprocessWorker.perform_async(id)
  end

  private

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end

  def paypal_failed_attachments(subscription)
    [{ fallback: "#{subscription.user.name} has a failed PayPal subscription payment",
       title: "<https://www.paypal.com/billing/subscriptions/#{payload['resource']['billing_agreement_id']}|#{subscription.user.name}> has a failed PayPal subscription payment.",
       title_link: "https://www.paypal.com/billing/subscriptions/#{payload['resource']['billing_agreement_id']}",
       color: '#7CD197',
       footer: 'PayPal',
       ts: Time.zone.parse(payload['create_time']).to_i }]
  end

  def update_failed_subscription
    subscription = Subscription.find_by(paypal_subscription_guid: payload['resource']['billing_agreement_id'])
    subscription.record_error!
    SlackService.new.notify_channel('payments', paypal_failed_attachments(subscription), icon_emoji: 'rotating_light') if Rails.env.production?
  end
end
