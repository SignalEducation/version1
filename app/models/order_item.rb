class OrderItem < ActiveRecord::Base

  # attr-accessible
  attr_accessible :order_id, :user_id, :product_id, :stripe_customer_id, :price, :currency_id, :quantity

  # Constants

  # relationships
  belongs_to :order
  belongs_to :user
  belongs_to :product
  belongs_to :currency

  # validation
  validates :order_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :product_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_customer_id, presence: true
  validates :price, presence: true
  validates :currency_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quantity, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:order_id) }
  scope :all_in_currency, lambda { |id| where(currency_id: id) }

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
