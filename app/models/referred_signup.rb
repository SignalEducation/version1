# == Schema Information
#
# Table name: referred_signups
#
#  id               :integer          not null, primary key
#  referral_code_id :integer
#  user_id          :integer
#  referrer_url     :string(2048)
#  subscription_id  :integer
#  maturing_on      :datetime
#  payed_at         :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ReferredSignup < ActiveRecord::Base

  # attr-accessible
  attr_accessible :referral_code_id, :user_id, :referrer_url, :subscription_id, :maturing_on, :payed_at

  # Constants

  # relationships
  belongs_to :referral_code
  belongs_to :user
  belongs_to :subscription

  # validation
  validates :referral_code_id, presence: true,
            uniqueness: { scope: :user_id, message: I18n.t('models.referred_signups.user_can_be_referred_only_once') }
  validates :user_id, presence: true
  validates :subscription_id, presence: true

  # callbacks
  before_destroy :check_dependencies
  after_save :check_conversion_count

  # scopes
  scope :all_in_order, -> { order(:referral_code_id) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :last_month, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :all_payed, -> { where.not(payed_at: nil) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_conversion_count
    current_referrals = ReferredSignup.this_month.where(referral_code_id: self.referral_code_id).count
    if payed_at && current_referrals == 5
      credit_stripe_account
    end
  end

  def credit_stripe_account
    referrer_user = self.referral_code.user
    referrer_subscription_plan = referrer_user.subscriptions.first.subscription_plan
    sub_plan_currency = referrer_subscription_plan.currency
    monthly_plan = SubscriptionPlan.in_currency(sub_plan_currency).where(payment_frequency_in_months: 1).last
    monthly_plan_price = monthly_plan.price
    price_in_cents = (monthly_plan_price.to_d * 100).to_i
    stripe_customer = Stripe::Customer.retrieve(self.referral_code.user.stripe_customer_id)
    stripe_customer.account_balance = price_in_cents * (-1)
    stripe_customer.save
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
