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

  serialize :payload, Hash

  # attr-accessible
  attr_accessible :guid, :api_version

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
      unless Invoice::STRIPE_LIVE_MODE == payload[:livemode]
        Rails.logger.error "ERROR: StripeAPIEvent#disseminate_payload: LiveMode of message incompatible with Rails.env. StripeMode:#{Invoice::STRIPE_LIVE_MODE}. Rails.env.#{Rails.env} -v- payload:#{payload}."
        self.update_attributes(processed: false, error: true, error_message: 'Livemode incorrect', callbacks: false, validation: false)
      else
        item_saved = nil
        case self.payload[:type]
        when 'invoice.created'
          item_saved = Invoice.build_from_stripe_data(self.payload[:data][:object])
        when 'invoice.payment_failed'

        when 'customer.subscription.updated'

        else
          self.update_attribute(:error_message, 'Unknown event type')
        end # of case statement

        if item_saved.errors.count == 0
          self.processed = true
          self.error = false
          self.error_message = nil
        else
          self.processed = false
          self.error_message = item_saved.errors.full_messages.inspect
          self.error = true
        end
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
    self.processed_at = Proc.new{Time.now}.call
    self.error = false
    self.error_message = nil
  end

end
