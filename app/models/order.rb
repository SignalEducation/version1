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

class Order < ActiveRecord::Base
  include LearnSignalModelExtras
  serialize :stripe_order_payment_data, JSON
  attr_accessor :use_paypal, :paypal_approval_url, :stripe_token

  # Constants
  ORDER_STATUS = %w(created paid canceled)

  # relationships
  belongs_to :product
  belongs_to :subject_course, optional: true
  belongs_to :mock_exam, optional: true
  belongs_to :user
  has_one :order_transaction

  # validation
  validates :reference_guid, uniqueness: true, allow_blank: true
  validates :terms_and_conditions, presence: true
  validates :stripe_status, :stripe_guid, :stripe_customer_id, presence: true, if: :stripe?

  # callbacks
  before_create :assign_random_guid
  before_destroy :check_dependencies
  after_create :create_order_transaction

  # scopes
  scope :all_in_order, -> { order(:product_id) }
  scope :all_for_course, lambda { |course_id| where(subject_course_id: course_id) }
  scope :all_for_product, lambda { |product_id| where(product_id: product_id) }
  scope :all_for_user, lambda { |user_id| where(user_id: user_id) }

  # INSTANCE METHODS ===========================================================

  # STATE MACHINE ==============================================================

  state_machine initial: :pending do
    event :complete do
      transition [:pending, :errored] => :completed
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
    MandrillWorker.perform_async(self.user_id, 'send_mock_exam_email', Rails.application.routes.url_helpers.account_url(host: 'https://learnsignal.com'), product.mock_exam.name, product.mock_exam.file, self.reference_guid)
  end

  def generate_exercises
    if product.mock_exam?
      user.exercises.create(product_id: product_id)
    elsif product.correction_pack?
      (1..product.correction_pack_count).each do |ex|
        user.exercises.create(product_id: product_id)
      end
    end
  end

  def mock_exam
    self.product.mock_exam
  end

  protected

  def assign_random_guid
    self.reference_guid = "Order_#{ApplicationController.generate_random_number(10)}"
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def create_order_transaction
    OrderTransaction.create_from_stripe_data(self.stripe_order_payment_data, self.user_id, self.id, self.product_id)
  end

  def stripe?
    stripe_token.present? || stripe_guid.present?
  end
end
