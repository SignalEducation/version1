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
#  stripe_guid                 :string(255)
#  sub_total                   :decimal(, )      default("0")
#  total                       :decimal(, )      default("0")
#  total_tax                   :decimal(, )      default("0")
#  stripe_customer_guid        :string(255)
#  object_type                 :string(255)      default("invoice")
#  payment_attempted           :boolean          default("false")
#  payment_closed              :boolean          default("false")
#  forgiven                    :boolean          default("false")
#  paid                        :boolean          default("false")
#  livemode                    :boolean          default("false")
#  attempt_count               :integer          default("0")
#  amount_due                  :decimal(, )      default("0")
#  next_payment_attempt_at     :datetime
#  webhooks_delivered_at       :datetime
#  charge_guid                 :string(255)
#  subscription_guid           :string(255)
#  tax_percent                 :decimal(, )
#  tax                         :decimal(, )
#  original_stripe_data        :text
#  paypal_payment_guid         :string
#  order_id                    :bigint
#  requires_3d_secure          :boolean          default("false")
#  sca_verification_guid       :string
#

class Invoice < ApplicationRecord
  include InvoiceReport
  include LearnSignalModelExtras
  require 'securerandom'

  serialize :original_stripe_data, Hash

  # Constants
  STRIPE_LIVE_MODE = (ENV['LEARNSIGNAL_V3_STRIPE_LIVE_MODE'] == 'live')
  CLOSED_STATUSES = %w[paid uncollectible void].freeze

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
  validates :stripe_guid, length: { maximum: 255 }, allow_blank: true
  validates :stripe_customer_guid, length: { maximum: 255 }, allow_blank: true
  validates :charge_guid, length: { maximum: 255 }, allow_blank: true
  validates :object_type, length: { maximum: 255 }, allow_blank: true
  validates :subscription_guid, length: { maximum: 255 }, allow_blank: true

  # callbacks
  after_create :set_vat_rate
  after_create :set_issued_at
  after_create :generate_sca_guid
  after_create :apply_coupon_credit
  before_save :update_total_revenue, if: :will_save_change_to_paid?

  # scopes
  scope :all_in_order,     -> { order(user_id: :asc, id: :desc) }
  scope :subscriptions,    -> { where.not(subscription_id: nil) }
  scope :orders,           -> { where.not(order_id: nil) }
  scope :valids,           -> { where('subscription_id IS NOT NULL OR order_id IS NOT NULL') }
  scope :from_year_start,  -> { where("DATE(created_at) >= ?", Date.today.beginning_of_year) }
  scope :from_yesterday,   -> { where("DATE(created_at) = ?", Date.today - 1) }

  # class methods

  ## Creates the Invoice from stripe data sent to a StripeApiEvent ##
  def self.build_from_stripe_data(stripe_data_hash)
    inv = nil
    # This is wrapped in a transaction block to ensure that the Invoice record does not save unless all the InvoiceLineItems save successfully. If an InvoiceLineItem record fails all other records including the parent Invoice record will be rolled back.
    Invoice.transaction do
      user         = User.find_by(stripe_customer_id: stripe_data_hash[:customer])
      currency     = Currency.find_by(iso_code: stripe_data_hash[:currency].upcase)
      subscription = Subscription.in_reverse_created_order.find_by(stripe_guid: stripe_data_hash[:subscription])

      if user && subscription && currency
        inv = Invoice.new(
          user_id: user.id,
          subscription_id: subscription.id,
          number_of_users: 1,
          currency_id: currency.id,
          issued_at: Time.zone.at(stripe_data_hash[:created]),
          stripe_guid: stripe_data_hash[:id],
          sub_total: stripe_data_hash[:subtotal].to_i / 100.0,
          total: stripe_data_hash[:total].to_i / 100.0,
          total_tax: stripe_data_hash[:tax].to_i / 100.0,
          stripe_customer_guid: stripe_data_hash[:customer],
          object_type: stripe_data_hash[:object],
          payment_attempted: stripe_data_hash[:attempted],
          payment_closed: stripe_data_hash[:closed],
          forgiven: stripe_data_hash[:status] == 'uncollectible',
          paid: stripe_data_hash[:paid],
          livemode: stripe_data_hash[:livemode],
          attempt_count: stripe_data_hash[:attempt_count],
          amount_due: stripe_data_hash[:amount_due].to_i / 100.0,
          next_payment_attempt_at: (stripe_data_hash[:next_payment_attempt] ? Time.zone.at(stripe_data_hash[:next_payment_attempt]) : nil),
          webhooks_delivered_at: (stripe_data_hash[:webhooks_delivered_at] ? Time.zone.at(stripe_data_hash[:webhooks_delivered_at]) : nil),
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
      if subscription.user && subscription && subscription.currency && subscription.paypal_subscription_guid
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

  def user_subscriptions_revenue
    user.subscriptions_revenue
  end

  def user_orders_revenue
    user.orders_revenue
  end

  def user_total_revenue
    user.total_revenue
  end

  def self.to_csv(options = {})
    attributes = %w[inv_id invoice_created sub_id sub_created user_email user_created
                    payment_provider sub_stripe_guid sub_paypal_guid sub_exam_body sub_status sub_type
                    invoice_type payment_interval plan_name currency_symbol plan_price sub_total total
                    card_country user_country hubspot_source hubspot_source_1 hubspot_source_2 first_visit_source
                    first_visit_utm_campaign first_visit_medium first_visit_date first_visit_referring_domain
                    first_visit_landing_page first_visit_referrer user_subscriptions_revenue
                    user_orders_revenue user_total_revenue coupon_code coupon_id]

    CSV.generate(options) do |csv|
      csv << attributes
      all.find_each do |invoice|
        csv << attributes.map { |attr| invoice.send(attr) }
      end
    end
  end

  def self.with_order_to_csv(orders)
    inv_attributes = %w[inv_id invoice_created sub_id sub_created user_email user_created
                        payment_provider sub_stripe_guid sub_paypal_guid sub_exam_body sub_status sub_type
                        invoice_type payment_interval plan_name currency_symbol plan_price sub_total total
                        card_country user_country hubspot_source hubspot_source_1 hubspot_source_2 first_visit_source
                        first_visit_utm_campaign first_visit_medium first_visit_date first_visit_referring_domain
                        first_visit_landing_page first_visit_referrer coupon_code coupon_id]
    ord_attributes = %w[order_id order_created name product_name stripe_id paypal_guid state
                        product_type leading_symbol price user_country card_country]

    CSV.generate do |csv|
      csv << inv_attributes + ord_attributes

      all.find_each do |invoice|
        csv << inv_attributes.map { |attr| invoice.send(attr) }
      end

      orders.find_each do |order|
        csv << inv_attributes.map { '' } + ord_attributes.map { |attr| order.send(attr) }
      end
    end
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
      invoice = Invoice.find_by(stripe_guid: stripe_invoice[:id])
      if invoice
        invoice.update_attributes(
          sub_total: stripe_invoice[:subtotal].to_i / 100.0,
          total: stripe_invoice[:total].to_i / 100.0,
          total_tax: stripe_invoice[:tax].to_i / 100.0,
          payment_attempted: stripe_invoice[:attempted],
          payment_closed: CLOSED_STATUSES.include?(stripe_invoice[:status]),
          forgiven: stripe_invoice[:status] == 'uncollectible',
          paid: stripe_invoice[:paid],
          livemode: stripe_invoice[:livemode],
          attempt_count: stripe_invoice[:attempt_count],
          amount_due: stripe_invoice[:amount_due].to_i / 100.0,
          next_payment_attempt_at: (stripe_invoice[:next_payment_attempt] ? Time.at(stripe_invoice[:next_payment_attempt]) : nil),
          webhooks_delivered_at: (stripe_invoice[:webhooks_delivered_at] ? Time.at(stripe_invoice[:webhooks_delivered_at]) : nil),
          charge_guid: stripe_invoice[:charge],
          requires_3d_secure: invoice.subscription.pending_3d_secure? && !stripe_invoice[:next_payment_attempt]
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
    Message.create(
      process_at: Time.zone.now,
      user_id: user_id,
      kind: :account,
      template: 'send_successful_payment_email',
      subscription_id: subscription_id,
      template_params: {
        url: account_url,
        invoice_url: invoice_url
      }
    )
  end

  def send_3d_secure_email
    return if Rails.env.test?

    invoice_url = UrlHelper.instance.show_invoice_url(sca_verification_guid,
                                                      locale: 'en',
                                                      host: LEARNSIGNAL_HOST)
    Message.create(
      process_at: Time.zone.now,
      user_id: user_id,
      kind: :account,
      template: 'send_sca_confirmation_email',
      template_params: {
        url: invoice_url
      }
    )
  end

  ## Used in the views to show state of the invoice ##
  def status
    if paid && payment_closed
      'Paid'
    elsif requires_3d_secure && !paid && !payment_closed
      'Pending Authentication'
    elsif payment_attempted && next_payment_attempt_at.to_i.positive?
      'Past Due'
    elsif !paid && !payment_closed
      'Pending'
    elsif payment_attempted && payment_closed && !paid
      'Closed'
    else
      'Other'
    end
  end

  def update_total_revenue
    return unless status == 'Paid'

    if order_id.present?
      order.update_revenue(:increment!, total)
    elsif subscription_id.present?
      subscription.update_revenue(:increment!, total)
    end
  end

  # check for yearly subscriptions with a coupoun with once duration aplied on it
  def apply_coupon_credit
    return if Rails.env.test?
    return if subscription.nil?
    StripeInvoiceLogWorker.perform_async(id, 'subscription', subscription.inspect)

    coupon_code = subscription.invoices.first.original_stripe_data.dig(:discount, :coupon, :id)
    return if coupon_code.nil?

    StripeInvoiceLogWorker.perform_async(id, 'coupon_code', coupon_code.inspect)

    coupon = coupon_code ? Coupon.find_by(code: coupon_code) : nil

    return if coupon.nil? || coupon.duration != 'once'
    StripeInvoiceLogWorker.perform_async(id, 'coupon', coupon.inspect)

    return if subscription.subscription_plan.interval_name != 'Yearly'
    return if subscription.invoices.blank? || subscription.invoices.count == 1

    plan        = subscription.subscription_plan
    StripeInvoiceLogWorker.perform_async(id, 'plan', plan.inspect)
    coupon_data = { code: coupon.code, price_discounted: coupon.price_discounted(subscription.subscription_plan_id) }
    StripeInvoiceLogWorker.perform_async(id, 'coupon_data', coupon_data.inspect)
    discounted  = plan.price.to_f - coupon_data[:price_discounted]
    StripeInvoiceLogWorker.perform_async(id, 'discounted', discounted.inspect)
    amount      = (-discounted * 100).to_i
    StripeInvoiceLogWorker.perform_async(id, 'amount', amount.inspect)
    memo        = "Coupon '#{coupon_data[:code]}' applied."
    StripeInvoiceLogWorker.perform_async(id, 'memo', memo.inspect)

    stripe_line_item = Stripe::InvoiceItem.create({
      customer: user.stripe_customer_id,
      invoice: stripe_guid,
      amount: amount,
      currency: currency.iso_code.downcase,
      description: memo
    })

    StripeInvoiceLogWorker.perform_async(id, 'stripe_line_item', stripe_line_item.inspect)

    add_invoice_line_item(stripe_line_item)
  rescue => e
    Rails.logger.error "StripeApiEvent#existing_guid #{e.inspect}"
    SlackService.new.notify_channel('payments',
                                    stripe_failed_notification(e, id),
                                    icon_emoji: 'rotating_light')
  end

  def add_invoice_line_item(stripe_line_item)
    invoice_line_item = InvoiceLineItem.create(
      invoice_id: id,
      amount: stripe_line_item[:amount] / 100.0,
      currency_id: Currency.find_by(iso_code: stripe_line_item[:currency].upcase).id,
      subscription_id: subscription_id,
      subscription_plan_id: subscription.subscription_plan_id,
      original_stripe_data: stripe_line_item.to_hash,
      kind: :credit_note
    )

    StripeInvoiceLogWorker.perform_async(id, 'invoice_line_item', invoice_line_item.inspect)
  rescue => e
    Rails.logger.error "StripeApiEvent#existing_guid #{e.inspect}"
    SlackService.new.notify_channel('payments',
                                    stripe_failed_notification(e, id),
                                    icon_emoji: 'rotating_light')
  end

  protected

  def stripe_failed_notification(error, invoice_id)
    [{ fallback: "Stripe credit note  to invoice ##{invoice_id} have failed.",
       title: "Stripe credit note  to invoice  ##{invoice_id} have failed.\nError: #{error.inspect}",
       title_link: "https://dashboard.stripe.com/invoices/#{stripe_guid}",
       color: '#7CD197',
       footer: 'Stripe' }]
  end

  def set_vat_rate
    country = user.country

    return unless country&.vat_codes&.any?

    vat_code = country.vat_codes.first
    vat_rate = VatRate.where(vat_code_id: vat_code.id)&.all_in_order&.last
    update_attribute(:vat_rate, vat_rate) if vat_rate
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
