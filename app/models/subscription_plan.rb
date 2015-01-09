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

  include LearnSignalModelExtras

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
  before_create :create_on_stripe_platform
  before_update :update_on_stripe_platform

  # scopes
  scope :all_in_order, -> { order(:available_to_students) }
  scope :all_active, -> { where('available_from <= :date AND available_to >= :date', date: Proc.new{Time.now.gmtime.to_date}.call) }
  scope :in_currency, lambda { |ccy_id| where(currency_id: ccy_id) }

  # class methods

  # instance methods
  def destroyable?
    self.subscriptions.empty?
  end

  protected

  def available_to_in_the_future
    unless self.available_to && self.available_to.to_date > Proc.new{Time.now.gmtime.to_date}.call
      errors.add(:available_to, I18n.t('models.subscription_plans.must_be_in_the_future'))
    end
  end

  def create_on_stripe_platform
    # todo stripe integration
    self.stripe_guid = 'plan_PLACEHOLDER-123'
  end

  def update_on_stripe_platform
    # todo stripe integration
    self.stripe_guid = self.stripe_guid.split('-')[0] + '-' + ((self.stripe_guid.split('-')[1].to_i + 1).to_s)
  end

end
