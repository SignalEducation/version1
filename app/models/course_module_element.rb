# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  forum_topic_id            :integer
#  tutor_id                  :integer
#  related_quiz_id           :integer
#  related_video_id          :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#

class CourseModuleElement < ActiveRecord::Base

  # attr-accessible
  attr_accessible :name, :name_url, :description, :estimated_time_in_seconds,
                  :course_module_id, :sorting_order,
                  :forum_topic_id, :tutor_id, :related_quiz_id,
                  :related_video_id, :is_video, :is_quiz,
                  :course_module_element_video_attributes,
                  :course_module_element_quiz_attributes

  # Constants

  # relationships
  belongs_to :course_module
  has_one :course_module_element_video
  has_one :course_module_element_quiz
  has_many :course_module_element_resources
  has_many :course_module_element_user_logs
  belongs_to :forum_topic
  has_many :quiz_answers, foreign_key: :wrong_answer_video_id
  has_many :quiz_questions
  belongs_to :related_quiz, class_name: 'CourseModuleElement',
             foreign_key: :related_quiz_id
  belongs_to :related_video, class_name: 'CourseModuleElement',
             foreign_key: :related_video_id
  has_many :student_exam_tracks, class_name: 'StudentExamTrack',
           foreign_key: :latest_course_module_element_id
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id

  accepts_nested_attributes_for :course_module_element_quiz
  accepts_nested_attributes_for :course_module_element_video, update_only: true

  # validation
  validates :name, presence: true, uniqueness: true
  validates :name_url, presence: true, uniqueness: true
  validates :description, presence: true
  validates :estimated_time_in_seconds, presence: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :forum_topic_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :related_quiz_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :related_video_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  after_save :update_the_module_total_time
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :all_videos, -> { where(is_video: true) }
  scope :all_quizzes, -> { where(is_quiz: true) }

  # class methods

  # instance methods
  def destroyable?
    self.course_module_element_resources.empty? && self.course_module_element_user_logs.empty? && self.quiz_answers.empty? && self.quiz_questions.empty? && self.student_exam_tracks.empty?
  end

  def update_the_module_total_time
    self.course_module.try(:recalculate_estimated_time)
  end

  def array_of_sibling_ids
    self.course_module.course_module_elements.all_in_order.map(&:id)
  end

  def my_position_among_siblings
    self.array_of_sibling_ids.index(self.id)
  end

  def previous_element_id
    if self.my_position_among_siblings > 0
      self.array_of_sibling_ids[self.my_position_among_siblings - 1]
    else
      nil
    end
  end

  def next_element_id
    if self.my_position_among_siblings < (self.array_of_sibling_ids.length - 1)
      self.array_of_sibling_ids[self.my_position_among_siblings + 1]
    else
      nil
    end
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
