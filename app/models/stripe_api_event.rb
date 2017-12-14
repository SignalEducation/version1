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

class StripeApiEvent < ActiveRecord::Base
  # Since we shouldn't access routes in models and we need profile URL
  # for sending email through Mandrill we are defining non-DB attribute
  # here which will use value passed by Stripe API controller.
  attr_accessor :account_url

  serialize :payload, Hash

  # attr-accessible
  attr_accessible :guid, :api_version, :account_url

  # Constants
  KNOWN_API_VERSIONS = %w(2015-02-18 2017-06-05 2017-05-25)
  KNOWN_PAYLOAD_TYPES = %w(invoice.created invoice.payment_succeeded invoice.payment_failed customer.subscription.deleted charge.failed charge.succeeded charge.refunded)

  # relationships
  has_many :charges

  # validation
  validates :guid, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :api_version, inclusion: {in: KNOWN_API_VERSIONS}, length: { maximum: 255 }
  validates :payload, presence: true

  # callbacks
  before_validation :set_default_values, on: :create
  before_validation :get_data_from_stripe, on: :create
  after_create :disseminate_payload
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(id: :desc) }

  # class methods

  # instance methods
  def destroyable?
    !self.processed
  end

  def disseminate_payload
    if self.payload && self.payload.class == Hash && self.payload[:type]
      Rails.logger.debug "DEBUG: Processing Stripe event #{self.payload[:type]}"
      if Invoice::STRIPE_LIVE_MODE == self.payload[:livemode]
        #If the payload livemode matches the environment variable livemode
        case self.payload[:type]
          when 'invoice.created'
            process_invoice_created(self.payload)
          when 'invoice.payment_succeeded'
            process_invoice_payment_success(self.payload[:data][:object][:customer], self.payload[:data][:object][:id], self.payload[:data][:object][:subscription])
          when 'invoice.payment_failed'
            process_invoice_payment_failed(self.payload[:data][:object][:customer], self.payload[:data][:object][:next_payment_attempt], self.payload[:data][:object][:subscription], self.payload[:data][:object][:id])
          when 'customer.subscription.deleted'
            process_customer_subscription_deleted(self.payload[:data][:object][:customer], self.payload[:data][:object][:id])
          when 'charge.succeeded'
            process_charge_event(self.payload[:data][:object][:invoice], self.payload[:data][:object])
          when 'charge.failed'
            process_charge_event(self.payload[:data][:object][:invoice], self.payload[:data][:object])
          when 'charge.refunded'
            process_charge_refunded(self.payload[:data][:object][:invoice], self.payload[:data][:object])
          else
            set_process_error "Unknown event type - #{self.payload}"
        end
        self.save
      else
        #If the payload livemode DOESN'T matche the environment variable livemode
        Rails.logger.error "ERROR: StripeAPIEvent#disseminate_payload: LiveMode of message incompatible with Rails.env. StripeMode:#{Invoice::STRIPE_LIVE_MODE}. Rails.env.#{Rails.env} -v- payload:#{self.payload}."
        set_process_error("Livemode incorrect")
        self.save
      end
      true
    else
      false
    end
  end

  def get_data_from_stripe
    if self.guid
      response = Stripe::Event.retrieve(self.guid)
      self.payload = response.to_hash
    else
      self.error = true
      self.error_message = I18n.t('models.stripe_api_event.guid_required_to_get_payload_from_stripe')
      self.payload = {}
    end
    true
  rescue => e
    Rails.logger.error "ERROR: StripeApiEvent#get_data_from_stripe - Error: #{e.inspect}."
    self.error = true
    self.error_message = "Error: #{e.inspect}."
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def process_invoice_created(payload)
    #This creates the Invoice record and InvoiceLineItem records using the webhook payload data
    invoice = Invoice.build_from_stripe_data(payload[:data][:object])
    if invoice && invoice.errors.count == 0
      Rails.logger.debug "DEBUG: Invoice created with id - #{invoice.id}"
      self.processed = true
      self.processed_at = Time.now
    else
      set_process_error(invoice ? invoice.errors.full_messages.inspect : 'Error creating invoice')
    end
  end

  def process_invoice_payment_success(stripe_customer_guid, stripe_invoice_guid, stripe_subscription_guid)
    #This updates the existing Invoice record using the webhook payload data. The related subscription may need to be updated also if it is in a 'past_due' state.
    user = User.find_by_stripe_customer_id(stripe_customer_guid)
    subscription = Subscription.all_active.find_by_stripe_guid(stripe_subscription_guid)
    invoice = Invoice.find_by_stripe_guid(stripe_invoice_guid)

    if user && invoice && subscription
      invoice.update_from_stripe(stripe_invoice_guid) unless Rails.env.test?
      self.processed = true
      self.processed_at = Time.now
      #Update the subscription if it is in the past_due state
      if subscription.update_from_stripe

        #The subscription charge was successful so send successful payment email
        url_host =  Rails.env.production? ? 'learnsignal.com' : 'staging.learnsignal.com'
        invoice_url = Rails.application.routes.url_helpers.subscription_invoices_url(invoice.id, locale: 'en', format: 'pdf', host: url_host)
        MandrillWorker.perform_async(user.id, 'send_successful_payment_email', self.account_url, invoice_url)

        Rails.logger.debug "DEBUG: Invoice being updated due to successful payment webhook. Invoice id - #{invoice.id}"
      
      else
        set_process_error("Error updating subscription from stripe - subscription.update_from_stripe. SubID-#{subscription.id}, InvID-#{invoice.id}, UserID-#{user.id}, InvoicePaymentSucceeded Event ")
      end

    else
      set_process_error("Error finding User by - #{stripe_customer_guid}, Invoice by - #{stripe_invoice_guid} or Subscription by - #{stripe_subscription_guid}. InvoicePaymentSucceeded Event")
    end
  end

  def process_invoice_payment_failed(stripe_customer_guid, stripe_next_attempt, stripe_subscription_guid, stripe_invoice_guid)
    #Latest attempt to charge a user has failed
    user = User.find_by_stripe_customer_id(stripe_customer_guid)
    subscription = Subscription.all_active.find_by_stripe_guid(stripe_subscription_guid)
    invoice = Invoice.where(stripe_guid: stripe_invoice_guid).last

    if user && invoice && subscription
      invoice.update_from_stripe(stripe_invoice_guid) unless Rails.env.test?
      subscription.update_from_stripe
      if stripe_next_attempt
        #A NextPaymentAttempt Date value means that another payment attempt will be made
        MandrillWorker.perform_async(user.id, 'send_card_payment_failed_email', self.account_url)
      else
        #Final payment attempt has failed on stripe so we cancel the current subscription
        MandrillWorker.perform_async(user.id, 'send_account_suspended_email')
      end
    else
      set_process_error "Error finding User-#{stripe_customer_guid}, Invoice-#{stripe_invoice_guid} OR Subscription- #{stripe_subscription_guid}. InvoicePaymentFailed Event"
    end

  end

  def process_customer_subscription_deleted(stripe_customer_guid, stripe_subscription_guid)
    user = User.find_by_stripe_customer_id(stripe_customer_guid)
    subscription = Subscription.all_active.find_by_stripe_guid(stripe_subscription_guid)

    if user && subscription
      Rails.logger.debug "DEBUG: Deleted Subscription-#{stripe_subscription_guid} for User-#{stripe_customer_guid}"
      self.processed = true
      self.processed_at = Time.now
      subscription.update_from_stripe
    else
      set_process_error("Error deleting subscription. Couldn't find User with stripe_customer_guid: #{stripe_customer_guid} OR Couldn't find Subscription with stripe_subscription_guid: #{stripe_subscription_guid}")
    end
  end

  def process_charge_event(invoice_guid, event_data)
    invoice = Invoice.where(stripe_guid: invoice_guid).first

    charge = Charge.create_from_stripe_data(event_data)

    if invoice && charge
      Rails.logger.debug "DEBUG: Successful Create Charge - #{charge.id} for Invoice - #{invoice.id}"
      self.processed = true
      self.processed_at = Time.now
    else
      set_process_error("Error creating charge. #{}")
    end
  end

  def process_charge_refunded(invoice_guid, event_data)
    invoice = Invoice.where(stripe_guid: invoice_guid).first

    charge = Charge.update_refund_data(event_data)

    if invoice && charge

      self.processed = true
      self.processed_at = Time.now
    else
      set_process_error("Error creating charge. #{}")
    end
  end

  def set_default_values
    self.processed = false
    self.processed_at = Time.now
    self.error = false
    self.error_message = nil
  end

  def set_process_error(error_message)
    Rails.logger.error "DEBUG: Stripe event processing error: #{error_message}"
    self.processed = false
    self.error_message = error_message
    self.error = true
  end
end
