# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  course_id                 :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default("false")
#  stripe_status             :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default("false")
#  reference_guid            :string
#  paypal_guid               :string
#  paypal_status             :string
#  state                     :string
#  cancellation_note         :text
#  cancelled_by_id           :bigint
#  stripe_payment_method_id  :string
#  stripe_payment_intent_id  :string
#  ahoy_visit_id             :uuid
#

class Order < ApplicationRecord
  include LearnSignalModelExtras
  include OrderReport

  serialize :stripe_order_payment_data, JSON
  attr_accessor :use_paypal, :paypal_approval_url, :stripe_client_secret

  ORDER_STATUS = %w[created paid canceled].freeze

  # relationships
  belongs_to :product
  belongs_to :course, optional: true
  belongs_to :mock_exam, optional: true
  belongs_to :user
  visitable :ahoy_visit

  has_one :order_transaction, dependent: :destroy
  has_one :invoice, autosave: true, dependent: :restrict_with_error

  has_many :exercises, dependent: :restrict_with_error
  delegate :mock_exam, to: :product

  # validation
  validates :reference_guid, uniqueness: true, allow_blank: true
  validates :stripe_customer_id, :stripe_payment_method_id,
            :stripe_payment_intent_id, presence: true, if: :stripe?
  validates :paypal_guid, :paypal_status, presence: true, if: :paypal?

  # callbacks
  before_create :assign_random_guid
  before_create :generate_invoice
  before_destroy :check_dependencies
  after_save :update_hub_spot_data, :update_segment_user

  # scopes
  scope :all_in_order,        -> { order(:product_id) }
  scope :all_stripe,          -> { where.not(stripe_guid: nil).where(paypal_guid: nil) }
  scope :for_lifetime_access, -> { includes(:product).where('products.product_type = ?', 3).references(:products) }
  scope :for_product,         ->(product_id) { includes(:product).where('products.id = ?', product_id).references(:products) }
  scope :for_group,           ->(group_id)   { includes(:product).where('products.group_id = ?', group_id).references(:products) }
  scope :all_for_course,      ->(course_id)  { where(course_id: course_id) }
  scope :all_for_product,     ->(product_id) { where(product_id: product_id) }
  scope :all_for_user,        ->(user_id)    { where(user_id: user_id) }
  scope :all_valid,           -> { where(state: 'completed') }
  scope :cancelled,           -> { where(state: 'cancelled') }

  scope :cbe_by_user, lambda { |user_id, cbe_id|
    joins(:product).
      where(user_id: user_id, products: { product_type: :cbe, cbe_id: cbe_id })
  }

  scope :orders_completed_in_time, lambda { |time|
    with_state(:completed).where('orders.created_at > (?)', time)
  }

  # STATE MACHINE ==============================================================

  state_machine initial: :pending do
    event :complete do
      transition %i[pending errored cancelled] => :completed
    end

    event :mark_pending do
      transition all => :pending
    end

    event :mark_payment_action_required do
      transition all => :pending_3d_secure
    end

    event :confirm_3d_secure do
      transition pending_3d_secure: :completed
    end

    event :record_error do
      transition pending: :errored
    end

    event :cancel do
      transition all => :cancelled
    end

    event :expire do
      transition completed: :expired
    end

    after_transition all => :completed do |order, _transition|
      order.execute_order_completion
      order.generate_exercises

      SegmentService.new.track_order_payment_complete_event(order)
    end
  end

  # CLASS METHODS ==============================================================

  def self.send_daily_orders_update
    return if (orders = orders_completed_in_time(24.hours.ago)) && orders.empty?

    slack = SlackService.new
    slack.notify_channel('corrections', slack.order_summary_attachment(orders),
                         icon_emoji: ':chart_with_upwards_trend:')
  end

  def self.product_type_count(product_type)
    joins(:product).where(products: { product_type: product_type }).count
  end

  def self.to_csv(options = {})
    attributes = %w[inv_id invoice_created sub_id sub_created user_email user_created
                    payment_provider sub_stripe_guid sub_paypal_guid sub_exam_body sub_status sub_type
                    invoice_type payment_interval plan_name currency_symbol plan_price sub_total total
                    card_country user_country hubspot_source hubspot_source_1 hubspot_source_2 first_visit_source
                    first_visit_utm_campaign first_visit_medium first_visit_date first_visit_referring_domain
                    first_visit_landing_page first_visit_referrer
                    order_id order_created name product_name stripe_id paypal_guid state
                    product_type leading_symbol price user_country card_country
                    user_subscriptions_revenue user_orders_revenue user_total_revenue]

    CSV.generate(options) do |csv|
      csv << attributes
      all.find_each do |order|
        csv << attributes.map { |attr| order.send(attr) }
      end
    end
  end

  # INSTANCE METHODS ===========================================================

  def confirm_payment_intent
    StripeService.new.confirm_purchase(self)
  end

  def destroyable?
    false
  end

  def execute_order_completion
    return if Rails.env.test?

    if %w[mock_exam correction_pack].include?(product.product_type)
      Message.create(
        process_at: Time.zone.now,
        user_id: user_id,
        kind: :account,
        order_id: id,
        template: 'send_mock_exam_email',
        template_params: {
          url: user_exercise_url,
          product: product.name_by_type,
          reference_guid: reference_guid
        }
      )
    elsif %w[lifetime_access program_access].include?(product.product_type)
      Message.create(
        process_at: Time.zone.now,
        user_id: user_id,
        kind: :account,
        order_id: id,
        template: 'send_successful_order_email',
        template_params: {
          url: account_url,
          product: product.name_by_type
        }
      )
    end

    invoice.update(paid: true, payment_closed: true)
  end

  def generate_exercises
    return if %w[lifetime_access program_access].include?(product.product_type)

    count = product.correction_pack_count || 1
    (1..count).each { user.exercises.create(product_id: product_id, order_id: id) }
  end

  def paypal?
    paypal_guid.present?
  end

  def stripe?
    stripe_payment_intent_id.present? || stripe_payment_method_id.present?
  end

  def payment_provider
    return 'stripe' if stripe?
    return 'paypal' if paypal?

    'unknown'
  end

  def generate_invoice
    invoice_params = { user_id: user_id, currency_id: product.currency_id,
                       sub_total: product.price, total: product.price,
                       issued_at: updated_at, object_type: 'invoice',
                       amount_due: product.price }
    self.invoice = Invoice.new(invoice_params)
    invoice.invoice_line_items << InvoiceLineItem.new(amount: invoice.total,
                                                      currency_id: invoice.currency_id)
  rescue => e
    Rails.logger.error "ERROR: Order#generate_invoice failed to create. Error:#{e.inspect}"
  end

  def exam_body_name
    return product.cbe.course.exam_body.name if product.cbe?

    product.group.exam_body.name
  end

  def exam_body_id
    return product.cbe.course.exam_body.id if product.cbe?

    product.group.exam_body.id
  end

  # kind -> increment! || decrement!
  def update_revenue(kind, value)
    user.send(kind, :orders_revenue, value)
  end

  protected

  def assign_random_guid
    self.reference_guid = "Order_#{ApplicationController.generate_random_number(10)}"
  end

  def check_dependencies
    return if destroyable?
    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end

  def create_order_transaction
    OrderTransaction.create_from_stripe_data(stripe_order_payment_data,
                                             user_id, id, product_id)
  end

  def user_exercise_url
    UrlHelper.instance.student_dashboard_url(anchor: :exercises,
                                          host: LEARNSIGNAL_HOST)
  end

  def account_url
    UrlHelper.instance.account_url(host: LEARNSIGNAL_HOST)
  end

  def update_hub_spot_data
    return if Rails.env.test?

    HubSpotContactWorker.perform_async(user_id) if product.lifetime_access? && completed?
  end

  def update_segment_user
    return if Rails.env.test?

    SegmentService.new.identify_user(user)
  end
end
