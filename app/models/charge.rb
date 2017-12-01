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
#  livemode                     :boolean          default(FALSE)
#  stripe_order_id              :string
#  paid                         :boolean          default(FALSE)
#  refunded                     :boolean          default(FALSE)
#  refunds                      :text
#  status                       :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class Charge < ActiveRecord::Base

  # attr-accessible
  attr_accessible :subscription_id, :invoice_id, :user_id, :subscription_payment_card_id, :currency_id, :coupon_id,
                  :stripe_api_event_id, :stripe_guid, :amount, :amount_refunded, :failure_code, :failure_message,
                  :stripe_customer_id, :stripe_invoice_id, :livemode, :stripe_order_id, :paid, :refunded, :refunds,
                  :status

  # Constants

  # relationships
  belongs_to :subscription
  belongs_to :invoice
  belongs_to :user
  belongs_to :subscription_payment_card
  belongs_to :currency
  belongs_to :coupon
  belongs_to :stripe_api_event

  # validation
  validates :subscription_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :invoice_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_payment_card_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :currency_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :coupon_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_api_event_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_guid, presence: true
  validates :amount, presence: true
  validates :stripe_customer_id, presence: true
  validates :stripe_invoice_id, presence: true
  validates :status, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:subscription_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
