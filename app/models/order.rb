# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  subject_course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default(FALSE)
#  stripe_status             :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#  paypal_guid               :string
#  paypal_status             :string
#  state                     :string
#

class Order < ApplicationRecord
  include LearnSignalModelExtras
  serialize :stripe_order_payment_data, JSON
  attr_accessor :use_paypal, :paypal_approval_url, :stripe_client_secret

  ORDER_STATUS = %w[created paid canceled].freeze

  # relationships
  belongs_to :product
  belongs_to :subject_course, optional: true
  belongs_to :mock_exam, optional: true
  belongs_to :user
  visitable :ahoy_visit

  has_one :order_transaction
  has_one :invoice, autosave: true

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

  # scopes
  scope :all_in_order,    -> { order(:product_id) }
  scope :all_stripe,      -> { where.not(stripe_guid: nil).where(paypal_guid: nil) }
  scope :all_for_course,  ->(course_id)  { where(subject_course_id: course_id) }
  scope :all_for_product, ->(product_id) { where(product_id: product_id) }
  scope :all_for_user,    ->(user_id)    { where(user_id: user_id) }

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
      transition %i[pending errored] => :completed
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

    after_transition all => :completed do |order, _transition|
      order.execute_order_completion unless Rails.env.test?
      order.generate_exercises
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

  # INSTANCE METHODS ===========================================================

  def confirm_payment_intent
    StripeService.new.confirm_purchase(self)
  end

  def destroyable?
    false
  end

  def execute_order_completion
    return if Rails.env.test?

    product_name = product.cbe? ? product.cbe.name : product.mock_exam.name

    MandrillWorker.perform_async(user_id,
                                 'send_mock_exam_email',
                                 user_exercise_url(user_id),
                                 product_name, reference_guid)
    invoice.update(paid: true, payment_closed: true)
  end

  def generate_exercises
    count = product.correction_pack_count || 1
    (1..count).each { user.exercises.create(product_id: product_id) }
  end

  def paypal?
    paypal_guid.present?
  end

  def stripe?
    stripe_payment_intent_id.present? || stripe_payment_method_id.present?
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
    return product.cbe.subject_course.exam_body.name if product.cbe?

    product.mock_exam.subject_course.exam_body.name
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

  def user_exercise_url(user_id)
    UrlHelper.instance.user_exercises_url(user_id: user_id,
                                          host: LEARNSIGNAL_HOST)
  end
end
