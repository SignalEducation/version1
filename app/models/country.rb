# == Schema Information
#
# Table name: countries
#
#  id            :integer          not null, primary key
#  name          :string
#  iso_code      :string
#  country_tld   :string
#  sorting_order :integer
#  in_the_eu     :boolean          default(FALSE), not null
#  currency_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  continent     :string
#

class Country < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :iso_code, :country_tld, :sorting_order,
                  :in_the_eu, :currency_id, :continent

  # Constants
  CONTINENTS = ['Europe', 'North America', 'Central America', 'South America', 'Asia', 'Africa','Australia', 'Antarctic']

  # relationships
  belongs_to :currency
  has_many :subscription_payment_cards, foreign_key: :account_country_id
  has_many :users
  has_many :vat_codes

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :iso_code, presence: true, length: {maximum: 255}
  validates :country_tld, presence: true, length: {maximum: 255}
  validates :sorting_order, presence: true
  validates :currency_id, presence: true
  validates :continent, inclusion: {in: CONTINENTS}, length: {maximum: 255}

  # callbacks
  before_validation { squish_fields(:name, :iso_code, :continent) }

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_in_eu, -> { where(in_the_eu: true) }

  # class methods

  # instance methods
  def destroyable?
    self.subscription_payment_cards.empty? && self.users.empty? && self.vat_codes.empty?
  end

  protected

end
