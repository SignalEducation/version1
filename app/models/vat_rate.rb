# == Schema Information
#
# Table name: vat_rates
#
#  id              :integer          not null, primary key
#  vat_code_id     :integer
#  percentage_rate :float
#  effective_from  :date
#  created_at      :datetime
#  updated_at      :datetime
#

class VatRate < ActiveRecord::Base

  # attr-accessible
  attr_accessible :vat_code_id, :percentage_rate, :effective_from

  # Constants

  # relationships
   belongs_to :vat_code, inverse_of: :vat_rates

  # validation
  validates :vat_code_id, presence: true,
            numericality: {only_integer: true, greater_than: 0},
            on: :update
  validates :percentage_rate, presence: true
  validates :effective_from, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:vat_code_id, :effective_from) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
