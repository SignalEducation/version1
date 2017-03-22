# == Schema Information
#
# Table name: subscription_transactions
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  subscription_id              :integer
#  stripe_transaction_guid      :string
#  transaction_type             :string
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

  serialize :original_data, Hash

  # attr-accessible
  attr_accessible :user_id, :subscription_id, :stripe_transaction_guid,
                  :transaction_type, :amount, :currency_id, :alarm,
                  :live_mode, :original_data, :subscription_payment_card_id

  # Constants
  ## All SubscriptionTransactions are 'payment'
  #TODO add creation of SubscriptionTransaction for failed subscription cancel event with the status of failed_payment
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
  validates :transaction_type, inclusion: {in: TRANSACTION_TYPES}, length: { maximum: 255 }
  validates :amount, presence: true, numericality: true
  validates :currency_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :original_data, presence: true

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_alarms, -> { where(alarm: true) }

  # class methods

  #Called as an after_create in Subscription model
  def self.create_from_stripe_data(subscription)
    stripe_sub_data = subscription.stripe_customer_data[:subscriptions][:data][0]
    stripe_card_data = subscription.stripe_customer_data[:cards] ?
            subscription.stripe_customer_data[:cards] :
            subscription.stripe_customer_data[:sources]
    default_card = SubscriptionPaymentCard.find_by_stripe_card_guid(subscription.stripe_customer_data[:default_card])
    if stripe_sub_data[:status] == 'active'
      tran_type = 'payment'
    else
      tran_type = 'failed_payment'
    end
    if default_card
      card_id = default_card.try(:id)
    else
      new_card_id = SubscriptionPaymentCard.create_cards_from_stripe_array(stripe_card_data[:data], subscription.user_id, (subscription.stripe_customer_data[:default_source] || subscription.stripe_customer_data[:default_card]))
      new_card = SubscriptionPaymentCard.find(new_card_id)
      card_id = new_card.try(:id)
    end
    SubscriptionTransaction.create!(
            user_id: subscription.user_id,
            subscription_id: subscription.id,
            stripe_transaction_guid: stripe_sub_data[:id],
            transaction_type: tran_type,
            amount: stripe_sub_data[:plan][:amount].to_i * 0.01,
            currency_id: Currency.get_by_iso_code(stripe_sub_data[:plan][:currency].upcase).id,
            alarm: 1,
            live_mode: (Rails.env.production? ? true : false),
            original_data: stripe_sub_data.to_hash,
            subscription_payment_card_id: card_id
    )
  rescue => e
    Rails.logger.error "ERROR: SubscriptionTransaction#create_from_stripe_data failed to save. Error:#{e.inspect}"
    return false
  end

  # instance methods
  def destroyable?
    !self.live_mode && self.invoices.empty?
  end

  protected

end
