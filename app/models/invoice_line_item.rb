
# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_line_items
#
#  id                   :integer          not null, primary key
#  invoice_id           :integer
#  amount               :decimal(, )
#  currency_id          :integer
#  prorated             :boolean
#  period_start_at      :datetime
#  period_end_at        :datetime
#  subscription_id      :integer
#  subscription_plan_id :integer
#  original_stripe_data :text
#  created_at           :datetime
#  updated_at           :datetime
#

class InvoiceLineItem < ApplicationRecord
  serialize :original_stripe_data, Hash

  # Constants

  # relationships
  belongs_to :invoice
  belongs_to :currency
  belongs_to :subscription, optional: true
  belongs_to :subscription_plan, optional: true

  # validation
  validates :invoice_id, :amount, :currency_id, presence: true
  validates :subscription_id, :subscription_plan_id, presence: true, if: :subscription_invoice?

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:invoice_id) }
  scope :all_prorated, -> { where(prorated: true) }

  # class methods
  def self.build_from_stripe_data(invoice_id, stripe_hash, subscription_id)
    li = InvoiceLineItem.new(
      invoice_id: invoice_id,
      amount: stripe_hash[:amount] / 100.0,
      currency_id: Currency.find_by(iso_code: stripe_hash[:currency].upcase).id,
      prorated: stripe_hash[:proration],
      period_start_at: Time.zone.at(stripe_hash[:period][:start]),
      period_end_at: Time.zone.at(stripe_hash[:period][:end]),
      subscription_id: subscription_id,
      subscription_plan_id: SubscriptionPlan.find_by(stripe_guid: stripe_hash[:plan][:id]).id,
      original_stripe_data: stripe_hash.to_hash
    )
    return if li.save

    Rails.logger.error "ERROR: InvoiceLineItems#build_from_stripe_data failed to create. Errors: #{li.errors.inspect}. Original Data: #{stripe_hash}."
  end

  def self.build_from_paypal_data(invoice)
    return false if invoice.invoice_line_items.any?

    invoice.invoice_line_items.create!(
      amount: invoice.total,
      currency_id: invoice.currency_id,
      subscription_id: invoice.subscription_id,
      subscription_plan_id: invoice.subscription.subscription_plan_id
    )
  end

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end

  def subscription_invoice?
    subscription.present?
  end
end
