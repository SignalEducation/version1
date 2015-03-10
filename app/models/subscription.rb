# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  corporate_customer_id :integer
#  subscription_plan_id  :integer
#  stripe_guid           :string(255)
#  next_renewal_date     :date
#  complementary         :boolean          default(FALSE), not null
#  current_status        :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  stripe_customer_id    :string(255)
#  stripe_customer_data  :text
#  livemode              :boolean          default(FALSE)
#

class Subscription < ActiveRecord::Base

  include LearnSignalModelExtras
  serialize :stripe_customer_data, Hash

  # attr-accessible
  attr_accessible :user_id, :corporate_customer_id, :subscription_plan_id,
                  :complementary, :current_status, :stripe_customer_id,
                  :stripe_token, :livemode

  # Constants
  STATUSES = %w(trialing active past_due canceled canceled-pending unpaid suspended paused previous)

  # relationships
  belongs_to :user
  belongs_to :corporate_customer
  has_many :invoices
  has_many :invoice_line_items
  belongs_to :subscription_plan
  has_many :subscription_transactions

  # validation
  validates :user_id, presence: true, on: :update
  validates :user_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_plan_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :next_renewal_date, presence: true
  validates :current_status, inclusion: {in: STATUSES}
  validates :livemode, inclusion: {in: Invoice::STRIPE_LIVE_MODE}

  # callbacks
  before_validation :create_on_stripe_platform, on: :create
  before_validation :update_on_stripe_platform, on: :update
  after_create :create_a_subscription_transaction

  # scopes
  scope :all_in_order, -> { order(:user_id, :id) }
  scope :all_of_status, lambda { |the_status| where(current_status: the_status) }

  # class methods
  def self.create_using_stripe_subscription(stripe_subscription_hash, stripe_customer_hash)
    user = User.find_by_stripe_customer_id(stripe_customer_hash[:id])
    plan = SubscriptionPlan.find_by_stripe_guid(stripe_subscription_hash[:plan][:id])
    x = Subscription.new(
          user_id: user.id,
          corporate_customer_id: user.corporate_customer_id,
          subscription_plan_id: plan.id,
          complementary: false,
          livemode: (stripe_subscription_hash[:livemode] == 'live'),
          current_status: stripe_subscription_hash[:status],
    )
    x.stripe_guid = stripe_subscription_hash[:id]
    x.next_renewal_date = Time.at(stripe_subscription_hash[:current_period_end].to_i)
    x.stripe_customer_id = user.stripe_customer_id
    x.stripe_customer_data = stripe_customer_hash
    unless x.save!(validate: false)
      Rails.logger.error "Subscription#create_using_stripe_subscription failed to create a subscription. stripe_subscription_hash: #{stripe_subscription_hash.inspect}. Error: #{x.errors.inspect}."
    end
  end

  def self.get_updates_for_user(stripe_customer_guid)
    stripe_customer = Stripe::Customer.retrieve(stripe_customer_guid).to_hash
    active_stripe_subscriptions = stripe_customer[:subscriptions][:data]
    # limited to 10 ACTIVE subscriptions on their platform
    active_stripe_subscriptions.each do |stripe_sub|
      # search for our copy of stripe_sub
      our_sub = Subscription.find_by_stripe_guid(stripe_sub[:id])
      if our_sub
        our_sub.compare_to_stripe_details(stripe_sub, stripe_customer)
      else
        Subscription.create_using_stripe_subscription(stripe_sub, stripe_customer)
      end
    end

  rescue => e
    Rails.logger.error "ERROR: Subscription#get_updates_for_user error: #{e.message}."
  end

  # instance methods
  def cancel
    # call stripe and cancel the subscription
    stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
    # update self to say that it's terminating
    if self.current_status == 'trialing'
      response = stripe_subscription.delete(at_period_end: false).to_hash
      if response[:status] == 'canceled'
        self.update_attribute(:current_status, 'canceled')
        self.update_attribute(:next_renewal_date, Proc.new{Time.now}.call)
      else
        Rails.logger.error "ERROR: Subscription#cancel failed to cancel a 'trialing' sub. Self:#{self}. StripeResponse:#{response}."
        errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
      end
    else
      response = stripe_subscription.delete(at_period_end: true).to_hash
      if response[:status] == 'active' && response[:cancel_at_period_end] == true
        self.update_attribute(:current_status, 'canceled-pending')
        SubscriptionDeferredCancellerWorker.perform_at((self.next_renewal_date.to_time.utc + 12.hours), self.id) unless Rails.env.test?
        Rails.logger.info "INFO: Subscription#cancel has scheduled a deferred cancellation status update for subscription ##{self.id} to be executed at midday GMT on #{self.next_renewal_date.to_s}."
      else
        Rails.logger.error "ERROR: Subscription#cancel failed to cancel an 'active' sub. Self:#{self}. StripeResponse:#{response}."
        errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
      end
    end
    # return true or false - if everything went well
    errors.messages.count == 0
  end

  def compare_to_stripe_details(stripe_subscription_hash, stripe_customer_hash)
    if self.subscription_plan.stripe_guid != stripe_subscription_hash[:id]
      Subscription.create_using_stripe_subscription(stripe_subscription_hash, stripe_customer_hash)
      self.update_attribute(:current_status, 'previous')
    else
      self.next_renewal_date = Time.at(stripe_subscription_hash[:current_period_end])
      self.current_status = stripe_subscription_hash[:status]
      if self.changed?
        self.stripe_customer_data = stripe_subscription_hash
        self.save(validate: false)
      end
    end
  end

  def destroyable?
    self.invoices.empty? && self.invoice_line_items.empty? && self.subscription_transactions.empty?
  end

  def stripe_token=(t) # setter method
    @stripe_token = t
  end

  def stripe_token # getter method
    @stripe_token
  end

  def reactivation_options
    SubscriptionPlan.where(currency_id: self.subscription_plan.currency_id, available_to_students: self.subscription_plan.available_to_students, available_to_corporates: self.subscription_plan.available_to_corporates).generally_available.all_active.all_in_order
  end

  def un_cancel
    stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    latest_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
    latest_subscription.plan = self.subscription_plan.stripe_guid
    response = latest_subscription.save
    if response[:cancel_at_period_end] == false && response[:canceled_at] == nil
      self.update_attribute(:current_status, 'active')
    else
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    end
    self
  end

  def upgrade_options
    SubscriptionPlan.where(currency_id: self.subscription_plan.currency_id, available_to_students: self.subscription_plan.available_to_students, available_to_corporates: self.subscription_plan.available_to_corporates).generally_available.all_active.where('payment_frequency_in_months >= ?', self.subscription_plan.payment_frequency_in_months).all_in_order
  end

  def upgrade_plan(new_plan_id)
    new_subscription_plan = SubscriptionPlan.find_by_id(new_plan_id)
    # compare the currencies of the old and new plans,
    unless self.subscription_plan.currency_id == new_subscription_plan.currency_id
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.currencies_mismatch'))
      return self
    end
    # make sure new plan is active
    unless new_subscription_plan.active?
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.new_plan_is_inactive'))
      return self
    end
    # make sure the current subscription is in "good standing"
    unless %w(trialing active).include?(self.current_status)
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.this_subscription_cant_be_upgraded'))
      return self
    end
    # only individual students are allowed to upgrade their plan
    unless self.user.individual_student? || self.user.corporate_customer?
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade'))
      return self
    end
    # Make sure they have a default credit card in place
    unless self.user.subscription_payment_cards.all_default_cards.length > 0
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_have_no_default_payment_card'))
      return self
    end

    # reduce the trial period in the new plan to the remaining trial period in the
    # current one, or zero if the current plan is already "active"
    remaining_trial_days = self.current_status == 'trialing' ?
          [self.next_renewal_date - Proc.new{Time.now}.call.to_date, 0].max.to_i :
          0

    #### if we're here, then we're good to go.
    stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
    stripe_subscription.plan = new_subscription_plan.stripe_guid
    stripe_subscription.prorate = true
    if self.current_status == 'trialing'
      stripe_subscription.trial_end = (Proc.new{Time.now}.call + remaining_trial_days.days).to_i
    else
      stripe_subscription.trial_end = 'now'
    end
    sample_response_from_stripe = {
          id: 'test_su_4', status: 'trialing',
          current_period_start: 1424881810, current_period_end: 1425486610,
          plan: {id:'test-fiiIjQX9TUf9nacPIrGu', interval:'month',
                name:'LearnSignal Test 2',amount:999, currency:'eur',
                object: 'plan', livemode:false, interval_count:1,
                trial_period_days:7, statement_description:'LearnSignal'},
          cancel_at_period_end: false, canceled_at: nil, ended_at: nil,
          start: 1308595038, object: 'subscription', trial_start: 1424881810,
          trial_end: 1425486610, customer: 'test_cus_3', quantity: 1, tax_percent: nil,
          metadata: {}
    }

    result = stripe_subscription.save # saves it at stripe.com, not in our DB

    #### if we are here, the subscription change on Stripe has gone well
    #### Now we need to create a new Subscription in our DB.
    ActiveRecord::Base.transaction do
      new_sub = Subscription.new(
              user_id: self.user_id,
              corporate_customer_id: self.corporate_customer_id,
              subscription_plan_id: new_subscription_plan.id,
              complementary: false,
              livemode: (result[:livemode] == 'live'),
              current_status: result[:status],
      )
      # mass-assign-protected attributes
      new_sub.stripe_guid = result[:id]
      new_sub.next_renewal_date = Time.at(result[:current_period_end])
      new_sub.stripe_customer_id = self.stripe_customer_id
      new_sub.stripe_customer_data = Stripe::Customer.retrieve(self.stripe_customer_id).to_hash
      new_sub.save(validate: false) # see "sample_response_from_stripe" above

      self.update_attribute(:current_status, 'previous')
      self.update_attribute(:next_renewal_date, Proc.new{Time.now}.call)

      return new_sub
    end
  rescue ActiveRecord::RecordInvalid => exception
    Rails.logger.error("ERROR: Subscription#upgrade_plan - AR.Transaction failed.  Details: #{exception.inspect}")
    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    false
  rescue => e
    Rails.logger.error("ERROR: Subscription#upgrade_plan - failed to update Subscription at Stripe.  Details: #{e.inspect}")
    errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    false
  end

  protected

  def create_on_stripe_platform
    Rails.logger.debug 'DEBUG: Subscription#create_on_stripe_platform initialised'
    self.complementary = false
    if self.stripe_customer_id.blank?
      #### New customer
      if @stripe_token
        stripe_customer = Stripe::Customer.create(
                card: @stripe_token,
                plan: self.subscription_plan.try(:stripe_guid),
                email: self.user.try(:email)
        )
        stripe_subscription = stripe_customer.try(:subscriptions).try(:data).try(:first)
      else
        errors.add(:stripe_token, I18n.t('models.subscriptions.create.cant_be_blank'))
        return
      end
    else
      #### Existing customer that is reactivating
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.create(plan: self.subscription_plan.stripe_guid, trial_end: 'now')
      # refresh...
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    end

    if stripe_customer && stripe_subscription
      self.stripe_guid = stripe_subscription.id
      self.next_renewal_date = Time.at(stripe_subscription.current_period_end)
      self.livemode = (stripe_subscription[:livemode] == 'live')
      self.current_status = stripe_subscription.status
      self.stripe_customer_id ||= stripe_customer.id
      self.stripe_customer_data = stripe_customer.to_hash.deep_dup
    end

    if Invoice::STRIPE_LIVE_MODE.first != stripe_customer[:livemode]
      errors.add(:base, I18n.t('models.general.live_mode_error'))
      Rails.logger.fatal 'FATAL: Subscription#create_on_stripe_platform - live-mode mismatch with Stripe.com. StripeCustomer: ' + stripe_customer.inspect + '. Self: ' + self.inspect
      false
    else
      true
    end
  rescue => e
    errors.add(:credit_card, e.message)
    return false
  end

  def create_a_subscription_transaction
    SubscriptionTransaction.create_from_stripe_data(self)
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

  def update_on_stripe_platform
    # Not needed: this is handled by self.upgrade_plan(new_plan_id)
  end

end
