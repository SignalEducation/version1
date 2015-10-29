# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
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
#  active                    :boolean          default(TRUE), not null
#  is_cme_flash_card_pack    :boolean          default(FALSE), not null
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  duration                  :float            default(0.0)
#

class CourseModuleElement < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :name, :name_url, :description,
                  :estimated_time_in_seconds, :active,
                  :course_module_id, :sorting_order,
                  :tutor_id, :related_quiz_id,
                  :related_video_id, :is_video, :is_quiz,
                  :course_module_element_video_attributes,
                  :course_module_element_quiz_attributes,
                  :course_module_element_resources_attributes,
                  :seo_description, :seo_no_index,
                  :course_module_element_flash_card_pack_attributes,
                  :is_cme_flash_card_pack, :number_of_questions

  # Constants

  # relationships
  belongs_to :course_module
  has_one :course_module_element_flash_card_pack
  has_one :course_module_element_quiz
  has_many :course_module_element_resources
  has_many :course_module_element_user_logs
  has_one :course_module_element_video
  has_many :quiz_answers, foreign_key: :wrong_answer_video_id
  has_many :quiz_questions
  belongs_to :related_quiz, class_name: 'CourseModuleElement',
             foreign_key: :related_quiz_id
  belongs_to :related_video, class_name: 'CourseModuleElement',
             foreign_key: :related_video_id
  has_many :student_exam_tracks, class_name: 'StudentExamTrack',
           foreign_key: :latest_course_module_element_id
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id

  accepts_nested_attributes_for :course_module_element_flash_card_pack
  accepts_nested_attributes_for :course_module_element_quiz
  accepts_nested_attributes_for :course_module_element_video, update_only: true
  accepts_nested_attributes_for :course_module_element_resources, reject_if: lambda { |attributes| nested_resource_is_blank?(attributes) }

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :estimated_time_in_seconds, allow_nil: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :related_quiz_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :related_video_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates_length_of :seo_description, maximum: 255, allow_blank: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :description) }
  before_save :sanitize_name_url
  before_save :log_question_count_and_duration
  after_create :update_parent
  after_update :update_parent
  after_save :update_student_exam_tracks

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name).where(destroyed_at: nil) }
  scope :all_active, -> { where(active: true, destroyed_at: nil) }
  scope :all_videos, -> { where(is_video: true) }
  scope :all_quizzes, -> { where(is_quiz: true) }

  # class methods

  # instance methods
  def array_of_sibling_ids
    self.course_module.course_module_elements.all_active.all_in_order.map(&:id)
  end

  def completed_by_user_or_guid(user_id, session_guid)
    cmeul = user_id ?
            self.course_module_element_user_logs.where(user_id: user_id).latest_only.first :
            self.course_module_element_user_logs.where(user_id: nil, session_guid: session_guid).latest_only.first
    cmeul.try(:element_completed)
  end

  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list << self.course_module_element_video if self.course_module_element_video
    the_list << self.course_module_element_quiz if self.course_module_element_quiz
    the_list += self.course_module_element_resources.to_a
    the_list += self.quiz_answers.to_a
    the_list += self.quiz_questions.to_a
    the_list
  end

  def my_position_among_siblings
    self.array_of_sibling_ids.index(self.id)
  end

  def next_element
    if self.my_position_among_siblings && (self.my_position_among_siblings < (self.array_of_sibling_ids.length - 1))
      CourseModuleElement.find(self.array_of_sibling_ids[self.my_position_among_siblings + 1])
    elsif self.course_module.course_module_jumbo_quiz
      self.course_module.course_module_jumbo_quiz
    elsif self.my_position_among_siblings && (self.my_position_among_siblings == (self.array_of_sibling_ids.length - 1))
      CourseModuleElement.find(self.course_module.parent.first_active_cme)
    else
      next_id = self.course_module.next_module.try(:course_module_elements).try(:all_active).try(:all_in_order).try(:first).try(:id)
      CourseModuleElement.find(next_id) if next_id
    end
  end

  def parent
    self.course_module
  end

  def previous_element
    if self.my_position_among_siblings && self.my_position_among_siblings > 0
      CourseModuleElement.find(self.array_of_sibling_ids[self.my_position_among_siblings - 1])
    elsif self.course_module.previous_module.try(:course_module_jumbo_quiz)
      self.course_module.previous_module.course_module_jumbo_quiz
    else
      prev_id = self.course_module.previous_module.try(:course_module_elements).try(:all_active).try(:all_in_order).try(:last).try(:id)
      CourseModuleElement.find(prev_id) if prev_id
    end
  end

  def update_student_exam_tracks
    #sets = StudentExamTrack.where(course_module_id: self.course_module_id)
    #sets.all.each do |set|
    #  set.recalculate_completeness
    #end
    StudentExamTracksWorker.perform_async(self.course_module_id)
  end

  def type_name
    if is_quiz
      "Quiz"
    elsif is_video
      "Video"
    else
      "Unknown"
    end
  end

  protected

  def self.nested_resource_is_blank?(attributes)
    attributes['name'].blank? &&
    attributes['description'].blank? &&
    attributes['upload'].blank? &&
    attributes['the_url'].blank?
  end

  def log_question_count_and_duration
    if self.is_video
      self.duration = self.course_module_element_video.try(:duration)
    elsif self.is_quiz
        self.number_of_questions = self.try(:course_module_element_quiz).try(:number_of_questions)
    else
      true
    end
  end

  def update_parent
    if self.is_video
      self.course_module.try(:recalculate_video_fields)
    elsif self.is_quiz
      self.course_module.try(:recalculate_quiz_fields)
    else
      true
    end
  end

end
