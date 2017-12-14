# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  livemode           :boolean          default(TRUE)
#  stripe_refund_data :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Refund < ActiveRecord::Base

  # attr-accessible
  attr_accessible :stripe_guid, :charge_id, :stripe_charge_guid, :invoice_id, :subscription_id, :user_id,
                  :manager_id, :amount, :reason, :status, :livemode, :stripe_refund_data

  # Constants
  REASONS = %w(duplicate fraudulent requested_by_customer)

  # relationships
  belongs_to :charge
  belongs_to :invoice
  belongs_to :subscription
  belongs_to :user
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id

  # validation
  validates :stripe_guid, presence: true, uniqueness: true
  validates :charge_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_charge_guid, presence: true, uniqueness: true
  validates :invoice_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :manager_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :amount, presence: true
  validates :reason, presence: true, inclusion: {in: REASONS}
  validates :status, presence: true
  validates :stripe_refund_data, presence: true

  # callbacks
  before_destroy :check_dependencies
  before_validation :create_on_stripe, unless: 'Rails.env.test?'

  # scopes
  scope :all_in_order, -> { order(:stripe_guid) }

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

  def create_on_stripe
    stripe_refund = Stripe::Refund.create(charge: self.stripe_charge_guid, amount: self.amount, reason: self.reason)

    if stripe_refund
      self.stripe_guid = stripe_refund[:id]
      self.status = stripe_refund[:status]
      self.livemode = stripe_refund[:livemode]
      self.stripe_refund_data = stripe_refund.to_hash.deep_dup
    else
      errors.add(:base, 'Failed to create Refund on Stripe')
    end

  end

end
