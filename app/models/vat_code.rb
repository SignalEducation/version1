class VatCode < ActiveRecord::Base

  # attr-accessible
  attr_accessible :country_id, :name, :label, :wiki_url

  # Constants

  # relationships
  belongs_to :country

  # validation
  validates :country_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :label, presence: true
  validates :wiki_url, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:country_id) }

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
