class VatRate < ActiveRecord::Base

  # attr-accessible
  attr_accessible :vat_code_id, :percentage_rate, :effective_from

  # Constants

  # relationships
  belongs_to :vat_code

  # validation
  validates :vat_code_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :percentage_rate, presence: true
  validates :effective_from, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:vat_code_id) }

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
