# frozen_string_literal: true

# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string(255)
#  api_version   :string(255)
#  payload       :text
#  processed     :boolean          default("false"), not null
#  processed_at  :datetime
#  error         :boolean          default("false"), not null
#  error_message :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class StripeApiEvent < ApplicationRecord
  attr_accessor :account_url

  serialize :payload, Hash

  # CONSTANTS ==================================================================

  KNOWN_API_VERSIONS = %w[2015-02-18 2017-06-05 2017-05-25 2019-05-16].freeze
  KNOWN_PAYLOAD_TYPES = %w[invoice.created invoice.payment_succeeded invoice.payment_failed
                           customer.subscription.deleted charge.failed charge.succeeded
                           charge.refunded coupon.updated invoice.payment_action_required invoice.upcoming].freeze
  DELAYED_TYPES = %w[invoice.payment_succeeded invoice.payment_failed
                     charge.failed charge.succeeded invoice.payment_action_required].freeze

  # RELATIONSHIPS ==============================================================

  has_many :charges, dependent: :nullify

  # VALIDATIONS ================================================================

  validates :guid, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :api_version,
            inclusion: { in: KNOWN_API_VERSIONS }, length: { maximum: 255 }
  validates :payload, presence: true

  # CALLBACKS ==================================================================

  before_validation :set_default_values, on: :create
  before_validation :sync_data_from_stripe, on: :create
  after_create :disseminate_payload
  before_destroy :check_dependencies

  # SCOPES =====================================================================

  scope :all_in_order, -> { order(id: :desc) }

  # CLASS METHODS ==============================================================

  def self.known_api_version?(version)
    KNOWN_API_VERSIONS.include?(version)
  end

  def self.known_payload_type?(type)
    KNOWN_PAYLOAD_TYPES.include?(type)
  end

  def self.processing_delay(event_type)
    DELAYED_TYPES.include?(event_type) ? 1.minute : 10.seconds
  end

  def self.should_process?(event_json)
    known_payload_type?(event_json['type']) &&
      known_api_version?(event_json['api_version']) &&
      where(guid: event_json['id']).empty?
  end

  # INSTANCE METHODS ===========================================================

  def destroyable?
    !processed
  end

  def disseminate_payload
    return unless payload&.is_a?(Hash) && payload[:type].present?

    if Invoice::STRIPE_LIVE_MODE == payload[:livemode]
      webhook_object = payload[:data][:object]
      case payload[:type]
      when 'invoice.created'
        process_invoice_created(payload)
      when 'invoice.payment_succeeded'
        process_invoice_payment_success(webhook_object[:id])
      when 'invoice.payment_failed'
        process_invoice_payment_failed(
          webhook_object[:customer], webhook_object[:next_payment_attempt],
          webhook_object[:subscription], webhook_object[:id]
        )
      when 'invoice.payment_action_required'
        process_payment_action_required(webhook_object[:id], webhook_object[:subscription])
      when 'invoice.updated'
        process_invoice_update(webhook_object[:id])
      when 'customer.subscription.deleted'
        process_customer_subscription_deleted(webhook_object[:customer],
                                              webhook_object[:id], webhook_object[:cancel_at_period_end])
      when 'charge.succeeded'
        process_charge_event(webhook_object[:invoice], webhook_object)
      when 'charge.failed'
        process_charge_event(webhook_object[:invoice], webhook_object)
      when 'charge.refunded'
        process_charge_refunded(webhook_object[:invoice], webhook_object)
      when 'coupon.updated'
        process_coupon_updated(webhook_object[:id])
      else
        log_process_error "Unknown event type - #{payload[:type]}"
      end
    else
      Rails.logger.error('ERROR: StripeAPIEvent#disseminate_payload: ' \
        'LiveMode of message incompatible with Rails.env. StripeMode:' \
        "#{Invoice::STRIPE_LIVE_MODE}. Rails.env.#{Rails.env} -v- payload:" \
        "#{payload}.")
      log_process_error('Livemode incorrect')
    end
  rescue => e
    Rails.logger.error("ERROR: StripeApiEvent#sync_data_from_stripe: #{e.inspect}.")
    assign_attributes(error: true, error_message: "Error: #{e.inspect}.")
    if Rails.env.production?
      SlackService.new.notify_channel('payments',
                                      webhook_failed_notification(e, webhook_object[:id]),
                                      icon_emoji: 'rotating_light')
    end
  end

  def sync_data_from_stripe
    if guid && (response = Stripe::Event.retrieve(guid))
      assign_attributes(payload: response.to_hash)
    else
      assign_attributes(error: true, payload: {},
                        error_message: I18n.t('models.stripe_api_event.missing_guid'))
    end
  rescue Stripe::StripeError => e
    Rails.logger.error("ERROR: StripeApiEvent#sync_data_from_stripe: #{e.inspect}.")
    assign_attributes(error: true, error_message: "Error: #{e.inspect}.")
    if Rails.env.production?
      SlackService.new.notify_channel('payments',
                                      webhook_failed_notification(e, guid),
                                      icon_emoji: 'rotating_light')
    end
  end

  protected

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
  end

  def process_invoice_created(payload)
    invoice = Invoice.build_from_stripe_data(payload[:data][:object])

    if invoice && invoice.errors.count.zero?
      update!(processed: true, processed_at: Time.zone.now, error: false, error_message: nil)
    else
      log_process_error(invoice&.errors&.inspect || 'Error creating invoice')
    end
  end

  def process_invoice_update(stripe_inv_id)
    invoice = Invoice.find_by(stripe_guid: stripe_inv_id)

    invoice.update_from_stripe(stripe_inv_id)
  end

  def process_invoice_payment_success(stripe_inv_id)
    if (invoice = Invoice.find_by(stripe_guid: stripe_inv_id))
      invoice.update_from_stripe(stripe_inv_id)
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
      invoice.subscription.update_invoice_payment_success
      invoice.send_receipt(account_url)
    else
      log_process_error("Error finding Invoice by - #{stripe_inv_id}. " \
                        'InvoicePaymentSucceeded Event')
    end
  end

  def process_invoice_payment_failed(stripe_customer_guid, stripe_next_attempt, stripe_subscription_guid, stripe_invoice_guid)
    user = User.find_by(stripe_customer_id: stripe_customer_guid)
    subscription = Subscription.in_reverse_created_order.find_by(stripe_guid: stripe_subscription_guid)
    invoice = Invoice.find_by(stripe_guid: stripe_invoice_guid)

    if user && invoice && subscription
      invoice.update_from_stripe(stripe_invoice_guid)
      subscription.update_from_stripe
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)

      return unless stripe_next_attempt

      # A NextPaymentAttempt Date value means that another payment attempt will be made
      Message.create(
        process_at: Time.zone.now,
        user_id: user.id,
        kind: :account,
        template: 'send_card_payment_failed_email',
        template_params: {
          url: account_url
        }
      )
      subscription.mark_past_due
    else
      log_process_error "Error finding User-#{stripe_customer_guid}, Invoice-#{stripe_invoice_guid} OR Subscription- #{stripe_subscription_guid}. InvoicePaymentFailed Event"
    end
  end

  def process_payment_action_required(stripe_inv_id, stripe_subscription_guid)
    invoice = Invoice.find_by(stripe_guid: stripe_inv_id)
    subscription = Subscription.in_reverse_created_order.find_by(stripe_guid: stripe_subscription_guid)

    if invoice && subscription
      invoice.mark_payment_action_required if subscription.invoices.count > 1
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      log_process_error("Error finding Invoice by - #{stripe_inv_id} or Subscription by - #{stripe_subscription_guid}.
                        InvoicePaymentSucceeded Event")
    end
  end

  def process_invoice_upcoming(stripe_subscription_guid)
    account_payment_url = account_url + '#payment-details'
    subscription = Subscription.in_reverse_created_order.find_by(stripe_guid: stripe_subscription_guid)
    return if subscription.subscription_plan.interval_name != 'Yearly'

    Message.create(
      process_at: Time.zone.now,
      user_id: subscription.user.id,
      kind: :account,
      template: 'send_subscription_notification_email',
      template_params: {
        url: account_payment_url
      }
    )
  end

  def process_customer_subscription_deleted(stripe_customer_guid, stripe_subscription_guid, cancel_at_period_end)
    user = User.find_by(stripe_customer_id: stripe_customer_guid)
    subscription = Subscription.in_reverse_created_order.find_by(stripe_guid: stripe_subscription_guid)

    if user && subscription
      Rails.logger.debug "DEBUG: Deleted Subscription-#{stripe_subscription_guid} for User-#{stripe_customer_guid}"
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)

      subscription.update_from_stripe
      subscription.cancel
      # This is to ensure the Account Suspended email is only sent when
      # the subscription is canceled by Stripe due to failed payments
      unless subscription.cancelled_by_id || cancel_at_period_end
        Message.create(process_at: Time.zone.now,
                       user_id: user.id,
                       kind: :account,
                       template: 'send_account_suspended_email')
      end
    else
      log_process_error("Error deleting subscription. Couldn't find User with stripe_customer_guid: #{stripe_customer_guid} OR Couldn't find Subscription with stripe_subscription_guid: #{stripe_subscription_guid}")
    end
  end

  def process_charge_event(invoice_guid, event_data)
    invoice = Invoice.find_by(stripe_guid: invoice_guid)
    charge = Charge.create_from_stripe_data(event_data) if invoice

    if invoice && charge
      Rails.logger.debug "DEBUG: Successful Create Charge - #{charge.id} for Invoice - #{invoice.id}"
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      log_process_error("Error creating charge. Invoice Guid: #{invoice_guid}")
    end
  end

  def process_charge_refunded(invoice_guid, event_data)
    invoice = Invoice.find_by(stripe_guid: invoice_guid)
    charge = Charge.update_refund_data(event_data)

    if invoice && charge
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      log_process_error("Error creating charge for invoice #{invoice_guid}")
    end
  end

  def process_coupon_updated(coupon_code)
    coupon = Coupon.find_by(code: coupon_code)
    if coupon
      coupon.deactivate
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      log_process_error("Error updating Coupon. Code: #{coupon_code}")
    end
  end

  def set_default_values
    assign_attributes(processed: false, processed_at: Time.zone.now,
                      error: false, error_message: nil)
  end

  def log_process_error(error_message)
    Rails.logger.error "DEBUG: Stripe event processing error: #{error_message}"
    update!(processed: false, error_message: error_message, error: true)
    webhook_failed_notification(error_message, 'general')
  end

  def webhook_failed_notification(error, stripe_event_id)
    [{ fallback: "Stripe webhook ##{stripe_event_id} have failed.",
       title: "Stripe webhook ##{stripe_event_id} have failed.\nError: #{error.inspect}",
       title_link: "https://dashboard.stripe.com/events/#{stripe_event_id}",
       color: '#7CD197',
       footer: 'Stripe' }]
  end
end
