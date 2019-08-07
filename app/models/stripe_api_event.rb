# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string
#  api_version   :string
#  payload       :text
#  processed     :boolean          default(FALSE), not null
#  processed_at  :datetime
#  error         :boolean          default(FALSE), not null
#  error_message :string
#  created_at    :datetime
#  updated_at    :datetime
#

class StripeApiEvent < ApplicationRecord
  attr_accessor :account_url

  serialize :payload, Hash

  # CONSTANTS ==================================================================

  KNOWN_API_VERSIONS = %w[2015-02-18 2017-06-05 2017-05-25 2019-05-16].freeze
  KNOWN_PAYLOAD_TYPES =
    %w[invoice.created invoice.payment_succeeded invoice.payment_failed
       customer.subscription.deleted charge.failed charge.succeeded
       charge.refunded coupon.updated].freeze
  DELAYED_TYPES = %w[invoice.payment_succeeded invoice.payment_failed
                     charge.failed charge.succeeded].freeze

  # RELATIONSHIPS ==============================================================

  has_many :charges

  # VALIDATIONS ================================================================

  validates :guid, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :api_version,
            inclusion: { in: KNOWN_API_VERSIONS }, length: { maximum: 255 }
  validates :payload, presence: true

  # CALLBACKS ==================================================================

  before_validation :set_default_values, on: :create
  before_validation :get_data_from_stripe, on: :create
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
    DELAYED_TYPES.include?(event_type) ? 5.minutes : 1.minute
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
<<<<<<< HEAD
    return unless payload && payload.is_a?(Hash) && payload[:type].present?
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
        process_payment_action_required(webhook_object[:id])
      when 'customer.subscription.deleted'
        process_customer_subscription_deleted(webhook_object[:customer],
                                              webhook_object[:id])
      when 'charge.succeeded'
        process_charge_event(webhook_object[:invoice], webhook_object)
      when 'charge.failed'
        process_charge_event(webhook_object[:invoice], webhook_object)
      when 'charge.refunded'
        process_charge_refunded(webhook_object[:invoice], webhook_object)
      when 'coupon.updated'
        process_coupon_updated(webhook_object[:id])
=======
    if self.payload && self.payload.class == Hash && self.payload['type']
      Rails.logger.debug "DEBUG: Processing Stripe event #{self.payload['type']}"
      if Invoice::STRIPE_LIVE_MODE == self.payload['livemode']
        #If the payload livemode matches the environment variable livemode
       
        case self.payload['type']
          when 'invoice.created'
            process_invoice_created(self.payload)
          when 'invoice.payment_succeeded'
            process_invoice_payment_success(self.payload[:data][:object][:customer], self.payload[:data][:object][:id], self.payload[:data][:object][:subscription])
          when 'invoice.payment_failed'
            process_invoice_payment_failed(self.payload[:data][:object][:customer], self.payload[:data][:object][:next_payment_attempt], self.payload[:data][:object][:subscription], self.payload[:data][:object][:id])
          when 'invoice.payment_action_required'
            process_payment_action_required()
          when 'customer.subscription.deleted'
            process_customer_subscription_deleted(self.payload[:data][:object][:customer], self.payload[:data][:object][:id])
          when 'charge.succeeded'
            process_charge_event(self.payload[:data][:object][:invoice], self.payload[:data][:object])
          when 'charge.failed'
            process_charge_event(self.payload[:data][:object][:invoice], self.payload[:data][:object])
          when 'charge.refunded'
            process_charge_refunded(self.payload[:data][:object][:invoice], self.payload[:data][:object])
          when 'coupon.updated'
            process_coupon_updated(self.payload[:data][:object][:id])
          
          else
            set_process_error "Unknown event type - #{self.payload[:type]}"
        end
        self.save
>>>>>>> Code cleanup
      else
        set_process_error "Unknown event type - #{payload[:type]}"
      end
    else
      Rails.logger.error('ERROR: StripeAPIEvent#disseminate_payload: ' \
        'LiveMode of message incompatible with Rails.env. StripeMode:' \
        "#{Invoice::STRIPE_LIVE_MODE}. Rails.env.#{Rails.env} -v- payload:" \
        "#{payload}.")
      set_process_error("Livemode incorrect")
    end
  end

  def get_data_from_stripe
<<<<<<< HEAD
    if guid
      response = Stripe::Event.retrieve(guid)
      assign_attributes(payload: response.to_hash)
=======

    if self.guid
      response = Stripe::Event.retrieve(self.guid)
      self.payload = response.to_hash
>>>>>>> Code cleanup
    else
      assign_attributes(
        error: true,
        error_message: I18n.t(
          'models.stripe_api_event.guid_required_to_get_payload_from_stripe'
        ),
        payload: {}
      )
    end
  rescue => e
    Rails.logger.error(
      "ERROR: StripeApiEvent#get_data_from_stripe - Error: #{e.inspect}."
    )
    assign_attributes(error: true, error_message: "Error: #{e.inspect}.")
  end

  protected

  def check_dependencies
    unless destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
    end
  end


  def process_payment_action_required
  end

  def process_invoice_created(payload)
    invoice = Invoice.build_from_stripe_data(payload[:data][:object])
    if invoice && invoice.errors.count == 0
      Rails.logger.debug "DEBUG: Invoice created with id - #{invoice.id}"
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      set_process_error(invoice&.errors&.inspect || 'Error creating invoice')
    end
  end

  def process_invoice_payment_success(stripe_inv_id)
    invoice = Invoice.find_by(stripe_guid: stripe_inv_id)

    if invoice
      invoice.update_from_stripe(stripe_inv_id)
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
      invoice.subscription.update_invoice_payment_success
      invoice.send_receipt(account_url)
    else
      set_process_error("Error finding Invoice by - #{stripe_inv_id}. " \
                        'InvoicePaymentSucceeded Event')
    end
  end

  def process_invoice_payment_failed(stripe_customer_guid, stripe_next_attempt, stripe_subscription_guid, stripe_invoice_guid)
    user = User.find_by_stripe_customer_id(stripe_customer_guid)
    subscription = Subscription.where(stripe_guid: stripe_subscription_guid).last
    invoice = Invoice.where(stripe_guid: stripe_invoice_guid).last

    if user && invoice && subscription
      invoice.update_from_stripe(stripe_invoice_guid)
      subscription.update_from_stripe
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)

      if stripe_next_attempt
        #A NextPaymentAttempt Date value means that another payment attempt will be made
        MandrillWorker.perform_async(user.id, 'send_card_payment_failed_email', self.account_url) unless Rails.env.test?
      else
        #Final payment attempt has failed on stripe so we cancel the current subscription
        MandrillWorker.perform_async(user.id, 'send_account_suspended_email') unless Rails.env.test?
      end
    else
      set_process_error "Error finding User-#{stripe_customer_guid}, Invoice-#{stripe_invoice_guid} OR Subscription- #{stripe_subscription_guid}. InvoicePaymentFailed Event"
    end
  end

  def process_payment_action_required(stripe_inv_id)
    invoice = Invoice.find_by(stripe_guid: stripe_inv_id)

    if invoice
      invoice.mark_payment_action_required
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      set_process_error("Error finding Invoice by - #{stripe_inv_id}.
                        InvoicePaymentSucceeded Event")
    end
  end

  def process_customer_subscription_deleted(stripe_customer_guid, stripe_subscription_guid)
    user = User.find_by_stripe_customer_id(stripe_customer_guid)
    subscription = Subscription.where(stripe_guid: stripe_subscription_guid).last

    if user && subscription
      Rails.logger.debug "DEBUG: Deleted Subscription-#{stripe_subscription_guid} for User-#{stripe_customer_guid}"
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)

      subscription.update_from_stripe
      subscription.cancel
    else
      set_process_error("Error deleting subscription. Couldn't find User with stripe_customer_guid: #{stripe_customer_guid} OR Couldn't find Subscription with stripe_subscription_guid: #{stripe_subscription_guid}")
    end
  end

  def process_charge_event(invoice_guid, event_data)
    invoice = Invoice.where(stripe_guid: invoice_guid).first
    charge = Charge.create_from_stripe_data(event_data) if invoice

    if invoice && charge
      Rails.logger.debug "DEBUG: Successful Create Charge - #{charge.id} for Invoice - #{invoice.id}"
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      set_process_error("Error creating charge. Invoice Guid: #{invoice_guid}")
    end
  end

  def process_charge_refunded(invoice_guid, event_data)
    invoice = Invoice.where(stripe_guid: invoice_guid).first
    charge = Charge.update_refund_data(event_data)

    if invoice && charge
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      set_process_error("Error creating charge. #{}")
    end
  end

  def process_coupon_updated(coupon_code)
    coupon = Coupon.where(code: coupon_code).first
    if coupon
      coupon.deactivate
      update!(processed: true, processed_at: Time.zone.now, error: false,
              error_message: nil)
    else
      set_process_error("Error updating Coupon. Code: #{coupon_code}")
    end
  end

  def set_default_values
    assign_attributes(processed: false, processed_at: Time.zone.now,
                      error: false, error_message: nil)
  end

  def set_process_error(error_message)
    Rails.logger.error "DEBUG: Stripe event processing error: #{error_message}"
    update!(processed: false, error_message: error_message, error: true)
  end
end
