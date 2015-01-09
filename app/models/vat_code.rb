# == Schema Information
#
# Table name: vat_codes
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string(255)
#  label      :string(255)
#  wiki_url   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class VatCode < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :country_id, :name, :label, :wiki_url, :vat_rates_attributes

  # Constants

  # relationships
  belongs_to :country
  has_many :vat_rates, inverse_of: :vat_code

  accepts_nested_attributes_for :vat_rates

  # validation
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :label, presence: true

  # callbacks
  before_validation { squish_fields(:name, :label, :wiki_url) }

  # scopes
  scope :all_in_order, -> { order(:country_id, :name) }

  # class methods

  # instance methods
  def destroyable?
    self.vat_rates.empty?
  end

  protected

end
