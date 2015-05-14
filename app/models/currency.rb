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

  include ActionView::Helpers::NumberHelper
  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :iso_code, :name, :leading_symbol, :trailing_symbol, :active, :sorting_order

  # Constants

  # relationships
  # todo has_many :corporate_customer_prices
  has_many :countries
  has_many :invoices
  has_many :invoice_line_items
  has_many :subscription_plans
  has_many :subscription_transactions

  # validation
  validates :iso_code, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :leading_symbol, presence: true, length: {maximum: 255}
  validates :trailing_symbol, presence: true, length: {maximum: 255}
  validates :sorting_order, presence: true, numericality: true

  # callbacks
  before_validation { squish_fields(:name, :iso_code, :leading_symbol, :trailing_symbol) }

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :iso_code) }
  scope :all_active, -> { where(active: true) }
  scope :all_inactive, -> { where(active: false) }

  # class methods
  def self.get_by_iso_code(the_iso_code)
    Currency.where(iso_code: the_iso_code).first || nil
  end

  # instance methods
  def destroyable?
    !self.active && self.countries.empty? && self.invoices.empty? && self.invoice_line_items.empty? && self.subscription_transactions.empty? && self.subscription_plans.empty?
  end

  def format_number(the_number=0)
    number_to_currency(the_number, precision: 0, unit: self.leading_symbol)
  end

  protected

end
