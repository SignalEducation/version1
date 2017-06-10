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
#  related_quiz_id           :integer
#  related_video_id          :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#  active                    :boolean          default(TRUE), not null
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
                  :related_quiz_id,
                  :related_video_id, :is_video, :is_quiz,
                  :course_module_element_video_attributes,
                  :course_module_element_quiz_attributes,
                  :course_module_element_resources_attributes,
                  :seo_description, :seo_no_index,
                  :number_of_questions, :video_resource_attributes,
                  :_destroy

  # Constants

  # relationships
  belongs_to :course_module
  has_one :course_module_element_quiz
  has_many :course_module_element_resources
  has_one :video_resource, inverse_of: :course_module_element
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

  accepts_nested_attributes_for :course_module_element_quiz
  accepts_nested_attributes_for :course_module_element_video
  accepts_nested_attributes_for :video_resource, reject_if: lambda { |attributes| nested_video_resource_is_blank?(attributes) }
  accepts_nested_attributes_for :course_module_element_resources, reject_if: lambda { |attributes| nested_resource_is_blank?(attributes) }, allow_destroy: true

  # validation
  validates :name, presence: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :course_module_id, presence: true
  validates :description, presence: true, if: :cme_is_video? #Description needs to be present because summernote editor will always populate the field with hidden html tags
  #validates :estimated_time_in_seconds, presence: true
  validates :sorting_order, presence: true
  validates_length_of :seo_description, maximum: 255, allow_blank: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :description) }
  before_validation :log_count_fields
  before_save :sanitize_name_url
  after_save :update_parent
  after_destroy :update_parent

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
    cmeuls = user_id ?
            self.course_module_element_user_logs.where(user_id: user_id) :
            self.course_module_element_user_logs.where(user_id: nil, session_guid: session_guid)
    array = cmeuls.all.map(&:element_completed)
    array.include? true
  end

  def started_by_user_or_guid(user_id, session_guid)
    cmeuls = user_id ?
            self.course_module_element_user_logs.where(user_id: user_id) :
            self.course_module_element_user_logs.where(user_id: nil, session_guid: session_guid)
    cmeuls.any?
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
    elsif self.course_module.course_module_jumbo_quiz && self.course_module.course_module_jumbo_quiz.active
      self.course_module.course_module_jumbo_quiz
    elsif self.my_position_among_siblings && (self.my_position_among_siblings == (self.array_of_sibling_ids.length - 1))
      if self.course_module.next_module && self.course_module.next_module.try(:course_module_elements).try(:all_active).any?
        #End of CourseModule continue on to first CME of next CourseModule
        next_id = self.course_module.next_module.try(:course_module_elements).try(:all_active).try(:all_in_order).try(:first).try(:id)
        if next_id
          CourseModuleElement.find(next_id)
        else
          CourseModule.where(id: self.course_module_id).first
        end
      else
        #End of Course redirect to Course library#live
        self.course_module
      end
    else
      CourseModule.where(id: self.course_module_id).first
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

  def type_name
    if is_quiz
      "Quiz"
    elsif is_video
      "Video"
    else
      "Unknown"
    end
  end

  def cme_is_video?
    self.is_video
  end

  protected

  def self.nested_resource_is_blank?(attributes)
    attributes['name'].blank? &&
    attributes['description'].blank? &&
    attributes['upload'].blank? &&
    attributes['the_url'].blank?
  end

  def self.nested_video_resource_is_blank?(attributes)
    attributes['question'].blank? &&
    attributes['name'].blank? &&
    attributes['notes'].blank?
  end

  def log_count_fields
    if self.is_video
      self.duration = self.course_module_element_video.try(:duration) unless Rails.env.test?
      self.estimated_time_in_seconds = self.course_module_element_video.duration.round if !Rails.env.test? && self.course_module_element_video.duration
    elsif self.is_quiz
        #Note: number_of_questions is the number selected in dropdown to be asked in the quiz, not the number of questions created for the quiz.
        self.number_of_questions = self.try(:course_module_element_quiz).try(:number_of_questions)
        self.estimated_time_in_seconds = (self.number_of_questions * 60) if self.estimated_time_in_seconds.nil?
    else
      true
    end
  end

  def update_parent
    self.course_module.try(:update_video_and_quiz_counts)
  end

end
