# == Schema Information
#
# Table name: subscriptions
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  subscription_plan_id     :integer
#  stripe_guid              :string(255)
#  next_renewal_date        :date
#  complimentary            :boolean          default("false"), not null
#  stripe_status            :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  stripe_customer_id       :string(255)
#  livemode                 :boolean          default("false")
#  active                   :boolean          default("false")
#  terms_and_conditions     :boolean          default("false")
#  coupon_id                :integer
#  paypal_subscription_guid :string
#  paypal_token             :string
#  paypal_status            :string
#  state                    :string
#  cancelled_at             :datetime
#  cancellation_reason      :string
#  cancellation_note        :text
#  changed_from_id          :bigint
#  completion_guid          :string
#  ahoy_visit_id            :uuid
#  cancelled_by_id          :bigint
#  kind                     :integer
#  paypal_retry_count       :integer          default("0")
#  total_revenue            :decimal(, )      default("0")
#

class Subscription < ApplicationRecord
  include LearnSignalModelExtras

  attr_accessor :use_paypal, :paypal_approval_url, :cancelling_subscription,
                :payment_intent_status, :client_secret

  delegate :currency, to: :subscription_plan

  # constants
  STATUSES        = %w[incomplete active past_due canceled canceled-pending pending_cancellation incomplete_expired].freeze
  VALID_STATES    = %w[active past_due canceled-pending pending_cancellation paused].freeze
  PAYPAL_STATUSES = %w[Pending Active Suspended Cancelled Expired].freeze

  # enums
  enum kind: { new_subscription: 0, reactivation: 1, change_plan: 2 }

  # relationships
  belongs_to :user, inverse_of: :subscriptions
  belongs_to :subscription_plan
  belongs_to :coupon, optional: true
  belongs_to :changed_from, class_name: 'Subscription', foreign_key: :changed_from_id, optional: true
  belongs_to :cancelled_by, class_name: 'User', inverse_of: :subscriptions_cancelled, optional: true
  visitable :ahoy_visit

  has_one :changed_to, class_name: 'Subscription', foreign_key: 'changed_from_id', inverse_of: :changed_from
  has_one :exam_body, through: :subscription_plan

  has_many :invoices
  has_many :invoice_line_items
  has_many :charges
  has_many :refunds
  has_many :messages

  # validation
  validates :user_id, presence: true,
                      numericality: { only_integer: true, greater_than: 0 }, on: :update
  validates :subscription_plan_id, presence: true
  validates :stripe_status, inclusion: { in: STATUSES }, allow_blank: true
  validates :paypal_status, inclusion: { in: PAYPAL_STATUSES }, allow_blank: true
  validates :stripe_guid, :stripe_customer_id, length: { maximum: 255 }, allow_blank: true
  validate :plan_change_currencies, :plan_change_active,
           :subscription_change_allowable,
           :user_is_student, if: proc { |sub| sub.changed_from.present? }, on: :create
  #validates :kind, presence: true, on: :create

  # callbacks
  after_initialize :set_completion_guid
  after_create :create_subscription_payment_card, if: :stripe_token # If new card details
  after_create :update_subscription_status, if: :stripe_token
  after_create :update_coupon_count
  after_save :update_hub_spot_data, :update_segment_user

  # scopes
  scope :all_in_order,             -> { order(:user_id, :id) }
  scope :in_created_order,         -> { order(:created_at) }
  scope :in_reverse_created_order, -> { order(created_at: :desc) }
  scope :all_of_status,            ->(status) { where(stripe_status: status) }
  scope :all_active,               -> { with_states(:active, :past_due, :paused, :errored, :pending_cancellation) }
  scope :all_valid,                -> { where(state: VALID_STATES) }
  scope :cancelled,                -> { where(state: 'cancelled') }
  scope :not_pending,              -> { where.not(state: 'pending') }
  scope :this_week,                -> { where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week) }
  scope :all_stripe,               -> { where.not(stripe_guid: nil).where(paypal_token: nil) }
  scope :all_paypal,               -> { where.not(paypal_token: nil).where(stripe_guid: nil) }
  scope :for_exam_body,            ->(body_id) { joins(:subscription_plan).where(subscription_plans: { exam_body_id: body_id }) }

  # STATE MACHINE ==============================================================

  state_machine initial: :pending do
    event :start do
      transition %i[pending pending_3d_secure] => :active
    end

    event :mark_pending do
      transition all => :pending
    end

    event :pause do
      transition %i[active past_due] => :paused
    end

    event :record_error do
      transition %i[active pending] => :errored
    end

    event :cancel_pending do
      transition active: :pending_cancellation
    end

    event :mark_past_due do
      transition active: :past_due
    end

    event :cancel do
      transition %i[pending active errored pending_cancellation
                    paused past_due pending_3d_secure] => :cancelled
    end

    event :restart do
      transition %i[errored pending_cancellation paused past_due
                    pending_3d_secure cancelled] => :active
    end

    event :mark_payment_action_required do
      # This event can also be triggered when non-3D-secure plan_changes fails to charge the first payment
      # So subscriptions that are not SCA required can be in pending_3d_secure state as action is required
      # in order to charge an outstanding invoice (A new card)
      transition all => :pending_3d_secure
    end

    state all - %i[active errored pending_cancellation] do
      def valid_subscription?
        false
      end
    end

    state :active, :errored, :pending_cancellation do
      def valid_subscription?
        true
      end
    end

    state all - %i[active paused pending_cancellation errored] do
      def can_change_plan?
        false
      end
    end

    state :active, :paused, :pending_cancellation, :errored do
      def can_change_plan?
        upgrade_options.length.positive?
      end
    end

    after_transition %i[active paused] => :pending_cancellation do |subscription, _transition|
      subscription.schedule_paypal_cancellation if subscription.paypal?
      subscription.update(cancelled_at: Time.zone.now)
    end

    after_transition all => :cancelled do |subscription, _transition|
      subscription.update(cancelled_at: Time.zone.now)
    end

    after_transition %i[pending pending_3d_secure] => :active do |subscription, _transition|
      SegmentService.new.track_subscription_payment_complete_event(subscription)
    end
  end

  # CLASS METHODS ==============================================================

  # INSTANCE METHODS ===========================================================

  def take_appropriate_action(status)
    case status
    when 'active'
      start
    when 'past_due'
      mark_payment_action_required
    end
  end

  def cancel_by_user
    if stripe_customer_id && stripe_guid
      # call stripe and cancel the subscription
      stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(stripe_guid)
      stripe_subscription.cancel_at_period_end = true
      response = stripe_subscription.save.to_hash
      if response[:status] == 'active' && response[:cancel_at_period_end] == true
        update_attribute(:stripe_status, 'canceled-pending')
        cancel_pending
      elsif response[:status] == 'past_due'
        update_attribute(:stripe_status, 'canceled-pending')
        cancel_pending
        Rails.logger.error "ERROR: Subscription#cancel with a past_due status updated local sub from past_due to canceled-pending StripeResponse:#{response}."
      else
        Rails.logger.error "ERROR: Subscription#cancel failed to cancel an 'active' sub. Self:#{self}. StripeResponse:#{response}."
        errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
      end

      # return true or false - if everything went well
      errors.messages.count.zero?
    elsif paypal_subscription_guid.present?
      SubscriptionService.new(self).cancel_subscription
    else
      Rails.logger.error "ERROR: Subscription#cancel failed because it didn't have a stripe_customer_id OR a stripe_guid. Subscription:#{self}."
      false
    end
  rescue Stripe::InvalidRequestError
    raise Learnsignal::SubscriptionError, I18n.t('controllers.subscriptions.destroy.flash.error')
  end

  def immediate_cancel
    if stripe? && stripe_customer_id && stripe_guid
      # call stripe and cancel the subscription
      stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(stripe_guid)
      response = stripe_subscription.delete.to_hash
      if response[:status] == 'canceled'
        update_attribute(:stripe_status, 'canceled')
        cancel
      else
        Rails.logger.error "ERROR: Subscription#cancel failed to cancel an 'active' sub. Self:#{self}. StripeResponse:#{response}."
        errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
      end

      # return true or false - if everything went well
      errors.messages.blank?
    else
      Rails.logger.error "ERROR: Subscription#cancel failed because it didn't have a stripe_customer_id OR a stripe_guid. Subscription:#{self}."
    end
  end

  def reactivate_canceled
    # ensure user is student user
    unless user.standard_student_user?
      errors.add(:base, I18n.t('models.subscriptions.reactivate_canceled.not_student_user'))
    end

    # Make sure there is a default credit card in place
    unless user.subscription_payment_cards.all_default_cards.length.positive?
      errors.add(:base, I18n.t('models.subscriptions.reactivate_canceled.no_default_payment_card'))
    end

    # Ensure this sub is canceled
    unless stripe_status == 'canceled'
      errors.add(:base, I18n.t('models.subscriptions.reactivate_canceled.sub_is_not_canceled'))
    end

    if errors.messages.count.zero?
      stripe_subscription = Stripe::Subscription.create(
        customer: user.stripe_customer_id,
        items: [{ plan: subscription_plan.stripe_guid,
                  quantity: 1 }],
        trial_end: 'now'
      )
      stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id) #Reload the stripe_customer to get new Subscription details

      if stripe_subscription && stripe_customer && stripe_subscription.status == 'active'
        update_attributes(
          stripe_status: stripe_subscription.status,
          stripe_guid: stripe_subscription.id,
          next_renewal_date: Time.zone.at(stripe_subscription.current_period_end),
          cancelled_at: nil,
          cancellation_reason: nil,
          cancellation_note: nil,
          cancelled_by_id: nil
        )
        restart
      end
    end

    # return true or false - if everything went well
    errors.messages.count.zero?
  end

  def destroyable?
    invoices.empty? && invoice_line_items.empty?
  end

  def stripe_guid_present?
    @stripe_guid.present?
  end

  # setter method
  def stripe_token=(t)
    @stripe_token = t
  end

  # getter method
  def stripe_token
    @stripe_token
  end

  def active_status?
    self.stripe_status == 'active'
  end

  def canceled_status?
    self.stripe_status == 'canceled'
  end

  def past_due_status?
    self.stripe_status == 'past_due'
  end

  def unpaid_status?
    self.stripe_status == 'unpaid'
  end

  def canceled_pending_status?
    self.stripe_status == 'canceled-pending'
  end

  def billing_amount
    subscription_plan.try(:amount)
  end

  def paypal_suspended
    PaypalService.new.update_billing_agreement(subscription)
    self.record_error
  end

  def pending_3ds_invoice
    invoices.find_by(requires_3d_secure: true)
  end

  def reactivation_options
    SubscriptionPlan.
      where(
        currency_id: subscription_plan.currency_id
      ).
      where('price > 0.0').generally_available.all_active.all_in_order
  end

  def schedule_paypal_cancellation
    cancel_pending if active?
    PaypalSubscriptionsService.new(self).set_cancellation_date
  end

  def upgrade_options
    SubscriptionPlan.includes(:currency).
      where.not(payment_frequency_in_months: subscription_plan.payment_frequency_in_months).
      where(subscription_plan_category_id: nil).
      for_exam_body(subscription_plan.exam_body_id).
      in_currency(subscription_plan.currency_id).
      all_active.all_in_display_order
  end

  def update_from_stripe
    return unless stripe_guid && stripe_customer_id

    stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
    update_subscription_attributes(stripe_customer) if stripe_customer
  rescue Stripe::InvalidRequestError
    update(stripe_status: 'canceled')
  rescue Stripe::RateLimitError
    sleep(3)
    retry
  end

  def update_subscription_attributes(stripe_customer)
    stripe_subscription = stripe_customer.subscriptions.retrieve(stripe_guid)

    subscription = Subscription.where(stripe_guid: stripe_subscription.id).in_reverse_created_order.last
    subscription.next_renewal_date = Time.zone.at(stripe_subscription.current_period_end)
    subscription.stripe_status = stripe_subscription.status
    subscription.livemode = stripe_subscription[:plan][:livemode]
    subscription.save(validate: false)
  end

  def un_cancel
    stripe_customer = Stripe::Customer.retrieve(stripe_customer_id)
    latest_subscription = stripe_customer.subscriptions.retrieve(stripe_guid)
    latest_subscription.cancel_at_period_end = false
    response = latest_subscription.save
    return false unless !response.cancel_at_period_end && response.canceled_at.nil?

    update(stripe_status: 'active', terms_and_conditions: true, cancelled_at: nil,
           cancellation_reason: nil, cancellation_note: nil, cancelled_by_id: nil)
    restart
  end

  def update_invoice_payment_success
    stripe_sub = StripeSubscriptionService.new(self).retrieve_subscription
    update!(stripe_status: stripe_sub.status,
            next_renewal_date: Time.at(stripe_sub.current_period_end))
    if pending?
      start!
    elsif !active?
      restart!
    end
  end

  def user_readable_status
    case state
      when 'active'
        'Active Subscription'
      when 'errored'
        'Past Due Subscription'
      when 'pending_cancellation'
        'Subscription Pending Cancellation'
      when 'paused'
        'Subscription Paused'
      when 'past_due'
        'Subscription Past Due'
      when 'cancelled'
        'Canceled Subscription'
      else
        'Invalid Subscription'
    end
  end

  def user_readable_name
    subscription_plan.exam_body.name + ' ' + subscription_plan.interval_name + ' Subscription'
  end

  def paypal?
    paypal_subscription_guid.present?
  end

  def stripe?
    stripe_guid.present?
  end

  def subscription_type
    return 'stripe' if stripe?
    return 'paypal' if paypal?
    'unknown'
  end

  def coupon_data
    return unless coupon_id

    { code: coupon.code, price_discounted: coupon.price_discounted(subscription_plan_id) }
  end

  # kind -> increment! || decrement!
  def update_revenue(kind, value)
    send(kind, :total_revenue, value)
    user.send(kind, :subscriptions_revenue, value)
  end

  protected

  def create_subscription_payment_card
    return if stripe_token.blank?

    stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id)
    array_of_cards  = stripe_customer.sources.data

    SubscriptionPaymentCard.create_from_stripe_array(array_of_cards, user_id, stripe_customer.default_source)
  end

  def update_subscription_status
    return if stripe_token.blank?

    if stripe_status == 'active'
      start
    elsif payment_intent_status == 'requires_action'
      mark_payment_action_required
    end
  end

  def update_coupon_count
    coupon.update_redeems if coupon_id
  end

  def prefix
    if Rails.env.production?
      ''
    elsif Rails.env.staging?
      'Staging: '
    elsif Rails.env.test?
      "Test-#{rand(9999)}: "
    else # development and all others
      "Dev-#{rand(9999)}: "
    end
  end

  def update_hub_spot_data
    return if Rails.env.test?

    HubSpotContactWorker.perform_async(user_id)
  end

  def update_segment_user
    return if Rails.env.test?

    SegmentService.new.identify_user(user)
  end

  def subscription_change_allowable
    return unless stripe?
    return if %w[active canceled-pending pending_cancellation].include?(changed_from.stripe_status)

    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.this_subscription_cant_be_upgraded'))
  end

  def user_has_default_card
    return unless stripe? && user.default_card.blank?

    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_have_no_default_payment_card'))
  end

  def user_is_student
    return if user.standard_student_user?

    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade'))
  end

  def plan_change_active
    return if subscription_plan.active?

    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.choose_different_plan'))
  end

  def plan_change_currencies
    return if changed_from.subscription_plan&.currency_id == subscription_plan.currency_id

    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.currencies_mismatch'))
  end

  def set_completion_guid
    return unless new_record? && completion_guid.blank?
    self.completion_guid = ApplicationController.generate_random_code(20)
  end
end
