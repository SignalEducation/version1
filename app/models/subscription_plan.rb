# == Schema Information
#
# Table name: subscription_plans
#
#  id                          :integer          not null, primary key
#  available_to_students       :boolean          default(FALSE), not null
#  available_to_corporates     :boolean          default(FALSE), not null
#  all_you_can_eat             :boolean          default(TRUE), not null
#  payment_frequency_in_months :integer          default(1)
#  currency_id                 :integer
#  price                       :decimal(, )
#  available_from              :date
#  available_to                :date
#  stripe_guid                 :string(255)
#  trial_period_in_days        :integer          default(0)
#  created_at                  :datetime
#  updated_at                  :datetime
#

class SubscriptionPlan < ActiveRecord::Base

  # attr-accessible
  attr_accessible :available_to_students, :available_to_corporates,
                  :all_you_can_eat, :payment_frequency_in_months,
                  :currency_id, :price, :available_from, :available_to,
                  :trial_period_in_days

  # Constants
  PAYMENT_FREQUENCIES = [1,3,6,12]

  # relationships
  belongs_to :currency
  has_many :subscriptions

  # validation
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

  # callbacks
  before_destroy :check_dependencies
  before_create :create_on_stripe_platform
  before_update :update_on_stripe_platform

  # scopes
  scope :all_in_order, -> { order(:currency_id, :available_from, :price) }
  scope :all_active, -> { where('available_from <= :date AND available_to >= :date', date: Proc.new{Time.now.gmtime.to_date}.call) }
  scope :for_corporates, -> { where(available_to_corporates: true) }
  scope :for_students, -> { where(available_to_students: true) }
  scope :in_currency, lambda { |ccy_id| where(currency_id: ccy_id) }

  # class methods

  # instance methods
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
  def destroyable?
    self.subscriptions.empty?
  end

  protected

  def available_to_in_the_future
    unless self.available_to && self.available_to.to_date > Proc.new{Time.now.gmtime.to_date}.call
      errors.add(:available_to, I18n.t('models.subscription_plans.must_be_in_the_future'))
    end
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def create_on_stripe_platform
    stripe_plan = Stripe::Plan.create(
            amount: (self.price * 100).to_i,
            interval: 'month',
            interval_count: self.payment_frequency_in_months,
            trial_period_days: self.trial_period_in_days,
            name: 'LearnSignal ' + I18n.t("views.student_sign_ups.form.payment_frequency_in_months.a#{self.payment_frequency_in_months}"),
            statement_description: 'LearnSignal',
            currency: self.currency.iso_code.downcase,
            id: Rails.env + '-' + ApplicationController::generate_random_code(20)
    )

    self.stripe_guid = stripe_plan.id
  end

  def update_on_stripe_platform
    # todo stripe integration
    # self.stripe_guid = self.stripe_guid.split('-')[0] + '-' + ((self.stripe_guid.split('-')[1].to_i + 1).to_s)
  end

end
