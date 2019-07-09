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
  attr_accessor :use_paypal, :paypal_approval_url, :stripe_token

  # Constants
  ORDER_STATUS = %w[created paid canceled].freeze

  # relationships
  belongs_to :product
  belongs_to :subject_course, optional: true
  belongs_to :mock_exam, optional: true
  belongs_to :user
  has_one :order_transaction
  has_one :invoice, autosave: true

  # delegates
  delegate :mock_exam, to: :product

  # validation
  validates :reference_guid, uniqueness: true, allow_blank: true
  validates :stripe_status, :stripe_guid, :stripe_customer_id, presence: true, if: :stripe?

  # callbacks
  before_create :assign_random_guid
  before_create :generate_invoice
  before_destroy :check_dependencies
  after_create :create_order_transaction, :remove_audience_tag

  # scopes
  scope :all_in_order,    -> { order(:product_id) }
  scope :all_stripe,      -> { where.not(stripe_guid: nil).where(paypal_guid: nil) }
  scope :all_for_course,  ->(course_id)  { where(subject_course_id: course_id) }
  scope :all_for_product, ->(product_id) { where(product_id: product_id) }
  scope :all_for_user,    ->(user_id)    { where(user_id: user_id) }

  # INSTANCE METHODS ===========================================================

  # STATE MACHINE ==============================================================

  state_machine initial: :pending do
    event :complete do
      transition %i[pending errored] => :completed
    end

    event :record_error do
      transition pending: :errored
    end

    after_transition all => :completed do |order, _transition|
      order.execute_order_completion
      order.generate_exercises
    end
  end

  # CLASS METHODS ==============================================================

  # INSTANCE METHODS ===========================================================

  def destroyable?
    false
  end

  def execute_order_completion
    return if Rails.env.test?

    MandrillWorker.perform_async(user_id,
                                 'send_mock_exam_email',
                                 user_exercise_url(user_id),
                                 product.mock_exam.name,
                                 reference_guid)

    invoice.update(paid: true, payment_closed: true)
  end

  def generate_exercises
    count = product.correction_pack_count || 1

    (1..count).each { user.exercises.create(product_id: product_id) }
  end

  def stripe?
    stripe_token.present? || stripe_guid.present?
  end

  def generate_invoice
    invoice_params = { user_id: user_id,
                       currency_id: product.currency_id,
                       sub_total: product.price,
                       total: product.price,
                       issued_at: updated_at,
                       object_type: 'invoice',
                       amount_due: product.price }
    invoice_params.merge!(paid: true, payment_closed: true) if stripe? && stripe_status == 'paid'

    self.invoice = Invoice.new(invoice_params)
    invoice.invoice_line_items << InvoiceLineItem.new(amount: invoice.total,
                                                      currency_id: invoice.currency_id)
  rescue => e
    Rails.logger.error "ERROR: Order#generate_invoice failed to create. Error:#{e.inspect}"
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
    OrderTransaction.
      create_from_stripe_data(stripe_order_payment_data, user_id, id, product_id)
  end

  def remove_audience_tag
    MailchimpAddCheckoutTagWorker.perform_async(user_id, product.name, 'inactive')
  end

  def user_exercise_url(user_id)
    UrlHelper.instance.user_exercises_url(user_id: user_id,
                                          host: 'https://learnsignal.com')
  end
end
