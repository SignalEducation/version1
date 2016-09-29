class StudentUserType < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :description, :subscription, :product_order

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
  def self.default_sub_user_type
    where(subscription: true, product_order: false)
  end

  def self.default_product_user_type
    where(subscription: false, product_order: true)
  end

  def self.default_sub_and_product_user_type
    where(subscription: true, product_order: true)
  end

  def self.default_no_user_type
    where(subscription: false, product_order: false)
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
