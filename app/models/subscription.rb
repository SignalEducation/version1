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
#

class Subscription < ActiveRecord::Base

  include LearnSignalModelExtras

  serialize :original_stripe_subscription_data

  # attr-accessible
  attr_accessible :user_id, :corporate_customer_id, :subscription_plan_id,
                  :complementary, :current_status,
                  :stripe_customer_id, :original_stripe_customer_data, :stripe_token

  # Constants
  STATUSES = %w(trialing active past_due canceled unpaid suspended paused)

  # relationships
  belongs_to :user
  belongs_to :corporate_customer
  has_many :invoices
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
  validates :stripe_token, presence: true, on: :create

  # callbacks
  before_create :create_on_stripe_platform
  after_create  :create_a_subscription_transaction
  before_update :update_on_stripe_platform

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_of_status, lambda { |the_status| where(current_status: the_status) }

  # class methods

  # instance methods
  def destroyable?
    self.invoices.empty? && self.subscription_transactions.empty?
  end

  def stripe_token=(t) # setter method
    @stripe_token = t
  end

  def stripe_token # getter method
    @stripe_token
  end

  protected

  def create_on_stripe_platform
    # todo see https://stripe.com/docs/guides/subscriptions#step-2-subscribe-customers
    stripe_customer = Stripe::Customer.create(
            card: @stripe_token,
            plan: self.subscription_plan.stripe_guid,
            email: self.user.email
    )

    #self.subscription_plan_id is set in the UI
    self.stripe_guid = stripe_customer.subscriptions.data[0].id
    self.next_renewal_date = stripe_customer.subscriptions.data[0].current_period_end
    self.complementary = false
    self.current_status = stripe_customer.subscriptions.data[0].status
    self.stripe_customer_id = stripe_customer.id
    self.original_stripe_customer_data = stripe_customer

    if Rails.env.production? && stripe_customer.livemode == false
      errors.add(:base, 'Non-live transaction on the Live server')
      Rails.error.log 'models/subscription.rb#create_on_stripe_platform - Non-live transaction on Production platform. StripeCustomer: ' + stripe_customer.inspect + '. Self: ' + self.inspect
      false
    else
      true
    end
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
    else
      "Dev-#{rand(9999)}: "
    end
  end

  def update_on_stripe_platform
    # todo stripe integration
    #self.stripe_guid = self.stripe_guid.split('-')[0] +
    # '-' + ((self.stripe_guid.split('-')[1].to_i + 1).to_s)
  end

  def sample_data
    { id: 'cus_5JJjWCDxOcq2Yf',
      object: 'customer',
      created: 1418343370,
      livemode: false,
      description: nil,
      email: 'dan.laffan.test@gmail.com',
      delinquent: false,
      metadata: {},
      subscriptions: {
            object: 'list',
            total_count: 1,
            has_more: false,
            url: '/v1/customers/cus_5JJjWCDxOcq2Yf/subscriptions',
            data:[
                  {id:'sub_5JJjYP1QnQ5iSx',
                   plan:{
                           id: 'development-of5JfmyFLxFjmemVWPAg',
                           interval: 'month',
                           name: 'LearnSignal Monthly',
                           created: 1418342780,
                           amount: 999,
                           currency: 'eur',
                           object: 'plan',
                           livemode: false,
                           interval_count: 1,
                           trial_period_days: 7,
                           metadata: {},
                           statement_description: 'LearnSignal'
                   },
                   object: 'subscription',
                   start: 1418343370,
                   status: 'trialing',
                   customer: 'cus_5JJjWCDxOcq2Yf',
                   cancel_at_period_end: false,
                   current_period_start: 1418343370,
                   current_period_end: 1418948170,
                   ended_at: nil,
                   trial_start: 1418343370,
                   trial_end: 1418948170,
                   canceled_at: nil,
                   quantity: 1,
                   application_fee_percent: nil,
                   discount: nil,
                   metadata:{}
            }
        ]
      },
      discount: nil,
      account_balance: 0,
      currency: 'eur',
      cards: {
            object: 'list',
            total_count: 1,
            has_more: false,
            url: '/v1/customers/cus_5JJjWCDxOcq2Yf/cards',
            data: [
                  {id: 'card_5JJjkBnrgGtHca',
                   object: 'card',
                   last4: '4242',
                   brand: 'Visa',
                   funding: 'credit',
                   exp_month: 1,
                   exp_year: 2015,
                   fingerprint: '2JyQfTIvakRtY5NA',
                   country: 'US',
                   name: nil,
                   address_line1: nil,
                   address_line2: nil,
                   address_city: nil,
                   address_state: nil,
                   address_zip: nil,
                   address_country: nil,
                   cvc_check: 'pass',
                   address_line1_check: nil,
                   address_zip_check: nil,
                   dynamic_last4: nil,
                   customer: 'cus_5JJjWCDxOcq2Yf'
                  }
            ]
      },
      default_card: 'card_5JJjkBnrgGtHca'
    }
  end

end
