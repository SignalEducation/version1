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
#

class Order < ActiveRecord::Base

  include LearnSignalModelExtras
  serialize :stripe_order_payment_data, JSON

  # attr-accessible
  attr_accessible :product_id, :subject_course_id, :user_id, :stripe_guid, :stripe_customer_id, :live_mode, :stripe_status, :stripe_order_payment_data, :stripe_token, :stripe_order_payment_data, :mock_exam_id, :terms_and_conditions, :reference_guid

  # Constants
  ORDER_STATUS = %w(created paid canceled)

  # relationships
  belongs_to :product
  belongs_to :subject_course
  belongs_to :mock_exam
  belongs_to :user
  has_one :order_transaction

  # validation
  validates :product_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_guid, presence: true
  validates :reference_guid, presence: true,
            uniqueness: true
  validates :terms_and_conditions, presence: true
  validates :stripe_customer_id, presence: true
  validates :stripe_status, presence: true

  # callbacks
  before_create :assign_random_guid
  before_destroy :check_dependencies
  after_create :create_order_transaction

  # scopes
  scope :all_in_order, -> { order(:product_id) }
  scope :all_for_course, lambda { |course_id| where(subject_course_id: course_id) }
  scope :all_for_product, lambda { |product_id| where(product_id: product_id) }
  scope :all_for_user, lambda { |user_id| where(user_id: user_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  def mock_exam
    self.product.mock_exam
  end

  ## setter method ##
  def stripe_token=(t)
    @stripe_token = t
  end

  ## getter method ##
  def stripe_token
    @stripe_token
  end

  protected

  def assign_random_guid
    reference_guid = "Order_#{ApplicationController.generate_random_number(10)}"
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
end
