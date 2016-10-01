# == Schema Information
#
# Table name: student_user_types
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :text
#  subscription  :boolean          default(FALSE)
#  product_order :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  free_trial    :boolean          default(FALSE)
#

class StudentUserType < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :description, :subscription, :product_order, :free_trial

  # Constants

  # relationships
  has_many :users

  # validation
  validates :name, presence: true, uniqueness: true, length: { maximum: 255}
  validates :description, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:name) }

  # class methods
  def self.default_free_trial_user_type
    where(free_trial: true, subscription: false, product_order: false).first
  end

  def self.default_sub_user_type
    where(free_trial: false, subscription: true, product_order: false).first
  end

  def self.default_product_user_type
    where(free_trial: false, subscription: false, product_order: true).first
  end

  def self.default_sub_and_product_user_type
    where(free_trial: false, subscription: true, product_order: true).first
  end

  def self.default_free_trial_and_product_user_type
    where(free_trial: true, subscription: false, product_order: true).first
  end

  def self.default_no_access_user_type
    #User that created an account through purchase product process but didn't complete purchase so has an account but no access to any content or a subscription user with a canceled subscription
    where(free_trial: false, subscription: false, product_order: false).first
  end

  # instance methods
  def destroyable?
    self.users.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
