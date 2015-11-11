class WhitePaper < ActiveRecord::Base

  # attr-accessible
  attr_accessible :title, :description

  # Constants

  # relationships

  # validation
  validates :title, presence: true
  validates :description, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:title) }

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
