# == Schema Information
#
# Table name: subject_course_categories
#
#  id           :integer          not null, primary key
#  name         :string
#  payment_type :string
#  active       :boolean          default(FALSE)
#  subdomain    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class SubjectCourseCategory < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :payment_type, :active, :subdomain

  # Constants
  PAYMENT_TYPES = %w(Subscription Product Corporate)

  # relationships
  has_many :subject_courses

  # validation
  validates :name, presence: true, uniqueness: true
  validates :payment_type, presence: true, inclusion: { in: PAYMENT_TYPES}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }
  scope :all_active, -> { where(active: true) }
  scope :all_product, -> { where(payment_type: 'Product') }
  scope :all_subscription, -> { where(payment_type: 'Subscription') }
  scope :all_corporate, -> { where(payment_type: 'Corporate') }

  # class methods
  def self.default_subscription_category
    where(payment_type: 'Subscription', active: true).first
  end

  def self.default_product_category
    where(payment_type: 'Product', active: true).first
  end

  def self.default_corporate_category
    where(payment_type: 'Corporate', active: true).first
  end

  # instance methods
  def destroyable?
    false
  end

  def active_children
    self.children.all_active.all_in_order
  end

  def first_active_child
    self.active_children.first
  end

  def children
    self.subject_courses.all
  end


  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
