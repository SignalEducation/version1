# == Schema Information
#
# Table name: countries
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  iso_code      :string(255)
#  country_tld   :string(255)
#  sorting_order :integer
#  in_the_eu     :boolean          default("false"), not null
#  currency_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  continent     :string(255)
#

class Country < ApplicationRecord
  include LearnSignalModelExtras

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
  def self.search(term)
    joins(:currency).
      where("countries.name ILIKE :t OR countries.iso_code ILIKE :t OR countries.continent ILIKE :t OR
             currencies.name ILIKE :t OR currencies.iso_code ILIKE :t", t: "%#{term}%")
  end

  ## Check if the Country can be deleted ##
  def destroyable?
    false
  end
end
