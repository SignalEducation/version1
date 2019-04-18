# == Schema Information
#
# Table name: subscriptions
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  subscription_plan_id     :integer
#  stripe_guid              :string
#  next_renewal_date        :date
#  complimentary            :boolean          default(FALSE), not null
#  stripe_status            :string
#  created_at               :datetime
#  updated_at               :datetime
#  stripe_customer_id       :string
#  stripe_customer_data     :text
#  livemode                 :boolean          default(FALSE)
#  active                   :boolean          default(FALSE)
#  terms_and_conditions     :boolean          default(FALSE)
#  coupon_id                :integer
#  paypal_subscription_guid :string
#  paypal_token             :string
#  paypal_status            :string
#  state                    :string
#  cancelled_at             :datetime
#  cancellation_reason      :string
#  cancellation_note        :text
#

class Subscription < ActiveRecord::Base
  include LearnSignalModelExtras
  serialize :stripe_customer_data, Hash
  attr_accessor :use_paypal, :paypal_approval_url, :cancelling_subscription

  delegate :currency, to: :subscription_plan

  # Constants
  STATUSES = %w(active past_due canceled canceled-pending)
  PAYPAL_STATUSES = %w(Pending Active Suspended Cancelled Expired)
  VALID_STATES = %w(active past_due canceled-pending)

  # relationships
  belongs_to :user, inverse_of: :subscriptions
  belongs_to :subscription_plan
  belongs_to :coupon, optional: true
  has_one :student_access

  has_many :invoices
  has_many :invoice_line_items
  has_many :subscription_transactions
  has_many :charges
  has_many :refunds

  delegate :exam_body, to: :subscription_plan, allow_nil: false

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :subscription_plan_id, presence: true
  # validates :next_renewal_date, presence: true
  validates :stripe_status, inclusion: { in: STATUSES }, allow_blank: true
  validates :paypal_status, inclusion: { in: PAYPAL_STATUSES }, allow_blank: true
  validates :cancellation_reason, presence: true, if: Proc.new { |sub| sub.cancelling_subscription }

  # validates :livemode, inclusion: { in: [Invoice::STRIPE_LIVE_MODE] }, on: :update
  validates_length_of :stripe_guid, maximum: 255, allow_blank: true
  validates_length_of :stripe_customer_id, maximum: 255, allow_blank: true

  # callbacks
  after_create :create_subscription_payment_card, if: :stripe_token # If new card details
  after_create :update_coupon_count

  # scopes
  scope :all_in_order, -> { order(:user_id, :id) }
  scope :in_created_order, -> { order(:created_at) }
  scope :in_reverse_created_order, -> { order(:created_at).reverse_order }
  scope :all_of_status, lambda { |the_status| where(stripe_status: the_status) }
  scope :all_active, -> { with_states(:active, :paused, :errored, :pending_cancellation) }
  scope :all_valid, -> { where(state: VALID_STATES) }
  scope :not_pending, -> { where.not(state: 'pending') }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }

  # STATE MACHINE ==============================================================

  state_machine initial: :pending do
    event :start do
      transition pending: :active
    end

    event :pause do
      transition active: :paused
    end

    event :record_error do
      transition [:active, :pending] => :errored
    end

    event :cancel_pending do
      transition active: :pending_cancellation
    end

    event :cancel do
      transition [:pending, :active, :errored, :pending_cancellation, :paused] => :cancelled
    end

    event :restart do
      transition [:errored, :pending_cancellation, :paused] => :active
    end

    state all - [:active, :errored, :pending_cancellation] do
      def valid_subscription?
        false
      end
    end

    state :active, :errored, :pending_cancellation do
      def valid_subscription?
        true
      end
    end

    state all - [:active, :paused, :pending_cancellation, :errored] do
      def can_change_plan?
        false
      end
    end

    state :active, :paused, :pending_cancellation, :errored do
      def can_change_plan?
        true
      end
    end

    after_transition pending: :active do |subscription, _transition|
      # ??
    end

    after_transition all => :errored do |subscription, _transition|
      # Email somebody and tell them that they have an errored subscription
      # Update card details
      # Retry ? Stripe auto retries after 3, 5 and 7 days
      # UserMailer.payment_failed_email(subscription.user).deliver
    end

    after_transition errored: :cancelled do |subscription, _transition|
      # De-activate the user's account and email them to tell them that their 
      # account has been temporarily cancelled with insturctions on how to unlock
      # along with the number of remaining payments due
      # Update card details (how-to)
      # UserMailer.subscription_delete_email(subscription.user).deliver
      # UserMailer.subscription_auto_delete_email(subscription.user).deliver
    end

    after_transition active: :paused do |subscription, _transition|
      # Notify the user that their sub is paused
    end

    after_transition active: :pending_cancellation do |subscription, _transition|
      # Email the user to tell them how many days of access they have left on
      # the platform. For Stripe they can 'un-cancel' but for PayPal they will
      # need to setup a new subscription
    end

    after_transition [:active, :paused] => :pending_cancellation do |subscription, _transition|
      subscription.update(cancelled_at: Time.zone.now)
    end

    after_transition pending_cancellation: :cancelled do |subscription, _transition|
      # The user has reached the max_failed_payments limit or has been manually
      # cancelled and reached the end of the last billing period.
    end
  end

  # CLASS METHODS ==============================================================

  # INSTANCE METHODS ===========================================================

  def cancel_by_user
    if self.stripe_customer_id && self.stripe_guid
      # call stripe and cancel the subscription
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
      response = stripe_subscription.delete(at_period_end: true).to_hash
      if response[:status] == 'active' && response[:cancel_at_period_end] == true
        self.update_attribute(:stripe_status, 'canceled-pending')
        self.cancel_pending
      elsif response[:status] == 'past_due'
        self.update_attribute(:stripe_status, 'canceled-pending')
        self.cancel_pending
        Rails.logger.error "ERROR: Subscription#cancel with a past_due status updated local sub from past_due to canceled-pending StripeResponse:#{response}."
      else
        Rails.logger.error "ERROR: Subscription#cancel failed to cancel an 'active' sub. Self:#{self}. StripeResponse:#{response}."
        errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
      end
      # return true or false - if everything went well
      errors.messages.count == 0
    elsif paypal_subscription_guid.present?
      SubscriptionService.new(self).cancel_subscription
    else
      Rails.logger.error "ERROR: Subscription#cancel failed because it didn't have a stripe_customer_id OR a stripe_guid. Subscription:#{self}."
      false
    end
  end

  def immediate_cancel
    if self.stripe_customer_id && self.stripe_guid
      # call stripe and cancel the subscription
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
      response = stripe_subscription.delete(at_period_end: false).to_hash
      if response[:status] == 'canceled'
        self.update_attribute(:stripe_status, 'canceled')
        self.cancel
      else
        Rails.logger.error "ERROR: Subscription#cancel failed to cancel an 'active' sub. Self:#{self}. StripeResponse:#{response}."
        errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
      end
      # return true or false - if everything went well
      errors.messages.count == 0
    else
      Rails.logger.error "ERROR: Subscription#cancel failed because it didn't have a stripe_customer_id OR a stripe_guid. Subscription:#{self}."
    end
  end

  def reactivate_canceled
    # make sure sub plan is active
    unless self.subscription_plan.active?
      errors.add(:base, I18n.t('models.subscriptions.reactivate_canceled.plan_is_inactive'))
    end
    # ensure user is student user
    unless self.user.trial_or_sub_user?
      errors.add(:base, I18n.t('models.subscriptions.reactivate_canceled.not_student_user'))
    end
    # Make sure there is a default credit card in place
    unless self.user.subscription_payment_cards.all_default_cards.length > 0
      errors.add(:base, I18n.t('models.subscriptions.reactivate_canceled.no_default_payment_card'))
    end
    # Ensure this sub is canceled
    unless self.stripe_status == 'canceled'
      errors.add(:base, I18n.t('models.subscriptions.reactivate_canceled.sub_is_not_canceled'))
    end

    stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    # Ensure no active sub object on stripe
    if stripe_customer.subscriptions.data.any?
      errors.add(:base, I18n.t('models.subscriptions.reactivate_canceled.existing_sub_on_stripe'))
    end

    if errors.messages.count == 0
      stripe_subscription = Stripe::Subscription.create(
          customer: self.user.stripe_customer_id,
          plan: self.subscription_plan.stripe_guid,
          trial_end: 'now'
      )
      stripe_customer = Stripe::Customer.retrieve(user.stripe_customer_id) #Reload the stripe_customer to get new Subscription details

      if stripe_subscription && stripe_customer && stripe_subscription.status == 'active'

        self.update_attributes(
            stripe_status: stripe_subscription.status,
            stripe_guid: stripe_subscription.id,
            next_renewal_date: Time.at(stripe_subscription.current_period_end),
            stripe_customer_data: stripe_customer.to_hash.deep_dup,
            active: true
        )
        self.start
      end

    end

    # return true or false - if everything went well
    errors.messages.count == 0

  end

  def destroyable?
    self.invoices.empty? &&
      self.invoice_line_items.empty? &&
      self.subscription_transactions.empty? &&
      self.referred_signup.nil?
      #self.livemode == Invoice::STRIPE_LIVE_MODE &&
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

  def reactivation_options
    SubscriptionPlan
      .where(
        currency_id: self.subscription_plan.currency_id
      )
      .where('price > 0.0').generally_available.all_active.all_in_order
  end

  def schedule_paypal_cancellation
    self.cancel_pending if self.active?
    PaypalSubscriptionsService.new(self).set_cancellation_date
  end

  def upgrade_options
    SubscriptionPlan.includes(:currency).where.not(id: subscription_plan.id).in_currency(subscription_plan.currency_id).all_active.all_in_order
  end

  def update_from_stripe
    if self.stripe_guid && self.stripe_customer_id
      begin
        stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)

        if stripe_customer
          begin
            stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)

            subscription = Subscription.where(stripe_guid: stripe_subscription.id, active: true).first
            subscription.next_renewal_date = Time.at(stripe_subscription.current_period_end)
            subscription.stripe_status = stripe_subscription.status
            subscription.stripe_customer_data = stripe_customer.to_hash.deep_dup
            subscription.livemode = stripe_subscription[:plan][:livemode]
            subscription.save(validate: false)

          rescue Stripe::InvalidRequestError => e
            subscription.update_attribute(:stripe_status, 'canceled')
          end

        end
      rescue Stripe::InvalidRequestError => e

      end
    end
  end

  def un_cancel
    stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    latest_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
    latest_subscription.plan = self.subscription_plan.stripe_guid
    response = latest_subscription.save
    if response[:cancel_at_period_end] == false && response[:canceled_at] == nil
      self.update_attributes(stripe_status: 'active', active: true, terms_and_conditions: true)
      self.restart
    else
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    end
    self
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
      when 'cancelled'
        'Canceled Subscription'
      else
        'Invalid Subscription'
    end
  end

  def user_readable_name
    subscription_plan.exam_body.name + ' ' + subscription_plan.interval_name + ' Subscription'
  end

  def stripe?
    stripe_guid.present?
  end

  protected

  def create_subscription_payment_card
    stripe_customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    array_of_cards = stripe_customer.sources.data
    SubscriptionPaymentCard.create_from_stripe_array(array_of_cards, self.user_id, stripe_customer.default_source)
  end

  def update_coupon_count
    if self.coupon_id
      self.coupon.update_redeems
    end
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

end
