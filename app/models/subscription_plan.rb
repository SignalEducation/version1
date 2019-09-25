# == Schema Information
#
# Table name: subscription_plans
#
#  id                            :integer          not null, primary key
#  payment_frequency_in_months   :integer          default(1)
#  currency_id                   :integer
#  price                         :decimal(, )
#  available_from                :date
#  available_to                  :date
#  stripe_guid                   :string
#  created_at                    :datetime
#  updated_at                    :datetime
#  name                          :string
#  subscription_plan_category_id :integer
#  livemode                      :boolean          default(FALSE)
#  paypal_guid                   :string
#  paypal_state                  :string
#  monthly_percentage_off        :integer
#  previous_plan_price           :float
#  exam_body_id                  :bigint(8)
#  guid                          :string
#  bullet_points_list            :string
#  sub_heading_text              :string
#  most_popular                  :boolean          default(FALSE), not null
#  registration_form_heading     :string
#  login_form_heading            :string
#

class SubscriptionPlan < ApplicationRecord
  include ActionView::Helpers::TextHelper
  include LearnSignalModelExtras
  include Filterable

  # Constants
  PAYMENT_FREQUENCIES = [1,3,6,12]
  PAYPAL_STATES = %w(CREATED ACTIVE INACTIVE)

  # relationships
  belongs_to :exam_body
  belongs_to :currency
  has_many :invoice_line_items
  has_many :subscriptions
  belongs_to :subscription_plan_category, optional: true

  # validation
  validates :name, presence: true, length: { maximum: 255 }
  validates :guid, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :payment_frequency_in_months, inclusion: { in: PAYMENT_FREQUENCIES }
  validates :paypal_state, inclusion: { in: PAYPAL_STATES }, allow_nil: true
  validates :currency, presence: true
  validates :price, presence: true
  validates :available_from, presence: true
  validates :available_to, presence: true
  validate  :available_to_in_the_future
  validates_length_of :stripe_guid, maximum: 255, allow_blank: true

  # callbacks
  before_validation :generate_guid, on: :create
  after_create :create_remote_plans
  after_update :update_remote_plans, if: :name_changed?
  after_destroy :delete_remote_plans

  # scopes
  scope :all_in_order, -> { order(:currency_id, :available_from, :price) }
  scope :all_in_display_order, -> { order(:created_at) }
  scope :all_in_update_order, -> { order(:updated_at) }
  scope :all_active, -> { where('available_from <= :date AND available_to >= :date', date: Proc.new{ Time.now.gmtime.to_date }.call) }
  scope :generally_available, -> { where(subscription_plan_category_id: nil) }
  scope :in_currency, lambda { |ccy_id| where(currency_id: ccy_id) }
  scope :for_exam_body, lambda { |body_id| where(exam_body_id: body_id) }
  scope :yearly, -> { where(payment_frequency_in_months: 12) }

  search_scope :prioritise_plan_frequency, ->(frequency) { where(payment_frequency_in_months: frequency) }
  search_scope :plan_guid,                 ->(guid)      { where(guid: guid) }
  search_scope :subscription_plan_id,      ->(id)        { where(id: id) }

  # class methods
  def self.get_relevant(user, currency, exam_body_id)
    plans = in_currency(currency.id).
              generally_available.
              all_active.
              all_in_order

    if exam_body_id && (body = ExamBody.find(exam_body_id))
      plans.where(exam_body_id: body.id)
    elsif body = user.preferred_exam_body
      plans.where(exam_body_id: body.id)
    else
      plans
    end
  end

  def self.get_individual_related_plan(plan_guid, currency)
    plan = SubscriptionPlan.find_by(guid: plan_guid)
    return plan unless (plan && plan.currency_id != currency.id) || (plan && !plan.active?)

    raise Learnsignal::SubscriptionError, 'The specified plan is not available! Please choose another.'
  end

  def self.get_related_plans(user, currency, exam_body_id, plan_guid)
    plan = get_individual_related_plan(plan_guid, currency)
    plans = if plan&.subscription_plan_category_id
              plan.subscription_plan_category.subscription_plans.in_currency(
                currency.id
              ).all_active.all_in_order
            else
              in_currency(currency.id).generally_available.all_active.
                all_in_order
            end

    scope_exam_body_plans(user, exam_body_id, plans)
  end

  def self.scope_exam_body_plans(user, exam_body_id, plans)
    if body = ExamBody.find_by(id: exam_body_id)
      plans.where(exam_body_id: body.id)
    elsif body_id = user.preferred_exam_body_id
      plans.where(exam_body_id: body_id)
    else
      plans
    end
  end

  def self.by_exam_body(exam_body_id)
    exam_body_id ? where(exam_body_id: exam_body_id) : all
  end

  def self.search(search)
    if search
      where('name ILIKE ? OR stripe_guid ILIKE ? OR paypal_guid ILIKE ? OR guid ILIKE ?',
            "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end

  # instance methods
  def active?
    self.available_from <= Proc.new{ Time.zone.now.to_date }.call && self.available_to >= Proc.new{ Time.zone.now.to_date }.call
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

  def interval_name
    case payment_frequency_in_months
    when 1
      'Monthly'
    when 3
      'Quarterly'
    when 12
      'Yearly'
    else
      'Monthly'
    end
  end

  def checkout_sub_heading
    if subscription_plan_category_id && subscription_plan_category.sub_heading_text
      subscription_plan_category.sub_heading_text.to_s
    elsif sub_heading_text && !sub_heading_text.empty?
      sub_heading_text.to_s
    else
      exam_body.subscription_page_subheading_text
    end
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

  def generate_guid
    self.guid = ApplicationController.generate_random_code(10)
  end

  def create_remote_plans
    SubscriptionPlanService.new(self).queue_async(:create)
  end

  def delete_remote_plans
    SubscriptionPlanWorker.perform_async(
      self.id,
      :delete,
      self.stripe_guid,
      self.paypal_guid
    )
  end

  def update_remote_plans
    SubscriptionPlanService.new(self).queue_async(:update)
  end
end
