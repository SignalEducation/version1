# == Schema Information
#
# Table name: coupons
#
#  id                 :integer          not null, primary key
#  name               :string
#  code               :string
#  currency_id        :integer
#  livemode           :boolean          default(FALSE)
#  active             :boolean          default(FALSE)
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
#

class Coupon < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :code, :currency_id, :livemode, :active, :amount_off, :duration, :duration_in_months,
                  :max_redemptions, :percent_off, :redeem_by, :times_redeemed, :stripe_coupon_data

  # Constants
  DURATIONS = %w(forever once repeating)

  # relationships
  belongs_to :currency
  has_many :charges
  has_many :subscriptions

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :code, presence: true, uniqueness: true, length: {maximum: 255}
  validates :duration, presence: true, inclusion: {in: DURATIONS}
  validates :currency_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}

  validate :amount_or_percent_off
  validate :duration_months_if_repeating
  validate :currency_if_amount_off_set


  # callbacks
  before_destroy :check_dependencies
  before_create :create_on_stripe
  after_create :activate
  before_destroy :delete_on_stripe

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :all_active, -> { where(active: true) }

  # class methods

  #Called from Subscriptions new form with Ajax through Coupons Controller.
  def self.verify_coupon_and_get_discount(code, plan_id)
    coupon = Coupon.where(code: code, active: true).first
    sub_plan = SubscriptionPlan.find(plan_id)
    valid = false
    discounted_price = sub_plan.currency.format_number(sub_plan.price)

    if coupon && coupon.active
      if coupon.amount_off
        discounted_number = sub_plan.price.to_f - (coupon.amount_off/100).to_f
        discounted_price = sub_plan.currency.format_number(discounted_number)
        valid = true if (coupon.currency_id == sub_plan.currency_id) && (discounted_number > 0)
      elsif coupon.percent_off
        discounted_number = (sub_plan.price.to_f/100)*coupon.percent_off
        discounted_price = sub_plan.currency.format_number(discounted_number)
        valid = true if discounted_number > 0
      end
    end
    return valid, discounted_price
  end

  #Called from Subscriptions#create action
  def self.get_and_verify(coupon_param, sub_plan_id)
    coupon = Coupon.where(code: coupon_param, active: true).first
    sub_plan = SubscriptionPlan.where(id: sub_plan_id).first

    if coupon && coupon.amount_off
      discounted_number = sub_plan.price.to_f - (coupon.amount_off/100).to_f
      if coupon.currency_id != sub_plan.currency_id || discounted_number < 0
        coupon = nil
      end
    end

    return coupon
  end

  # instance methods

  def destroyable?
    true
  end

  def amount_or_percent_off
    if self.amount_off.blank? && self.percent_off.blank?
      errors.add(:base, I18n.t('models.coupons.must_populate_one'))
    end

    if self.amount_off && self.percent_off
      errors.add(:base, I18n.t('models.coupons.cant_populate_both'))
    end
  end

  def duration_months_if_repeating
    if self.duration == 'repeating' && self.duration_in_months.blank?
      errors.add(:base, I18n.t('models.coupons.must_populate_duration_months'))
    end
  end

  def currency_if_amount_off_set
    if self.amount_off && self.currency_id.blank?
      errors.add(:base, I18n.t('models.coupons.must_populate_currency_if_amount_off'))
    end
  end


  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def activate
    strip_coupon = Stripe::Coupon.retrieve(id: self.code)
    if strip_coupon && strip_coupon[:valid]
      self.update_column(:active, true)
    end
  end

  def create_on_stripe
    unless self.stripe_coupon_data
      strip_coupon = Stripe::Coupon.create(id: self.code, currency: self.currency.try(:iso_code),
                                           percent_off: self.percent_off, amount_off: self.amount_off,
                                           duration: self.duration, duration_in_months: self.duration_in_months,
                                           max_redemptions: self.max_redemptions, redeem_by: self.redeem_by.try(:to_i))

      if strip_coupon
        self.active = strip_coupon[:valid]
        self.livemode = strip_coupon[:livemode]
        self.times_redeemed = strip_coupon[:times_redeemed]
        self.stripe_coupon_data = strip_coupon.to_hash.deep_dup
      end
    end
  end

  def delete_on_stripe
    strip_coupon = Stripe::Coupon.retrieve(id: self.code)
    strip_coupon.delete if strip_coupon
  end

end
