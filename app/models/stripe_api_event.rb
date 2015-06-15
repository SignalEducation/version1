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
  attr_accessor :profile_url

  serialize :payload, Hash

  # attr-accessible
  attr_accessible :guid, :api_version, :profile_url

  # Constants
  KNOWN_API_VERSIONS = %w(2015-02-18)
  KNOWN_PAYLOAD_TYPES = %w(invoice.created invoice.payment_failed customer.subscription.updated)

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
        self.update_attributes(processed: false, error: true, error_message: 'Livemode incorrect', callbacks: false, validation: false)
      else
        case self.payload[:type]
        when 'invoice.created'
          invoice = Invoice.build_from_stripe_data(self.payload[:data][:object])
          if invoice && invoice.errors.count == 0
            Rails.logger.debug "DEBUG: Invoice #{invoice.id} created"
            set_default_values
          else
            set_process_error (invoice ? invoice.errors.full_messages.inspect : "error creating invoice")
          end
        when 'invoice.payment_failed'
          user = User.find_by_stripe_customer_id(payload[:data][:object][:customer])
          if user
            MandrillWorker.perform_async(user.id, "send_card_payment_failed_email", self.profile_url)
          else
            Rails.logger.error "ERROR: User with Stripe id #{payload[:data][:object][:customer]} does not exist."
          end
        when 'customer.subscription.updated'
          subscription = Subscription.find_by_stripe_guid(payload[:data][:object][:id])
          if subscription && subscription.current_status == 'trialing' &&
             payload[:data][:object][:status] == 'active' &&
             # this check is probably not necessary but let's double check
             # that subscription is changed from trialing to active
             payload[:data][:previous_attributes][:status] == 'trialing'
            if subscription.update_attribute(:current_status, 'active')
              Rails.logger.debug "DEBUG: Subscription #{subscription.id} updated"
              if subscription.referred_signup
                subscription.referred_signup.update_attribute(:maturing_on, 40.days.from_now)
                Rails.logger.debug "DEBUG: Set maturing date for referred signup #{subscription.referred_signup}"
              end
              set_default_values
            else
              set_process_error subscription.errors.full_messages.join("\n")
            end
            # We have to sent mail 'Trial Converted' here
          end
        else
          self.update_attribute(:error_message, 'Unknown event type')
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
    Rails.logger.debug "DEBUG: Stripe event processing error: #{error_message}"
    self.processed = false
    self.error_message = error_message
    self.error = true
  end
end
