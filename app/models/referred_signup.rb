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
  attr_accessible :referral_code_id, :user_id, :referrer_url, :maturing_on, :payed_at

  # Constants

  # relationships
  belongs_to :referral_code
  belongs_to :user
  belongs_to :subscription

  # validation
  validates :referral_code_id, presence: true,
            uniqueness: { scope: :user_id, message: I18n.t('models.referred_signups.user_can_be_referred_only_once') }
  validates :user_id, presence: true

  # callbacks
  before_destroy :check_dependencies
  after_update :check_conversion_count

  # scopes
  scope :all_in_order, -> { order(:referral_code_id) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :last_month, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :all_payed, -> { where.not(payed_at: nil) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :one_month_ago, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :two_months_ago, -> { where(created_at: 2.month.ago.beginning_of_month..2.month.ago.end_of_month) }
  scope :three_months_ago, -> { where(created_at: 3.month.ago.beginning_of_month..3.month.ago.end_of_month) }


  # class methods

  # instance methods
  def destroyable?
    true
  end

  def referrer_user
    self.referral_code.user
  end

  protected

  def check_conversion_count
    if referrer_user.student_user?
      current_referrals = ReferredSignup.this_month.where(referral_code_id: self.referral_code_id)
      current_payed_referrals = current_referrals.where.not(payed_at: nil)
      if current_payed_referrals.count == 5
        credit_stripe_account
      end
    else
      return nil
    end
  end

  def credit_stripe_account
    currency = referrer_user.country.currency
    monthly_plan = SubscriptionPlan.in_currency(currency).where(payment_frequency_in_months: 1).last
    monthly_plan_price = monthly_plan.price
    price_in_cents = (monthly_plan_price.to_d * 100).to_i
    stripe_customer = Stripe::Customer.retrieve(self.referral_code.user.stripe_customer_id)
    stripe_customer.account_balance = price_in_cents * (-1)
    stripe_customer.save
    referrer_user.update_attribute(:stripe_account_balance, stripe_customer.account_balance)
    amount = monthly_plan.currency.format_number(monthly_plan.price)
    ReferralsWorker.perform_async(referrer_user.id, 'send_referral_discount_email', amount) unless Rails.env.test?
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
