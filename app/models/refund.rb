# == Schema Information
#
# Table name: refunds
#
#  id                 :integer          not null, primary key
#  stripe_guid        :string
#  charge_id          :integer
#  stripe_charge_guid :string
#  invoice_id         :integer
#  subscription_id    :integer
#  user_id            :integer
#  manager_id         :integer
#  amount             :integer
#  reason             :text
#  status             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Refund < ActiveRecord::Base

  # attr-accessible
  attr_accessible :stripe_guid, :charge_id, :stripe_charge_guid, :invoice_id, :subscription_id, :user_id,
                  :manager_id, :amount, :reason, :status

  # Constants

  # relationships
  belongs_to :charge
  belongs_to :invoice
  belongs_to :subscription
  belongs_to :user
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id

  # validation
  validates :stripe_guid, presence: true
  validates :charge_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :stripe_charge_guid, presence: true
  validates :invoice_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :manager_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :amount, presence: true
  validates :reason, presence: true
  validates :status, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:stripe_guid) }

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
