# frozen_string_literal: true

# == Schema Information
#
# Table name: ip_addresses
#
#  id           :integer          not null, primary key
#  ip_address   :string(255)
#  latitude     :float
#  longitude    :float
#  country_id   :integer
#  alert_level  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  rechecked_on :datetime
#

class IpAddress < ApplicationRecord
  geocoded_by :ip_address

  reverse_geocoded_by :latitude, :longitude do |obj, results|
    obj.assign_country_from_geo(results.first)
  end

  # relationships
  belongs_to :country

  # validation
  validates :ip_address, presence: true, uniqueness: true, length: { maximum: 255 }, case_sensitive: false
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :country_id, presence: true
  validates :alert_level, presence: true

  # callbacks
  before_validation :geo_locate, on: :create
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:ip_address) }

  # class methods
  def self.get_country(ip_address, country_required = false)
    country = where(ip_address: ip_address).first_or_create.country
    if !country && country_required
      Country.find_by(name: 'United Kingdom')
    else
      country
    end
  end

  # instance methods
  def assign_country_from_geo(result)
    self.country_id = if result
                        Country.find_by(iso_code: result.country_code)&.id || 78
                      else
                        78 # UK
                      end
  end

  def destroyable?
    true
  end

  private

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end

  def geo_locate
    self.alert_level = 0
    return if Rails.env.test? || !ip_address

    geocode
    reverse_geocode
  end
end
