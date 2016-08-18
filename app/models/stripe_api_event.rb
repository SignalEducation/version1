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
  KNOWN_PAYLOAD_TYPES = %w(invoice.created invoice.payment_succeeded invoice.payment_failed customer.subscription.created customer.subscription.updated)

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
          invoice = Invoice.build_from_stripe_data(self.payload[:data][:object])
          if invoice && invoice.errors.count == 0
            Rails.logger.debug "DEBUG: Invoice #{invoice.id} created"
            self.processed = true
            self.processed_at = Time.now
          else
            set_process_error (invoice ? invoice.errors.full_messages.inspect : "Error creating invoice")
          end
        when 'invoice.payment_succeeded'
          #Latest attempt to charge a user has succeeded so we check if it was a crushoffers referral
          user = User.find_by_stripe_customer_id(self.payload[:data][:object][:customer])
          invoice = Invoice.where(stripe_guid: self.payload[:data][:object][:id]).last
          invoice_url = Rails.application.routes.url_helpers.subscription_invoices_url(invoice.id, locale: 'en', format: 'pdf')
          price = self.payload[:data][:object][:total].to_f / 100.0
          curr = self.payload[:data][:object][:currency].upcase
          if user && user.crush_offers_session_id && price > 0
            uri = URI("https://crushpay.com/p.ashx?o=29&e=22&p=#{price}&c=#{curr}&f=pb&r=#{user.crush_offers_session_id}&t=#{self.payload[:data][:object][:id]}")
            resp = Net::HTTP.get(uri)
            xml_doc = Nokogiri::XML(resp)
            result = xml_doc.at_xpath('//msg').content
            if result != 'SUCCESS'
              Rails.logger.error "ERROR: Notifying CrushOffers fails - response is #{resp}"
              set_process_error "Error notifying CrushOffers"
            end
          end
          if user && price > 0
            self.processed = true
            self.processed_at = Time.now
            unless Rails.env.test?
              stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
              balance = stripe_customer.account_balance
              Rails.logger.error "Notice: User Stripe balance #{balance}"
              Rails.logger.error "Notice: User Stripe balance #{user.try(:stripe_account_balance)}"
              user.update_attributes(stripe_account_balance: balance)
              subscription = Subscription.find_by_stripe_guid(self.payload[:data][:object][:subscription]) || user.subscriptions.last
              if subscription.try(:current_status) == 'past_due'
                #The subscription was overdue a payment so update it's status and send account reactivation email
                subscription.update_attributes(current_status: 'active')
                Rails.logger.error "Notice: User Subscription was updated from past_due to active #{user.try(:current_status)}"
                MandrillWorker.perform_async(user.id, 'send_account_reactivated_email', self.account_url)
              else
                #The subscription charge was successful so send successful payment email
                MandrillWorker.perform_async(user.id, 'send_successful_payment_email', self.account_url, invoice_url)
              end
              Rails.logger.error "Notice: User Stripe balance #{user.try(:stripe_account_balance)}"
            end
          else
            set_process_error "Unknown user, CrushOffers session id or the user could not be found"
          end
        when 'invoice.payment_failed'
          #Latest attempt to charge a user has failed
          user = User.find_by_stripe_customer_id(self.payload[:data][:object][:customer])
          if user
            if self.payload[:data][:object][:next_payment_attempt] == 'null'
              #Final payment attempt has failed on stripe so we cancel the current subscription
              self.processed = true
              self.processed_at = Time.now
              subscription = Subscription.find_by_stripe_guid(self.payload[:data][:object][:subscription])
              subscription.immediately_cancel
              MandrillWorker.perform_async(user.id, 'send_account_suspended_email', self.account_url)
            else
              #One of the attempted charges within the Stripe retry 5 day window so mark the subscription as past_due,
              #allowing access to course content until the retry window has expired.
              MandrillWorker.perform_async(user.id, 'send_card_payment_failed_email', self.account_url)
              self.processed = true
              self.processed_at = Time.now
              subscription = Subscription.find_by_stripe_guid(self.payload[:data][:object][:subscription])
              subscription.update_attribute(:current_status, 'past_due')
            end
          else
            Rails.logger.error "ERROR: User with Stripe id #{payload[:data][:object][:customer]} does not exist."
            set_process_error "User with given Stripe ID does not exist"
          end
        when 'customer.subscription.updated'
            #User upgrading from a free_trial subscription to a paying subscription
          subscription = Subscription.find_by_stripe_guid(self.payload[:data][:object][:id])
          if subscription &&
             subscription.update_attributes(next_renewal_date: Time.at(self.payload[:data][:object][:current_period_end].to_i),
                                            current_status: self.payload[:data][:object][:status])
            self.processed = true
            self.processed_at = Time.now
          else
            set_process_error("Error updating subscription #{subscription.try(:id)} with Stripe ID #{self.payload[:data][:object][:id]}")
          end
        when 'customer.subscription.created'
          #User reactivating their account after it was canceled due to repeated failed charges

          subscription = Subscription.find_by_stripe_guid(self.payload[:data][:object][:id])
          if subscription
            user_subscriptions = subscription.user.subscriptions.all_in_order
            if user_subscriptions.count == 2 &&
               user_subscriptions.first.free_trial? &&
               user_subscriptions.first.current_status == 'previous'

              self.processed = true
              self.processed_at = Time.now
            else
              set_process_error "API Event with Stripe ID #{self.payload[:data][:object][:id]} was created but the necessary conditions for the user were not met."
            end
          else
            set_process_error "Unknown subscription with Stripe ID #{self.payload[:data][:object][:id]}"
          end
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
