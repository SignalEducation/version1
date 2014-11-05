class ExamSection < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :exam_level_id, :active, :sorting_order, :best_possible_first_attempt_score

  # Constants

  # relationships
  belongs_to :exam_level

  # validation
  validates :name, presence: true
  validates :name_url, presence: true
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true
  validates :best_possible_first_attempt_score, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, name) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
