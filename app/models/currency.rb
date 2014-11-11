# == Schema Information
#
# Table name: currencies
#
#  id              :integer          not null, primary key
#  iso_code        :string(255)
#  name            :string(255)
#  leading_symbol  :string(255)
#  trailing_symbol :string(255)
#  active          :boolean          default(FALSE), not null
#  sorting_order   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class Currency < ActiveRecord::Base

  # attr-accessible
  attr_accessible :iso_code, :name, :leading_symbol, :trailing_symbol, :active, :sorting_order

  # Constants

  # relationships
  # todo has_many :corporate_customer_prices
  has_many :countries
  has_many :invoices
  has_many :subscription_plans
  has_many :subscription_transactions

  # validation
  validates :iso_code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :leading_symbol, presence: true
  validates :trailing_symbol, presence: true
  validates :sorting_order, presence: true, numericality: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :iso_code) }
  scope :all_active, -> { where(active: true) }
  scope :all_inactive, -> { where(active: false) }

  # class methods

  # instance methods
  def destroyable?
    !self.active && self.countries.empty? && self.invoices.empty? && self.subscription_transactions.empty? && self.subscription_plans.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
