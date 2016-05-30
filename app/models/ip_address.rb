# == Schema Information
#
# Table name: ip_addresses
#
#  id          :integer          not null, primary key
#  ip_address  :string
#  latitude    :float
#  longitude   :float
#  country_id  :integer
#  alert_level :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class IpAddress < ActiveRecord::Base

  geocoded_by :ip_address
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.country_id = Country.find_by_iso_code(geo.country_code).try(:id) || 105
    else
      obj.country_id = 105 # Ireland
    end
  end

  # attr-accessible
  attr_accessible :ip_address, :country_id, :alert_level

  # Constants

  # relationships
  belongs_to :country
  has_many :user_activity_logs

  # validation
  validates :ip_address, presence: true, uniqueness: true, length: { maximum: 255 }
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
  def self.get_country(ip_address)
    IpAddress.where(ip_address: ip_address).first_or_create.country
  end

  # instance methods
  def destroyable?
    self.user_activity_logs.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def geo_locate
    unless Rails.env.test?
      self.geocode if self.ip_address
      self.reverse_geocode if self.ip_address
    end
    self.alert_level = 0
  end

end
