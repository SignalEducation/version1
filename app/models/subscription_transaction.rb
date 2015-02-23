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

  serialize :original_data, Hash

  # attr-accessible
  attr_accessible :user_id, :subscription_id, :stripe_transaction_guid,
                  :transaction_type, :amount, :currency_id, :alarm,
                  :live_mode, :original_data, :subscription_payment_card_id

  # Constants
  TRANSACTION_TYPES = %w(payment refund failed_payment trialing)

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
    stripe_sub_data = subscription.stripe_customer_data[:subscriptions][:data][0]
    if stripe_sub_data[:status] == 'trialing'
      tran_type = 'trialing'
    elsif stripe_sub_data[:status] == 'active'
      tran_type = 'payment'
    else
      tran_type = 'failed_payment'
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
            subscription_payment_card_id: create_payment_card(stripe_sub_data[:cards][:data], subscription.user_id, stripe_sub_data[:default_card])
    )
  end

  def self.create_payment_card(stripe_card_array, user_id, default_card_guid)
    id_of_default = nil
    stripe_card_array.each do |stripe_card_data|
      x = SubscriptionPaymentCard.where(stripe_card_guid: stripe_card_data[:id]).first_or_initialize(
              user_id: user_id,
              stripe_card_guid: stripe_card_data[:id],
              status: 'live',
              brand: stripe_card_data[:brand],
              last_4: stripe_card_data[:last4],
              expiry_month: stripe_card_data[:exp_month],
              expiry_year: stripe_card_data[:exp_year],
              billing_address: stripe_card_data[:address_line1].to_s +
                      stripe_card_data[:address_line2].to_s +
                      stripe_card_data[:address_city].to_s +
                      stripe_card_data[:address_state].to_s +
                      stripe_card_data[:address_zip].to_s,
              billing_country: stripe_card_data[:address_country],
              billing_country_id: Country.find_by_iso_code(stripe_card_data[:country]),
              stripe_object_name: stripe_card_data[:stripe_object_name],
              funding: stripe_card_data[:funding],
              cardholder_name: stripe_card_data[:name],
              fingerprint: stripe_card_data[:fingerprint],
              cvc_checked: stripe_card_data[:cvc_check],
              address_line1_check: stripe_card_data[:address_line1_check],
              address_zip_check: stripe_card_data[:address_zip_check],
              dynamic_last4: stripe_card_data[:dynamic_last4],
              customer_guid: stripe_card_data[:customer],
              is_default_card: default_card_guid == stripe_card_data[:id]


      )
      x.valid?
      puts x.errors
      x.save!
      id_of_default = x.id if x.is_default_card
    end
    if id_of_default.to_i > 0
      SubscriptionPaymentCard.where(user_id: user_id, is_default_card: true).where('stripe_card_guid != ?', default_card_guid).update_all(is_default_card: false, status: 'not-live')
    end
    id_of_default
  end

  # instance methods
  def destroyable?
    !self.live_mode && self.invoices.empty?
  end

  protected

end
