class TutorApplication < ActiveRecord::Base

  # attr-accessible
  attr_accessible :first_name, :last_name, :email, :info, :description

  # Constants

  # relationships

  # validation
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :info, presence: true
  validates :description, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:first_name) }

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
