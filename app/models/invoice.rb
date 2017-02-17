# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  corporate_customer_id       :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  vat_rate_id                 :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  issued_at                   :datetime
#  stripe_guid                 :string
#  sub_total                   :decimal(, )      default(0.0)
#  total                       :decimal(, )      default(0.0)
#  total_tax                   :decimal(, )      default(0.0)
#  stripe_customer_guid        :string
#  object_type                 :string           default("invoice")
#  payment_attempted           :boolean          default(FALSE)
#  payment_closed              :boolean          default(FALSE)
#  forgiven                    :boolean          default(FALSE)
#  paid                        :boolean          default(FALSE)
#  livemode                    :boolean          default(FALSE)
#  attempt_count               :integer          default(0)
#  amount_due                  :decimal(, )      default(0.0)
#  next_payment_attempt_at     :datetime
#  webhooks_delivered_at       :datetime
#  charge_guid                 :string
#  subscription_guid           :string
#  tax_percent                 :decimal(, )
#  tax                         :decimal(, )
#  original_stripe_data        :text
#

class Invoice < ActiveRecord::Base

  include LearnSignalModelExtras

  serialize :original_stripe_data, Hash

  # attr-accessible
  attr_accessible :user_id, :corporate_customer_id, :subscription_transaction_id,
                  :subscription_id, :number_of_users, :currency_id, :vat_rate_id,
                  :issued_at, :stripe_guid, :sub_total, :total, :total_tax,
                  :stripe_customer_guid, :object_type, :payment_attempted,
                  :payment_closed, :forgiven, :paid, :livemode, :attempt_count,
                  :amount_due, :next_payment_attempt_at, :webhooks_delivered_at,
                  :charge_guid, :subscription_guid, :tax_percent, :tax,
                  :original_stripe_data

  # Constants
  STRIPE_LIVE_MODE = (ENV['learnsignal_v3_stripe_live_mode'] == 'live')

  # relationships
  belongs_to :currency
  belongs_to :corporate_customer
  has_many :invoice_line_items
  belongs_to :subscription_transaction
  belongs_to :subscription
  belongs_to :user
  belongs_to :vat_rate

  # validation
  validates :user_id, presence: true
  validates :subscription_id, presence: true
  validates :number_of_users, presence: true
  validates :currency_id, presence: true
  validates :total, presence: true
  validates :livemode, inclusion: {in: [STRIPE_LIVE_MODE]}
  validates_length_of :stripe_guid, maximum: 255, allow_blank: true
  validates_length_of :stripe_customer_guid, maximum: 255, allow_blank: true
  validates_length_of :charge_guid, maximum: 255, allow_blank: true
  validates_length_of :object_type, maximum: 255, allow_blank: true
  validates_length_of :subscription_guid, maximum: 255, allow_blank: true

  # callbacks
  after_create :set_vat_rate

  # scopes
  scope :all_in_order, -> { order(user_id: :asc, id: :desc) }

  # class methods
  def self.build_from_stripe_data(stripe_data_hash)
    inv = nil
    Invoice.transaction do
      user = User.find_by_stripe_customer_id(stripe_data_hash[:customer])
      subscription = Subscription.find_by_stripe_guid(stripe_data_hash[:subscription])
      if user && subscription
        inv = Invoice.new(
          user_id: user.id,
          corporate_customer_id: nil,
          subscription_id: subscription.id,
          currency_id: Currency.find_by_iso_code(stripe_data_hash[:currency].upcase).id,
          issued_at: Time.at(stripe_data_hash[:date]),
          stripe_guid: stripe_data_hash[:id],
          sub_total: stripe_data_hash[:subtotal].to_i / 100.0,
          total: stripe_data_hash[:total].to_i / 100.0,
          total_tax: stripe_data_hash[:tax].to_i / 100.0,
          stripe_customer_guid: stripe_data_hash[:customer],
          object_type: stripe_data_hash[:object],
          payment_attempted: stripe_data_hash[:attempted],
          payment_closed: stripe_data_hash[:closed],
          forgiven: stripe_data_hash[:forgiven],
          paid: stripe_data_hash[:paid],
          livemode: stripe_data_hash[:livemode],
          attempt_count: stripe_data_hash[:attempt_count],
          amount_due: stripe_data_hash[:amount_due],
          next_payment_attempt_at: (stripe_data_hash[:next_payment_attempt] ? Time.at(stripe_data_hash[:next_payment_attempt]) : nil),
          webhooks_delivered_at: (stripe_data_hash[:webhooks_delivered_at] ? Time.at(stripe_data_hash[:webhooks_delivered_at]) : nil),
          charge_guid: stripe_data_hash[:charge],
          subscription_guid: stripe_data_hash[:subscription],
          tax_percent: stripe_data_hash[:tax_percent],
          tax: stripe_data_hash[:tax].to_i / 100.0,
          original_stripe_data: stripe_data_hash.to_hash,
          # todo - these need further attention
          subscription_transaction_id: nil,
          vat_rate_id: nil,
          number_of_users: 0
        )
        if inv.save
          begin
            stripe_data_hash[:lines][:data].each do |line_item|
              InvoiceLineItem.build_from_stripe_data(inv.id, line_item, inv.subscription_id)
            end
          rescue NoMethodError => err
            Rails.logger.error "ERROR: Invoice with id #{inv.id} should be rolled back due to the error in creating invoice line items."
            inv = nil
            raise ActiveRecord::Rollback
          end
        else
          Rails.logger.error "ERROR: Invoice#build_from_stripe_data failed to build an invoice. Errors: #{inv.errors.full_messages.inspect}. Original data: #{stripe_data_hash}."
        end
      else
        Rails.logger.error "ERROR: Invoice#build_from_stripe_data failed to build an invoice. Either user #{stripe_data_hash[:customer]} or subscritpion #{stripe_data_hash[:subscription]} do not exisr."
      end
    end
    inv
  end

  def self.get_updates_for_user(stripe_customer_guid)
    payload = Stripe::Invoice.all(limit: 10, customer: stripe_customer_guid).to_hash
    if payload[:data].length > 0
      known_invoice_guids = Invoice.where(stripe_customer_guid: stripe_customer_guid).pluck(:stripe_guid)
      payload[:data].each do |incoming_inv|
        unless known_invoice_guids.include?(incoming_inv[:id])
          Invoice.build_from_stripe_data(incoming_inv)
        end
      end
    end
  end

  # instance methods
  def destroyable?
    #!Rails.env.production? && self.invoice_line_items.empty?
    true
  end

  def status
    if self.paid
      'Paid'
    elsif self.forgiven
      'Free'
    elsif self.payment_attempted && self.next_payment_attempt_at.to_i > 0
      ActionController::Base.helpers.pluralize(attempt_count, 'attempt') +
              ' made to charge your card - next attempt at ' +
              Time.at(next_payment_attempt_at).to_s(:standard)
    elsif self.payment_attempted
      ActionController::Base.helpers.pluralize(attempt_count, 'attempt') +
              ' made to charge your card'
    else
      'Other'
    end
    # payment_attempted
    # payment_closed
    # livemode
    # attempt_count
    # next_payment_attempt_at
    # 'hello'
  end

  protected

  def set_vat_rate
    country = user.country
    if country && country.vat_codes.any?
      vat_code = country.vat_codes.first
      vat_rate_id = VatRate.find_by_vat_code_id(vat_code.id).try(:id)
      self.update_attribute(:vat_rate_id, vat_rate_id) if vat_rate_id
    end
  end
end
