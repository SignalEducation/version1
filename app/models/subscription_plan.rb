# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  available_to_students         :boolean          default(FALSE), not null
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
#  paypal_guid                   :string
#

class SubscriptionPlan < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include LearnSignalModelExtras

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
  validates :currency_id, presence: true
  validates :price, presence: true
  validates :available_from, presence: true
  validates :available_to, presence: true
  validate  :available_to_in_the_future
  validates :trial_period_in_days, presence: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0,
                           less_than: 32}
  validates_length_of :stripe_guid, maximum: 255, allow_blank: true

  # callbacks
  after_create :create_remote_plans
  after_update :update_remote_plans, if: :name_updated?
  after_destroy :delete_remote_plans

  # scopes
  scope :all_in_order, -> { order(:currency_id, :available_from, :price) }
  scope :all_in_display_order, -> { order(:created_at) }
  scope :all_in_update_order, -> { order(:updated_at) }
  scope :all_active, -> { where('available_from <= :date AND available_to >= :date', date: Proc.new{Time.now.gmtime.to_date}.call) }
  scope :for_students, -> { where(available_to_students: true) }
  scope :for_non_standard_students, -> { where(available_to_students: false) }
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

  def description
    case payment_frequency_in_months
    when 1
      I18n.t('models.subscription_plans.monthly_description')
    when 3
      I18n.t('models.subscription_plans.quarterly_description')
    when 12
      I18n.t('models.subscription_plans.yearly_description')
    else
      'A subscription for the LearnSignal online training service.'
    end
  end

  def destroyable?
    self.subscriptions.empty?
  end

  def amount
    self.currency.format_number(self.price)
  end

  protected

  def available_to_in_the_future
    # On creating subscription plan available_to must be in the future. Later we can
    # make subscription plan inactive only by setting this value to some date in the
    # past so we must allow setting such dates.
    if self.id.nil? && self.available_to && self.available_to.to_date <= Time.now.gmtime.to_date
      errors.add(:available_to, I18n.t('models.subscription_plans.must_be_in_the_future'))
    end
  end

  def create_remote_plans
    SubscriptionPlanWorker.perform_async(id, :create)
  end

  def delete_remote_plans
    SubscriptionPlanWorker.perform_async(id, :delete)
  end

  def update_remote_plans
    SubscriptionPlanWorker.perform_async(id, :update)
  end
end
