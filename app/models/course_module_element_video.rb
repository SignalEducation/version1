class CourseModuleElementVideo < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :raw_video_file_id, :name, :run_time_in_seconds, :tutor_id, :description, :tags, :difficulty_level, :estimated_study_time_seconds, :transcript

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :raw_video_file
  belongs_to :tutor

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :raw_video_file_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :run_time_in_seconds, presence: true
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :description, presence: true
  validates :tags, presence: true
  validates :difficulty_level, presence: true
  validates :estimated_study_time_seconds, presence: true
  validates :transcript, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

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
