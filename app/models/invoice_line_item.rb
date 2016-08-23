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

class InvoiceLineItem < ActiveRecord::Base

  serialize :original_stripe_data, Hash

  # attr-accessible
  attr_accessible :invoice_id, :amount, :currency_id, :prorated, :period_start_at,
                  :period_end_at, :subscription_id, :subscription_plan_id,
                  :original_stripe_data

  # Constants

  # relationships
  belongs_to :invoice
  belongs_to :currency
  belongs_to :subscription
  belongs_to :subscription_plan

  # validation
  validates :invoice_id, presence: true
  validates :amount, presence: true
  validates :currency_id, presence: true
  validates :period_start_at, presence: true
  validates :period_end_at, presence: true
  validates :subscription_id, presence: true
  validates :subscription_plan_id, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:invoice_id) }

  # class methods
  def self.build_from_stripe_data(invoice_id, stripe_hash, subscription_id)
    li = InvoiceLineItem.new(
            invoice_id: invoice_id,
            amount: stripe_hash[:amount] / 100.0,
            currency_id: Currency.find_by_iso_code(stripe_hash[:currency].upcase).id,
            prorated: stripe_hash[:proration],
            period_start_at: Time.at(stripe_hash[:period][:start]),
            period_end_at: Time.at(stripe_hash[:period][:end]),
            subscription_id: subscription_id,
            subscription_plan_id: SubscriptionPlan.find_by_stripe_guid(stripe_hash[:plan][:id]).id,
            original_stripe_data: stripe_hash.to_hash
    )
    unless li.save
      Rails.logger.error "ERROR: InvoiceLineItems#build_from_stripe_data failed to create. Errors: #{li.errors.inspect}. Original Data: #{stripe_hash}."
    end
  end

  # instance methods
  def destroyable?
    #!Rails.env.production?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
