# == Schema Information
#
# Table name: countries
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  iso_code      :string(255)
#  country_tld   :string(255)
#  sorting_order :integer
#  in_the_eu     :boolean          default(FALSE), not null
#  currency_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  continent     :string(255)
#

class Country < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :iso_code, :country_tld, :sorting_order,
                  :in_the_eu, :currency_id, :continent

  # Constants
  CONTINENTS = ['Europe', 'North America', 'Central America', 'South America', 'Asia', 'Africa','Australia', 'Antarctic']

  # relationships
  has_many :corporate_customers
  belongs_to :currency
  has_many :subscription_payment_cards, foreign_key: :billing_country_id
  has_many :users
  has_many :vat_codes

  # validation
  validates :name, presence: true, uniqueness: true
  validates :iso_code, presence: true
  validates :country_tld, presence: true
  validates :sorting_order, presence: true,
            numericality: {only_integer: true}
  validates :currency_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :continent, inclusion: {in: CONTINENTS}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_in_eu, -> { where(in_the_eu: true) }

  # class methods

  # instance methods
  def destroyable?
    self.corporate_customers.empty? && self.subscription_payment_cards.empty? && self.users.empty? && self.vat_codes.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
