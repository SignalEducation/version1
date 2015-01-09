# == Schema Information
#
# Table name: subscription_transactions
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  subscription_id              :integer
#  stripe_transaction_guid      :string(255)
#  transaction_type             :string(255)
#  amount                       :decimal(, )
#  currency_id                  :integer
#  alarm                        :boolean          default(FALSE), not null
#  live_mode                    :boolean          default(FALSE), not null
#  original_data                :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  subscription_payment_card_id :integer
#

class SubscriptionTransaction < ActiveRecord::Base

  include LearnSignalModelExtras

  serialize :original_data

  # attr-accessible
  attr_accessible :user_id, :subscription_id, :stripe_transaction_guid,
                  :transaction_type, :amount, :currency_id, :alarm,
                  :live_mode, :original_data, :subscription_payment_card_id

  # Constants
  TRANSACTION_TYPES = %w(payment refund failed_payment)

  # relationships
  belongs_to :currency
  has_many :invoices
  belongs_to :subscription
  belongs_to :subscription_payment_card
  belongs_to :user # the person that owns the transaction

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_payment_card_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_transaction_guid, presence: true, uniqueness: true
  validates :transaction_type, inclusion: {in: TRANSACTION_TYPES}
  validates :amount, presence: true, numericality: true
  validates :currency_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :original_data, presence: true

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_alarms, -> { where(alarm: true) }

  # class methods
  def self.create_from_stripe_data(subscription)
    stripe_sub_data = subscription.original_stripe_customer_data['subscriptions']['data'][0]
    SubscriptionTransaction.create(
            user_id: subscription.user_id,
            subscription_id: subscription.id,
            stripe_transaction_guid: stripe_sub_data['id'],
            transaction_type: stripe_sub_data['status'],
            amount: stripe_sub_data['plan']['amount'].to_i * 0.01,
            currency_id: Currency.get_by_iso_code(stripe_sub_data['plan']['currency']),
            alarm: 1,
            live_mode: 1,
            original_data: stripe_sub_data,
            subscription_payment_card_id: 1
    )
  end

  # instance methods
  def destroyable?
    !self.live_mode && self.invoices.empty?
  end

  protected

end
