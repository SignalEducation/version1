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

  serialize :original_data

  # attr-accessible
  attr_accessible :user_id, :subscription_id, :stripe_transaction_guid,
                  :transaction_type, :amount, :currency_id, :alarm,
                  :live_mode, :original_data, :subscription_payment_card_id

  # Constants
  TRANSACTION_TYPES = %w(payment refund failed_payment)

  # relationships
  belongs_to :currency
  # todo has_many :invoices
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
  validates :stripe_transaction_guid, presence: true
  validates :transaction_type, inclusion: {in: TRANSACTION_TYPES}
  validates :amount, presence: true, numericality: true
  validates :currency_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :original_data, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_alarms, -> { where(alarm: true) }

  # class methods

  # instance methods
  def destroyable?
    !self.live_mode
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
