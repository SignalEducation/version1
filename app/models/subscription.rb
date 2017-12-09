# == Schema Information
#
# Table name: subscriptions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  subscription_plan_id :integer
#  stripe_guid          :string
#  next_renewal_date    :date
#  complimentary        :boolean          default(FALSE), not null
#  current_status       :string
#  created_at           :datetime
#  updated_at           :datetime
#  stripe_customer_id   :string
#  stripe_customer_data :text
#  livemode             :boolean          default(FALSE)
#  active               :boolean          default(FALSE)
#  terms_and_conditions :boolean          default(FALSE)
#  coupon_id            :integer
#

class Subscription < ActiveRecord::Base

  include LearnSignalModelExtras
  serialize :stripe_customer_data, Hash

  # attr-accessible
  attr_accessible :user_id, :subscription_plan_id, :complimentary,
                  :current_status, :stripe_customer_id, :stripe_token,
                  :livemode, :next_renewal_date, :active, :terms_and_conditions,
                  :stripe_guid, :stripe_customer_data, :coupon_id

  # Constants
  STATUSES = %w(active past_due canceled canceled-pending unpaid suspended)
  VALID_STATES = %w(active past_due canceled-pending)

  # relationships
  belongs_to :user, inverse_of: :subscriptions
  has_many :invoices
  has_many :invoice_line_items
  belongs_to :subscription_plan
  belongs_to :coupon
  has_one :student_access
  has_many :subscription_transactions
  has_many :charges
  has_many :refunds
  has_one :referred_signup

  # validation
  validates :terms_and_conditions, presence: true
  validates :user_id, presence: true
  validates :subscription_plan_id, presence: true
  validates :next_renewal_date, presence: true
  validates :current_status, inclusion: {in: STATUSES}
  validates :livemode, inclusion: {in: [Invoice::STRIPE_LIVE_MODE]}
  validates_length_of :stripe_guid, maximum: 255, allow_blank: true
  validates_length_of :stripe_customer_id, maximum: 255, allow_blank: true


  # callbacks
  after_create :create_subscription_payment_card
  after_save :update_student_access

  # scopes
  scope :all_in_order, -> { order(:user_id, :id) }
  scope :in_created_order, -> { order(:created_at).reverse_order }
  scope :all_of_status, lambda { |the_status| where(current_status: the_status) }
  scope :all_active, -> { where(active: true) }
  scope :all_valid, -> { where(current_status: VALID_STATES) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }

  # class methods

  # instance methods
  def cancel
    if self.stripe_customer_id && self.stripe_guid
      # call stripe and cancel the subscription
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
      response = stripe_subscription.delete(at_period_end: true).to_hash
      if response[:status] == 'active' && response[:cancel_at_period_end] == true
        self.update_attribute(:current_status, 'canceled-pending')
      elsif response[:status] == 'past_due'
        self.update_attribute(:current_status, 'canceled')
        self.user.student_access.update_attributes(content_access: false)
        #We don't send any email here!!
        Rails.logger.error "ERROR: Subscription#cancel with a past_due status updated local sub from past_due to canceled StripeResponse:#{response}."
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

  def immediate_cancel
    if self.stripe_customer_id && self.stripe_guid
      # call stripe and cancel the subscription
      stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
      stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
      response = stripe_subscription.delete(at_period_end: false).to_hash
      if response[:status] == 'canceled'
        self.update_attribute(:current_status, 'canceled')
        self.user.student_access.update_attributes(content_access: false)
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

  def destroyable?
    self.invoices.empty? &&
      self.invoice_line_items.empty? &&
      self.subscription_transactions.empty? &&
      self.referred_signup.nil?
      #self.livemode == Invoice::STRIPE_LIVE_MODE &&
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
    self.current_status == 'active'
  end

  def canceled_status?
    self.current_status == 'canceled'
  end

  def past_due_status?
    self.current_status == 'past_due'
  end

  def unpaid_status?
    self.current_status == 'unpaid'
  end

  def canceled_pending_status?
    self.current_status == 'canceled-pending'
  end

  def suspended_status?
    self.current_status == 'suspended'
  end

  def billing_amount
    self.subscription_plan.amount
  end

  def reactivation_options
    SubscriptionPlan.where(currency_id: self.subscription_plan.currency_id,
                           available_to_students: true).where('price > 0.0').generally_available.all_active.all_in_order
  end

  def upgrade_options
    current_plan = self.subscription_plan
    SubscriptionPlan.includes(:currency).where.not(id: current_plan.id).for_students.in_currency(current_plan.currency_id).all_active.all_in_order
  end

  def upgrade_plan(new_plan_id)
    new_subscription_plan = SubscriptionPlan.find_by_id(new_plan_id)
    user = self.user
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
    unless %w(active past_due).include?(self.current_status)
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.this_subscription_cant_be_upgraded'))
      return self
    end
    # only student_users are allowed to upgrade their plan
    unless self.user.trial_or_sub_user?
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_are_not_permitted_to_upgrade'))
      return self
    end
    # Make sure they have a default credit card in place
    unless self.user.subscription_payment_cards.all_default_cards.length > 0
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.you_have_no_default_payment_card'))
      return self
    end

    #### if we're here, then we're good to go.
    stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    if stripe_customer
      stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)
      stripe_subscription.plan = new_subscription_plan.stripe_guid
      stripe_subscription.prorate = true
      #stripe_subscription.trial_end = 'now'
      stripe_subscription.trial_end = 'now'

      result = stripe_subscription.save # saves it at stripe.com, not in our DB

      #### if we are here, the subscription change on Stripe has gone well
      #### Now we need to create a new Subscription in our DB.
      ActiveRecord::Base.transaction do
        new_sub = Subscription.new(
            user_id: self.user.id,
            subscription_plan_id: new_plan_id,
            complimentary: false,
            active: true,
            livemode: (result[:plan][:livemode]),
            current_status: result[:status],
        )
        # mass-assign-protected attributes

        ## This means it will have the same stripe_guid as the old Subscription ##
        new_sub.stripe_guid = result[:id]

        new_sub.next_renewal_date = Time.at(result[:current_period_end])
        new_sub.stripe_customer_id = self.stripe_customer_id
        new_sub.stripe_customer_data = Stripe::Customer.retrieve(self.stripe_customer_id).to_hash
        new_sub.save(validate: false)

        #Only one subscription is active for a user at a time; when creating new subscriptions old ones must be set to active: false.
        self.update_attributes(current_status: 'canceled', active: false)

        return new_sub
      end
    else
      return self
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

  def update_from_stripe
    if self.stripe_guid && self.stripe_customer_id
      begin
        stripe_customer = Stripe::Customer.retrieve(self.stripe_customer_id)

        if stripe_customer
          begin
            stripe_subscription = stripe_customer.subscriptions.retrieve(self.stripe_guid)

            subscription = Subscription.find_by_stripe_guid(stripe_subscription.id)
            subscription.next_renewal_date = Time.at(stripe_subscription.current_period_end)
            subscription.current_status = stripe_subscription.status
            subscription.stripe_customer_data = stripe_customer.to_hash.deep_dup
            subscription.livemode = stripe_subscription[:plan][:livemode]
            subscription.save(validate: false)

          rescue Stripe::InvalidRequestError => e
            subscription.update_attribute(:current_status, 'canceled')
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
      self.update_attributes(current_status: 'active', active: true)

    else
      errors.add(:base, I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe'))
    end
    self
  end

  protected

  def create_subscription_payment_card
    stripe_customer = Stripe::Customer.retrieve(self.user.stripe_customer_id)
    array_of_cards = stripe_customer.sources.data
    SubscriptionPaymentCard.create_from_stripe_array(array_of_cards, self.user_id, stripe_customer.default_source)
  end

  def update_student_access
    ## TODO Review this!
    if self.active && self.student_access
      if %w(unpaid suspended canceled).include?(self.current_status)
        self.student_access.update_attribute(:content_access, false)
      elsif %w(active past_due canceled-pending).include?(self.current_status)
        self.student_access.update_attribute(:content_access, true)
      end
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
