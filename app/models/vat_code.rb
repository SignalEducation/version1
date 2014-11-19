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

  # attr-accessible
  attr_accessible :country_id, :name, :label, :wiki_url

  # Constants

  # relationships
  # to belongs_to :country
  has_many :vat_rates

  # validation
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :label, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:country_id) }

  # class methods

  # instance methods
  def destroyable?
    self.vat_rates.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
