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
#  alarm                        :boolean          default("false"), not null
#  live_mode                    :boolean          default("false"), not null
#  original_data                :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  subscription_payment_card_id :integer
#

class SubscriptionTransaction < ApplicationRecord
  include LearnSignalModelExtras
  serialize :original_data, Hash

  # Constants
  ## All SubscriptionTransactions are 'payment'
  # TODO add creation of SubscriptionTransaction for failed subscription cancel event with the status of failed_payment
  TRANSACTION_TYPES = %w(payment refund failed_payment)

  # relationships
  belongs_to :currency
  has_many :invoices
  belongs_to :subscription
  belongs_to :subscription_payment_card
  belongs_to :user

  # validation
  validates :user_id, presence: true
  validates :subscription_id, presence: true
  #validates :subscription_payment_card_id, presence: true
  validates :stripe_transaction_guid, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES }, length: { maximum: 255 }
  validates :amount, presence: true, numericality: true
  validates :currency_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :original_data, presence: true

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_alarms, -> { where(alarm: true) }

  # instance methods
  def destroyable?
    !live_mode && invoices.empty?
  end
end
