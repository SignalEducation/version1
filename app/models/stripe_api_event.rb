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
  KNOWN_API_VERSIONS = %w(2015-02-18)
  KNOWN_PAYLOAD_TYPES = %w(customer.subscription.created customer.subscription.updated invoice.created invoice.payment_failed invoice.payment_succeeded)

  # relationships

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
      Rails.logger.debug "DEBUG: Processing Stripe event #{payload[:type]}"
      unless Invoice::STRIPE_LIVE_MODE == payload[:livemode]
        Rails.logger.error "ERROR: StripeAPIEvent#disseminate_payload: LiveMode of message incompatible with Rails.env. StripeMode:#{Invoice::STRIPE_LIVE_MODE}. Rails.env.#{Rails.env} -v- payload:#{payload}."
        set_process_error("Livemode incorrect")
        self.save
      else
        case self.payload[:type]
        when 'invoice.created'
          invoice_created(self.payload[:data][:object])
        when 'invoice.payment_succeeded'
          invoice_payment_succeeded(payload[:data][:object][:customer], self.payload[:data][:object][:id], self.payload[:data][:object][:total].to_f / 100.0, self.payload[:data][:object][:currency].upcase, self.payload[:data][:object][:subscription], self.payload[:data][:object])
        when 'invoice.payment_failed'
          invoice_payment_failed(self.payload[:data][:object][:customer], self.payload[:data][:object][:next_payment_attempt], self.payload[:data][:object][:subscription])

        when 'customer.subscription.updated'
          customer_subscription_updated(self.payload[:data][:object][:id], self.payload[:data][:object][:current_period_end].to_i, self.payload[:data][:object][:status])
        when 'customer.subscription.created'
          customer_subscription_created(self.payload[:data][:object][:id])
        else
          set_process_error "Unknown event type"
        end # of case statement

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

  def invoice_created(stripe_data)
    invoice = Invoice.build_from_stripe_data(stripe_data)
    if invoice && invoice.errors.count == 0
      Rails.logger.debug "DEBUG: Invoice #{invoice.id} created"
      self.processed = true
      self.processed_at = Time.now
    else
      set_process_error (invoice ? invoice.errors.full_messages.inspect : "Error creating invoice")
    end
  end

  def invoice_payment_succeeded(stripe_user_data, stripe_invoice_data, stripe_price_data, stripe_currency_data, stripe_subscription_data, stripe_data_hash)
    user = User.where(stripe_customer_id: stripe_user_data).last
    invoice = Invoice.where(stripe_guid: stripe_invoice_data).last
    price = stripe_price_data
    curr = stripe_currency_data
    subscription = Subscription.find_by_stripe_guid(stripe_subscription_data)


    if user && subscription && invoice
      #Update the Invoice
      invoice.update_from_stripe(stripe_invoice_data)
      #Update the Subscription if it was in past_due state
      subscription.update_attribute(:current_status, 'active') if subscription.current_status == 'past_due'
      self.processed = true
      self.processed_at = Time.now
      unless Rails.env.test?
        stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
        balance = stripe_customer.account_balance
        Rails.logger.error "Notice: Stripes User balance #{balance}"
        Rails.logger.error "Notice: LearnSignal Users old stripe_balance #{user.try(:stripe_account_balance)}"
        user.update_attributes(stripe_account_balance: balance)
        Rails.logger.error "Notice: LearnSignal Users new stripe_balance #{user.try(:stripe_account_balance)}"
      end

      # Set url for mandrill email, if no invoice then set url to account page
      if invoice
        invoice_url = Rails.application.routes.url_helpers.subscription_invoices_url(invoice.id, locale: 'en', format: 'pdf', host: 'www.learnsignal.com')
      else
        invoice_url = Rails.application.routes.url_helpers.account_url(host: 'www.learnsignal.com')
      end
      #The subscription charge was successful so send successful payment email
      MandrillWorker.perform_async(user.id, 'send_successful_payment_email', self.account_url, invoice_url) unless Rails.env.test?

    else
      set_process_error("Unknown User or Subscription #{user} - #{subscription}")
    end
  end

  def invoice_payment_failed(stripe_user_data, stripe_next_attempt, stripe_subscription_data)
    #Latest attempt to charge a user has failed
    user = User.find_by_stripe_customer_id(stripe_user_data)
    if user

      if stripe_next_attempt
        #One of the attempted charges within the Stripe retry 5 day window so mark the subscription as past_due, allowing access to course content until the retry window has expired.
        MandrillWorker.perform_async(user.id, 'send_card_payment_failed_email', self.account_url)
        self.processed = true
        self.processed_at = Time.now
        subscription = Subscription.find_by_stripe_guid(stripe_subscription_data)
        subscription.update_attribute(:current_status, 'past_due')
      else
        #Final payment attempt has failed on stripe so we cancel the current subscription
        self.processed = true
        self.processed_at = Time.now
        subscription = Subscription.find_by_stripe_guid(stripe_subscription_data)
        subscription.immediately_cancel
        MandrillWorker.perform_async(user.id, 'send_account_suspended_email', self.account_url) if Rails.env.production?
      end
    else
      Rails.logger.error "ERROR: User with Stripe id #{stripe_user_data} does not exist."
      set_process_error "Could not find user with stripe id #{stripe_user_data}"
    end

  end

  def customer_subscription_updated(stripe_subscription_data, stripe_subscription_renewal_date, stripe_subscription_status)
    subscription = Subscription.find_by_stripe_guid(stripe_subscription_data)
    if subscription &&
        subscription.update_attributes(next_renewal_date: Time.at(stripe_subscription_renewal_date),
                                       current_status: stripe_subscription_status)
      self.processed = true
      self.processed_at = Time.now
    else
      set_process_error("Error updating subscription #{subscription.try(:id)} with Stripe ID #{stripe_subscription_data}")
    end
  end

  def customer_subscription_created(stripe_subscription_data)
    #User has just created their first subscription or User reactivating their account after it was fully canceled and deleted on stripe
    subscription = Subscription.find_by_stripe_guid(stripe_subscription_data)
    if subscription && subscription.user.active_subscription
      if subscription.id == subscription.user.active_subscription.id && subscription.user.active_subscription.current_status == 'active'
        #User has just created their first subscription
        self.processed = true
        self.processed_at = Time.now

      elsif subscription.id == subscription.user.active_subscription.id && subscription.user.active_subscription.current_status == 'canceled'
        #User reactivating their account after it was fully canceled and deleted on stripe
        self.processed = true
        self.processed_at = Time.now
        user = subscription.user

      else
        set_process_error "API Event with Stripe ID #{stripe_subscription_data} was created but the necessary conditions for the user subscription were not met."
      end
    else
      set_process_error "Unknown subscription with Stripe ID #{stripe_subscription_data}"
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
