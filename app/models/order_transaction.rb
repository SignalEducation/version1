# == Schema Information
#
# Table name: order_transactions
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  user_id          :integer
#  product_id       :integer
#  stripe_order_id  :string
#  stripe_charge_id :string
#  live_mode        :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class OrderTransaction < ActiveRecord::Base

  # attr-accessible
  attr_accessible :order_id, :user_id, :stripe_charge_id, :stripe_charge_id, :product_id, :stripe_order_id, :live_mode

  # Constants

  # relationships
  belongs_to :product
  belongs_to :order
  belongs_to :user

  # validation
  validates :order_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :product_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_order_id, presence: true
  validates :stripe_charge_id, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:order_id) }

  # class methods

  def self.create_from_stripe_data(order, user_id, order_id, product_id)
    OrderTransaction.create!(
        user_id: user_id,
        order_id: order_id,
        product_id: product_id,
        stripe_order_id: order["id"],
        stripe_charge_id: order["charge"],
        live_mode: order["livemode"],
    )
  rescue => e
    Rails.logger.error "ERROR: OrderTransaction#create_from_stripe_data failed to save. Error:#{e.inspect}"
    return false
  end

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
