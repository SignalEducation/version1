class CourseModuleElement < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :description, :estimated_time_in_seconds, :course_module_id, :course_video_id, :course_quiz_id, :sorting_order, :forum_topic_id, :tutor_id, :related_quiz_id, :related_video_id

  # Constants

  # relationships
  belongs_to :course_module
  belongs_to :course_video
  belongs_to :course_quiz
  belongs_to :forum_topic
  belongs_to :tutor
  belongs_to :related_quiz
  belongs_to :related_video

  # validation
  validates :name, presence: true
  validates :name_url, presence: true
  validates :description, presence: true
  validates :estimated_time_in_seconds, presence: true
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_quiz_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true
  validates :forum_topic_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :related_quiz_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :related_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }

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
