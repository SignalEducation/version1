# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  available_to_students         :boolean          default(FALSE), not null
#  available_to_corporates       :boolean          default(FALSE), not null
#  all_you_can_eat               :boolean          default(TRUE), not null
#  payment_frequency_in_months   :integer          default(1)
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string
#  trial_period_in_days          :integer          default(0)
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default(FALSE)
#

class SubscriptionPlan < ActiveRecord::Base

  include ActionView::Helpers::TextHelper
  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :available_to_students, :available_to_corporates,
                  :all_you_can_eat, :payment_frequency_in_months,
                  :currency_id, :price, :available_from, :available_to,
                  :trial_period_in_days, :name, :subscription_plan_category_id,
                  :livemode

  # Constants
  PAYMENT_FREQUENCIES = [1,3,6,12]

  # relationships
  belongs_to :currency
  has_many :invoice_line_items
  has_many :subscriptions
  belongs_to :subscription_plan_category

  # validation
  validates :name, presence: true, length: { maximum: 255 }
  validates :payment_frequency_in_months, inclusion: {in: PAYMENT_FREQUENCIES}
  validates :currency_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :price, presence: true,
            numericality: {greater_than_or_equal_to: 0}
  validates :available_from, presence: true
  validates :available_to, presence: true
  validate  :available_to_in_the_future
  validates :trial_period_in_days, presence: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0,
                           less_than: 32}
  validates :subscription_plan_category_id, allow_blank: true,
            numericality: {greater_than_or_equal_to: 0}
  validate  :one_of_customer_types_checked
  validates_length_of :stripe_guid, maximum: 255, allow_blank: true

  # callbacks
  before_create :create_on_stripe_platform
  before_update :update_on_stripe_platform
  after_destroy :delete_on_stripe_platform

  # scopes
  scope :all_in_order, -> { order(:currency_id, :available_from, :price) }
  scope :all_active, -> { where('available_from <= :date AND available_to >= :date', date: Proc.new{Time.now.gmtime.to_date}.call) }
  scope :for_corporates, -> { where(available_to_corporates: true) }
  scope :for_students, -> { where(available_to_students: true) }
  scope :generally_available, -> { where(subscription_plan_category_id: nil) }
  scope :in_currency, lambda { |ccy_id| where(currency_id: ccy_id) }

  # class methods
  def self.generally_available_or_for_category_guid(the_guid)
    plan_category = SubscriptionPlanCategory.active_with_guid(the_guid).first
    if plan_category
      where(subscription_plan_category_id: plan_category.id)
    else
      generally_available
    end
  end

  # instance methods
  def active?
    self.available_from < Proc.new{Time.now}.call && self.available_to > Proc.new{Time.now}.call
  end

  def age_status
    right_now = Proc.new{Time.now}.call.to_date
    if self.available_from > right_now
       'info' # future
    elsif self.available_to < right_now
      'active' # expired
    else
      'success' # live
    end
  end

  def description
    self.description_without_trial + "\r\n" +
            (self.trial_period_in_days > 0 ?
                (self.trial_period_in_days).to_s + (I18n.t('views.general.day') + I18n.t('views.general.free_trial')) +
                     "\r\n" : '')
  end

  def description_without_trial
    self.currency.format_number(self.price) + "\r\n" + (self.all_you_can_eat ?
                                              I18n.t('views.general.all_you_can_eat_yes') :
                                              I18n.t('views.general.all_you_can_eat_no') )
  end

  def destroyable?
    self.subscriptions.empty? && self.livemode == Invoice::STRIPE_LIVE_MODE
  end

  protected

  def available_to_in_the_future
    unless self.available_to && self.available_to.to_date > Proc.new{Time.now.gmtime.to_date}.call
      errors.add(:available_to, I18n.t('models.subscription_plans.must_be_in_the_future'))
    end
  end

  def create_on_stripe_platform
    if self.stripe_guid.nil? # would be !nil while importing from website v2
      stripe_plan = Stripe::Plan.create(
              amount: (self.price.to_f * 100).to_i,
              interval: 'month',
              interval_count: self.payment_frequency_in_months.to_i,
              trial_period_days: self.trial_period_in_days.to_i,
              name: 'LearnSignal ' + self.name.to_s,
              statement_descriptor: 'LearnSignal',
              currency: self.currency.try(:iso_code).try(:downcase),
              id: Rails.env + '-' + ApplicationController::generate_random_code(20)
      )
      self.stripe_guid = stripe_plan.id
      self.livemode = stripe_plan[:livemode]
      if self.livemode == Invoice::STRIPE_LIVE_MODE
        true
      else
        errors.add(:stripe, I18n.t('models.general.live_mode_error'))
        return false
      end
    else
      true
    end
  rescue => e
    errors.add(:stripe, e.message)
    false
  end

  def delete_on_stripe_platform
    if self.destroyable?
      stripe_plan = Stripe::Plan.retrieve(self.stripe_guid)
      stripe_plan.delete
    end
  rescue => e
    errors.add(:stripe, e.message)
    false
  end

  def one_of_customer_types_checked
    if !self.available_to_students && !self.available_to_corporates
      errors.add(:base, I18n.t('models.subscription_plans.at_least_one_customer_type'))
      false
    end
  end

  def update_on_stripe_platform
    stripe_plan = Stripe::Plan.retrieve(self.stripe_guid)
    stripe_plan.name = 'Learnsignal ' + self.name
    stripe_plan.save
  rescue => e
    errors.add(:stripe, e.message)
    false
  end

end
