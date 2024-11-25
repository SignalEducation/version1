# == Schema Information
#
# Table name: charges
#
#  id                           :integer          not null, primary key
#  subscription_id              :integer
#  invoice_id                   :integer
#  user_id                      :integer
#  subscription_payment_card_id :integer
#  currency_id                  :integer
#  coupon_id                    :integer
#  stripe_api_event_id          :integer
#  stripe_guid                  :string
#  amount                       :integer
#  amount_refunded              :integer
#  failure_code                 :string
#  failure_message              :text
#  stripe_customer_id           :string
#  stripe_invoice_id            :string
#  livemode                     :boolean          default("false")
#  stripe_order_id              :string
#  paid                         :boolean          default("false")
#  refunded                     :boolean          default("false")
#  stripe_refunds_data          :text
#  status                       :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  original_event_data          :text
#

class Charge < ApplicationRecord
  # Constants

  # relationships
  belongs_to :subscription
  belongs_to :invoice
  belongs_to :user
  belongs_to :subscription_payment_card
  belongs_to :currency
  belongs_to :coupon, optional: true
  belongs_to :stripe_api_event, optional: true
  has_many :refunds

  # validation
  validates :subscription_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :invoice_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :user_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :subscription_payment_card_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :coupon_id, allow_nil: true, numericality: { only_integer: true, greater_than: 0 }
  validates :stripe_guid, presence: true
  validates :amount, presence: true
  validates :status, presence: true

  #These should attributes should be stripe_customer_guid & stripe_invoice_id - don't validate numericality
  validates :stripe_customer_id, presence: true
  validates :stripe_invoice_id, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:subscription_id) }

  # instance methods

  def self.create_from_stripe_data(event)
    invoice      = Invoice.where(stripe_guid: event[:invoice]).first
    subscription = invoice.subscription
    user         = User.where(stripe_customer_id: event[:customer]).first
    card         = SubscriptionPaymentCard.find_by(stripe_card_guid: event[:payment_method])

    Charge.create!(
      subscription_id: subscription.id,
      invoice_id: invoice.id,
      user_id: user.id,
      subscription_payment_card_id: card.id,
      currency_id: subscription.subscription_plan.currency_id,
      coupon_id: subscription.try(:coupon_id),
      stripe_guid: event[:id],
      amount: event[:amount],
      amount_refunded: event[:amount_refunded],
      failure_code: event[:failure_code],
      failure_message: event[:failure_message],
      stripe_customer_id: event[:customer],
      stripe_invoice_id: event[:invoice],
      livemode: event[:livemode],
      stripe_order_id: event[:order],
      paid: event[:paid],
      refunded: event[:refunded],
      stripe_refunds_data: event[:refunds],
      status: event[:status],
      original_event_data: event.to_hash.deep_dup
    )
  rescue => e
    Rails.logger.error "ERROR: Charge#create_from_stripe_data failed to save. Error:#{e.inspect}"
    false
  end

  def self.update_refund_data(event)
    charge = Charge.find_by(stripe_guid: event[:id])
    return if charge.nil?

    charge.update(amount: event[:amount],
                  amount_refunded: event[:amount_refunded],
                  paid: event[:paid],
                  refunded: event[:refunded],
                  stripe_refunds_data: event[:refunds].to_hash.deep_dup,
                  status: event[:status])

    charge
  end

  def destroyable?
    false
  end

  def refundable?
    amount > amount_refunded
  end

  protected

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end
end
