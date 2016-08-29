# == Schema Information
#
# Table name: orders
#
#  id                 :integer          not null, primary key
#  product_id         :integer
#  subject_course_id  :integer
#  user_id            :integer
#  stripe_guid        :string
#  stripe_customer_id :string
#  live_mode          :boolean          default(FALSE)
#  current_status     :string
#  coupon_code        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Order < ActiveRecord::Base

  # attr-accessible
  attr_accessible :product_id, :subject_course_id, :user_id, :stripe_guid, :stripe_customer_id, :live_mode, :current_status

  # Constants

  # relationships
  belongs_to :product
  belongs_to :subject_course
  belongs_to :user

  # validation
  validates :product_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_guid, presence: true
  validates :stripe_customer_id, presence: true
  validates :current_status, presence: true

  # callbacks
  before_destroy :check_dependencies

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

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
