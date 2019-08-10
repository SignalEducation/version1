# frozen_string_literal: true
# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
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
#  paypal_payment_guid         :string
#  order_id                    :bigint(8)
#  requires_3d_secure          :boolean          default(FALSE)
#

class Invoice < ApplicationRecord
  include LearnSignalModelExtras
  require 'securerandom'

  serialize :original_stripe_data, Hash

  # Constants
  STRIPE_LIVE_MODE = (ENV['LEARNSIGNAL_V3_STRIPE_LIVE_MODE'] == 'live')

  # relationships
  belongs_to :currency
  has_many :invoice_line_items, autosave: true
  has_many :charges
  has_many :refunds
  belongs_to :subscription_transaction, optional: true
  belongs_to :subscription, optional: true
  belongs_to :order, optional: true
  belongs_to :user
  belongs_to :vat_rate, optional: true

  # validation
  validates :user_id, :currency_id, :total, presence: true
  validates :subscription_id, :number_of_users, presence: true, if: :strip_invoice?
  validates :livemode, inclusion: { in: [STRIPE_LIVE_MODE] }, if: :strip_invoice?
  validates_length_of :stripe_guid, maximum: 255, allow_blank: true
  validates_length_of :stripe_customer_guid, maximum: 255, allow_blank: true
  validates_length_of :charge_guid, maximum: 255, allow_blank: true
  validates_length_of :object_type, maximum: 255, allow_blank: true
  validates_length_of :subscription_guid, maximum: 255, allow_blank: true

  # callbacks
  after_create :set_vat_rate
  after_create :set_issued_at
  after_create :generate_sca_guid

  # scopes
  scope :all_in_order,  -> { order(user_id: :asc, id: :desc) }
  scope :subscriptions, -> { where.not(subscription_id: nil) }
  scope :orders,        -> { where.not(order_id: nil) }

  # class methods

  ## Creates the Invoice from stripe data sent to a StripeApiEvent ##
  def self.build_from_stripe_data(stripe_data_hash)
    inv = nil
    # This is wrapped in a transaction block to ensure that the Invoice record does not save unless all the InvoiceLineItems save successfully. If an InvoiceLineItem record fails all other records including the parent Invoice record will be rolled back.
    Invoice.transaction do
      user = User.find_by_stripe_customer_id(stripe_data_hash[:customer])
      subscription = Subscription.where(stripe_guid: stripe_data_hash[:subscription]).last
      currency = Currency.find_by_iso_code(stripe_data_hash[:currency].upcase)

      if user && subscription && currency
        inv = Invoice.new(
          user_id: user.id,
          subscription_id: subscription.id,
          number_of_users: 1,
          currency_id: currency.id,
          issued_at: Time.at(stripe_data_hash[:created]),
          stripe_guid: stripe_data_hash[:id],
          sub_total: stripe_data_hash[:subtotal].to_i / 100.0,
          total: stripe_data_hash[:total].to_i / 100.0,
          total_tax: stripe_data_hash[:tax].to_i / 100.0,
          stripe_customer_guid: stripe_data_hash[:customer],
          object_type: stripe_data_hash[:object],
          payment_attempted: stripe_data_hash[:attempted],
          payment_closed: stripe_data_hash[:status_transitions][:finalized_at].present?,
          forgiven: stripe_data_hash[:status] == 'uncollectible',
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
          original_stripe_data: stripe_data_hash.to_hash
        )
        if inv.save
          begin
            stripe_data_hash[:lines][:data].each do |line_item|
              InvoiceLineItem.build_from_stripe_data(inv.id, line_item, inv.subscription_id)
            end
          rescue NoMethodError
            Rails.logger.error "ERROR: Invoice with id #{inv.id} was be rolledback due to the error in creating invoice line items."
            inv = nil
            raise ActiveRecord::Rollback
          end
        else
          Rails.logger.error "ERROR: Invoice#build_from_stripe_data failed to saved an invoice. Errors: #{inv.errors.full_messages.inspect}. Original data: #{stripe_data_hash}."
        end
      else
        Rails.logger.error "ERROR: Invoice#build_from_stripe_data find User-#{stripe_data_hash[:customer]}, Subscription-#{stripe_data_hash[:subscription]} OR Currency-#{stripe_data_hash[:currency].upcase}"
      end
    end
    inv
  end

  def self.build_from_paypal_data(paypal_body)
    inv = Invoice.find_or_initialize_by(paypal_payment_guid: paypal_body['resource']['id'])
    subscription = Subscription.find_by(paypal_subscription_guid: paypal_body['resource']['billing_agreement_id'])
    Invoice.transaction do
      if subscription.user && subscription && subscription.currency
        inv.assign_attributes(
          user_id: subscription.user.id,
          subscription_id: subscription.id,
          number_of_users: 1,
          currency_id: subscription.currency.id,
          issued_at: Time.parse(paypal_body['create_time']),
          total: paypal_body['resource']['amount']['total'].to_f,
          sub_total: paypal_body['resource']['amount']['total'].to_f,
          paypal_payment_guid: paypal_body['resource']['id']
        )
        if inv.save
          begin
            InvoiceLineItem.build_from_paypal_data(inv)
          rescue NoMethodError
            Rails.logger.error "ERROR: Invoice with id #{inv.id} was be rolledback due to the error in creating invoice line items."
            inv = nil
            raise ActiveRecord::Rollback
          end
        else
          Rails.logger.error "ERROR: Invoice#build_from_paypal_data failed to saved an invoice. Errors: #{inv.errors.full_messages.inspect}. Original data: #{paypal_body}."
        end
      else
        Rails.logger.error "ERROR: Invoice#build_from_paypal_data find Billing Agreement-#{paypal_body['resource']['billing_agreement_id']}}"
      end
    end

    inv
  end

  def mark_payment_action_required
    update!(requires_3d_secure: true)
    subscription.mark_payment_action_required!
    send_3d_secure_email
  end

  def mark_payment_action_successful
    update!(requires_3d_secure: false)
    subscription.restart!
  end

  ## Updates the Invoice from stripe data sent to a StripeApiEvent ##
  def update_from_stripe(invoice_guid)
    stripe_invoice = Stripe::Invoice.retrieve(invoice_guid)
    if stripe_invoice
      invoice = Invoice.find_by_stripe_guid(stripe_invoice[:id])
      if invoice
        invoice.update_attributes(
          sub_total: stripe_invoice[:subtotal].to_i / 100.0,
          total: stripe_invoice[:total].to_i / 100.0,
          total_tax: stripe_invoice[:tax].to_i / 100.0,
          payment_attempted: stripe_invoice[:attempted],
          payment_closed: stripe_invoice[:status_transitions][:finalized_at].present?,
          forgiven: stripe_invoice[:status] == 'uncollectible',
          paid: stripe_invoice[:paid],
          livemode: stripe_invoice[:livemode],
          attempt_count: stripe_invoice[:attempt_count],
          amount_due: stripe_invoice[:amount_due],
          next_payment_attempt_at: (stripe_invoice[:next_payment_attempt] ? Time.at(stripe_invoice[:next_payment_attempt]) : nil),
          webhooks_delivered_at: (stripe_invoice[:webhooks_delivered_at] ? Time.at(stripe_invoice[:webhooks_delivered_at]) : nil),
          charge_guid: stripe_invoice[:charge]
        )
      else
        Rails.logger.debug "Error: Invoice#update_from_stripe failed to find an Invoice #{stripe_invoice[:id]}"
      end
    else
      Rails.logger.debug "Error: Invoice#update_from_stripe failed to find a Stripe Invoice-#{invoice_guid}."
    end
  end

  # instance methods
  def destroyable?
    self.invoice_line_items.empty?
  end

  def send_receipt(account_url)
    return if Rails.env.test?
    invoice_url = UrlHelper.instance.subscription_invoices_url(
      id, locale: 'en', format: 'pdf', host: LEARNSIGNAL_HOST
    )
    MandrillWorker.perform_async(
      user_id, 'send_successful_payment_email', account_url,
      invoice_url
    )
  end

  def send_3d_secure_email
    return if Rails.env.test?

    invoice_url = UrlHelper.instance.show_invoice_url(sca_verification_guid,
                                                      locale: 'en',
                                                      host: LEARNSIGNAL_HOST)
    MandrillWorker.perform_async(user_id, 'send_sca_confirmation_email', invoice_url)
  end

  ## Used in the views to show state of the invoice ##
  def status
    if paid && payment_closed
      'Paid'
    elsif requires_3d_secure && !paid && !payment_closed
      'Pending Authentication'
    elsif payment_attempted && next_payment_attempt_at.to_i > 0
      'Past Due'
    elsif !paid && !payment_closed
      'Pending'
    elsif payment_attempted && payment_closed && !paid
      'Closed'
    else
      'Other'
    end
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

  def set_issued_at
    return if self.issued_at.present?

    update(issued_at: Time.zone.now)
  end

  def generate_sca_guid
    return if sca_verification_guid.present?

    update(sca_verification_guid: SecureRandom.uuid)
  end

  def strip_invoice?
    subscription_guid.present?
  end
end
