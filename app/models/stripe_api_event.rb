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
          user = User.find_by_stripe_customer_id(self.payload[:data][:object][:customer])
          price = self.payload[:data][:object][:total].to_f / 100.0
          curr = self.payload[:data][:object][:currency].upcase
          if user && user.crush_offers_session_id && price > 0
            uri = URI("https://crushpay.com/p.ashx?o=29&e=22&p=#{price}&c=#{curr}&f=pb&r=#{user.crush_offers_session_id}&t=#{self.payload[:data][:object][:id]}")
            resp = Net::HTTP.get(uri)
            xml_doc = Nokogiri::XML(resp)
            result = xml_doc.at_xpath('//msg').content
            if result == 'SUCCESS'
              self.processed = true
              self.processed_at = Time.now
            else
              Rails.logger.error "ERROR: Notifying CrushOffers fails - response is #{resp}"
              set_process_error "Error notifying CrushOffers"
            end
          elsif user && price > 0
            self.processed = true
            self.processed_at = Time.now
            stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
            user.update_attribute(stripe_account_balance, stripe_customer.account_balance)
          else
            set_process_error "Unknown user, CrushOffers session id or price not greater than 0"
          end
        when 'invoice.payment_failed'
          user = User.find_by_stripe_customer_id(self.payload[:data][:object][:customer])
          if user
            IntercomPaymentFailedWorker.perform_async(user.id, self.account_url) unless Rails.env.test?
            self.processed = true
            self.processed_at = Time.now
          else
            Rails.logger.error "ERROR: User with Stripe id #{payload[:data][:object][:customer]} does not exist."
            set_process_error "User with given Stripe ID does not exist"
          end
        when 'customer.subscription.updated'
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
          subscription = Subscription.find_by_stripe_guid(self.payload[:data][:object][:id])
          if subscription
            user_subscriptions = subscription.user.subscriptions.all_in_order
            if user_subscriptions.count == 2 &&
               user_subscriptions.first.free_trial? &&
               user_subscriptions.first.current_status == 'canceled'
              # If this is first subscriptiona after user's free trial subscription
              # we have to check referred signups. Since referred signups are related
              # to original, free trial, subscription we will redirect it to new
              # subscription. This will enable us to double check (if needed) maturong on
              # value since we can compare it with subscription's created_at value.
              if user_subscriptions.first.referred_signup
                user_subscriptions.first.referred_signup.update_attributes(maturing_on: 40.days.from_now.utc.beginning_of_day,
                                                                           subscription_id: subscription.id)
                Rails.logger.debug "DEBUG: Set maturing date for referred signup #{subscription.referred_signup.id}"
              end

              self.processed = true
              self.processed_at = Time.now
            else
              set_process_error "Subscription with Stripe ID created #{self.payload[:data][:object][:id]} but it is not the first one after free trial."
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
