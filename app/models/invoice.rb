# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  corporate_customer_id       :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  unit_price_ex_vat           :decimal(, )
#  line_total_ex_vat           :decimal(, )
#  vat_rate_id                 :integer
#  line_total_vat_amount       :decimal(, )
#  line_total_inc_vat          :decimal(, )
#  created_at                  :datetime
#  updated_at                  :datetime
#

class Invoice < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :corporate_customer_id, :subscription_transaction_id,
                  :subscription_id, :number_of_users, :currency_id,
                  :unit_price_ex_vat, :vat_rate_id

  # Constants

  # relationships
  belongs_to :currency
  # todo belongs_to :corporate_customer
  belongs_to :subscription_transaction
  belongs_to :subscription
  belongs_to :user
  # todo belongs_to :vat_rate

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_transaction_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subscription_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :number_of_users, presence: true
  validates :currency_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :unit_price_ex_vat, presence: true
  validates :vat_rate_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_create :calculate_line_totals
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def calculate_line_totals
    self.line_total_ex_vat = self.unit_price_ex_vat * self.number_of_users.to_f
    # todo self.line_total_vat_amount = self.line_total_ex_vat * self.vat_rate.percentage_rate / 100.0
    self.line_total_inc_vat = self.line_total_ex_vat + self.line_total_vat_amount
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
