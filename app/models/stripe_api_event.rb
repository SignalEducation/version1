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
  KNOWN_PAYLOAD_TYPES = %w(invoice.create invoice.payment_succeeded invoice.payment_failed charge.succeeded customer.subscription.trial_will_end customer.subscription.updated)

  # relationships

  # validation
  validates :guid, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :api_version, inclusion: {in: KNOWN_API_VERSIONS}, length: { maximum: 255 }
  validates :payload, presence: true

  # callbacks
  before_validation :set_default_values, on: :create
  before_create :get_data_from_stripe
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
        return true
      end
      item_saved = nil
      case self.payload[:type]
        when 'charge'

        when 'customer'

        when 'invoice.created'
          item_saved = Invoice.build_from_stripe_data(self.payload[:data][:object])

        # sample = {
        #         id: 'test_evt_1',
        #         created: 1326853478,
        #         livemode: false,
        #         type: 'invoice.created',
        #         object: 'event',
        #         data: {
        #                 object: {
        #                         id: 'in_00000000000000',
        #                         date: 1380674206,
        #                         period_start: 1378082075,
        #                         period_end: 1380674075,
        #                         lines: {
        #                                 count: 1,
        #                                 object: 'list',
        #                                 url: '/v1/invoices/in_00000000000000/lines',
        #                                 data: [
        #                                         {
        #                                                 id: 'su_2hksGtIPylSBg2',
        #                                                 object: 'line_item',
        #                                                 type: 'subscription',
        #                                                 livemode: true,
        #                                                 amount: 100,
        #                                                 currency: 'usd',
        #                                                 proration: false,
        #                                                 period: {
        #                                                         start: 1383759042,
        #                                                         end: 1386351042
        #                                                 },
        #                                                 quantity: 1,
        #                                                 plan: {
        #                                                         id: 'fkx0AFo',
        #                                                         interval: 'month',
        #                                                         name: "Member's Club",
        #                                                         amount: 100,
        #                                                         currency: 'usd',
        #                                                         object: 'plan',
        #                                                         livemode: false,
        #                                                         interval_count: 1,
        #                                                         trial_period_days: nil,
        #                                                         metadata: {}
        #                                                 },
        #                                                 description: nil,
        #                                                 metadata: nil
        #                                         }
        #                                 ]
        #                         },
        #                         subtotal: 1000,
        #                         total: 1000,
        #                         customer: 'cus_00000000000000',
        #                         object: 'invoice',
        #                         attempted: false,
        #                         closed: true,
        #                         paid: true,
        #                         livemode: false,
        #                         attempt_count: 1,
        #                         amount_due: 1000,
        #                         currency: 'usd',
        #                         starting_balance: 0,
        #                         ending_balance: 0,
        #                         next_payment_attempt: nil,
        #                         charge: 'ch_00000000000000',
        #                         discount: nil,
        #                         application_fee: nil,
        #                         subscription: 'sub_00000000000000',
        #                         metadata: {},
        #                         description: nil
        #                 }
        #         }
        # }

        when 'payment'

        when ''

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
