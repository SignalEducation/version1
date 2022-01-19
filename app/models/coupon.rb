# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default("false")
#  active             :boolean          default("false")
#  amount_off         :integer
#  duration           :string
#  duration_in_months :integer
#  max_redemptions    :integer
#  percent_off        :integer
#  redeem_by          :datetime
#  times_redeemed     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_coupon_data :text
#  exam_body_id       :integer
#  monthly_interval   :boolean          default("true")
#  quarterly_interval :boolean          default("true")
#  yearly_interval    :boolean          default("true")
#

class Coupon < ApplicationRecord
  # Constants
  DURATIONS = %w[forever once repeating].freeze

  # relationships
  belongs_to :currency, optional: true
  belongs_to :exam_body, optional: true
  has_many :charges, dependent: :restrict_with_error
  has_many :subscriptions, dependent: :restrict_with_error

  # validation
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :code, presence: true, uniqueness: true, length: { maximum: 255 },
                   format: { with: /\A[a-zA-Z0-9_\-]+\z/,
                             message: 'code may only contain alphanumeric characters in addition to - and _.' }
  validates :duration, presence: true, inclusion: { in: DURATIONS }
  validates :currency_id, allow_nil: true, numericality: { only_integer: true, greater_than: 0 }

  validate :amount_or_percent_off
  validate :duration_months_if_repeating
  validate :currency_if_amount_off_set

  # callbacks
  before_create  :create_on_stripe
  after_create   :activate
  after_update   :update_on_stripe

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :all_active, -> { where(active: true) }

  # class methods

  # Called from Subscriptions new form with Ajax through Coupons Controller.
  def self.verify_coupon_and_get_discount(code, plan_id)
    coupon           = Coupon.find_by(code: code, active: true)
    sub_plan         = SubscriptionPlan.find(plan_id)
    valid            = false
    reason           = 'Invalid Code'
    discounted_price = sub_plan.currency.format_number(sub_plan.price)

    if coupon&.active
      if sub_plan.subscription_plan_category_id
        reason = "Coupons can't be applied to this plan"
      elsif coupon.exam_body && coupon.exam_body != sub_plan.exam_body
        reason = "Coupon can't be applied to #{sub_plan.exam_body.name} plans"
      elsif !coupon.available_payment_intervals.include?(sub_plan.interval_name)
        reason = "Coupon can't be applied to the selected plan"
      elsif coupon.amount_off
        discounted_number = sub_plan.price.to_f - (coupon.amount_off / 100).to_f
        discounted_price = sub_plan.currency.format_number(discounted_number)
        valid = true if (coupon.currency_id == sub_plan.currency_id) && discounted_number.positive?
      elsif coupon.percent_off
        discounted_number = sub_plan.price.to_f - ((sub_plan.price.to_f / 100) * coupon.percent_off)
        discounted_price = sub_plan.currency.format_number(discounted_number)
        valid = true unless discounted_number.negative?
      end
    end
    [valid, discounted_price, reason, coupon&.id]
  end

  # Called from Subscriptions#create action
  def self.get_and_verify(coupon_param, sub_plan_id)
    coupon = Coupon.find_by(code: coupon_param, active: true)
    return coupon if coupon.nil?

    sub_plan = SubscriptionPlan.find(sub_plan_id)

    if coupon&.amount_off
      discounted_number = sub_plan.price.to_f - (coupon.amount_off / 100).to_f
      coupon = nil if coupon.currency_id != sub_plan.currency_id || discounted_number.negative?
    elsif sub_plan.subscription_plan_category_id || (coupon.exam_body && coupon.exam_body != sub_plan.exam_body) || (!coupon.available_payment_intervals.include?(sub_plan.interval_name))
      coupon = nil
    end
    coupon
  end

  # instance methods

  def available_payment_intervals
    intervals = []
    intervals << 'Monthly' if monthly_interval
    intervals << 'Quarterly' if quarterly_interval
    intervals << 'Yearly' if yearly_interval
    intervals
  end

  def amount_or_percent_off
    errors.add(:base, I18n.t('models.coupons.must_populate_one')) if amount_off.blank? && percent_off.blank?
    errors.add(:base, I18n.t('models.coupons.cant_populate_both')) if amount_off && percent_off
  end

  def duration_months_if_repeating
    errors.add(:base, I18n.t('models.coupons.must_populate_duration_months')) if duration == 'repeating' && duration_in_months.blank?
  end

  def currency_if_amount_off_set
    errors.add(:base, I18n.t('models.coupons.must_populate_currency_if_amount_off')) if amount_off && currency_id.blank?
  end

  def update_redeems
    update(times_redeemed: subscriptions.count)
  end

  def deactivate
    stripe_coupon = Stripe::Coupon.retrieve(id: code)
    update(active: false) if stripe_coupon && !stripe_coupon[:valid]
  end

  def update_on_stripe
    return if Rails.env.test?

    Stripe::Coupon.update(code, name: name)
  end

  def price_discounted(plan_id)
    sub_plan = SubscriptionPlan.find(plan_id)

    if amount_off
      sub_plan.price.to_f - (amount_off / 100).to_f
    elsif percent_off
      sub_plan.price.to_f - ((sub_plan.price.to_f / 100) * percent_off)
    end
  end

  protected

  def activate
    return if Rails.env.test?

    stripe_coupon = Stripe::Coupon.retrieve(id: code)
    update(active: true) if stripe_coupon && stripe_coupon[:valid]
  end

  def create_on_stripe
    return if stripe_coupon_data

    stripe_coupon =
      Stripe::Coupon.create(id: code, currency: currency.try(:iso_code),
                            percent_off: percent_off,
                            amount_off: amount_off, duration: duration,
                            duration_in_months: duration_in_months,
                            max_redemptions: max_redemptions,
                            redeem_by: redeem_by.try(:to_i)) unless Rails.env.test?

    return unless stripe_coupon

    self.active = stripe_coupon[:valid]
    self.livemode = stripe_coupon[:livemode]
    self.times_redeemed = stripe_coupon[:times_redeemed]
    self.stripe_coupon_data = stripe_coupon.to_hash.deep_dup
  end
end
