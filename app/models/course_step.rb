# frozen_string_literal: true

# == Schema Information
#
# Table name: course_steps
#
#  id                        :integer          not null, primary key
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  estimated_time_in_seconds :integer
#  course_lesson_id          :integer
#  sorting_order             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default("false"), not null
#  is_quiz                   :boolean          default("false"), not null
#  active                    :boolean          default("true"), not null
#  destroyed_at              :datetime
#  seo_description           :string
#  seo_no_index              :boolean          default("false")
#  number_of_questions       :integer          default("0")
#  duration                  :float            default("0.0")
#  temporary_label           :string
#  is_constructed_response   :boolean          default("false"), not null
#  available_on_trial        :boolean          default("false")
#  related_course_step_id    :integer
#  is_note                   :boolean          default("false")
#  vid_end_seconds           :integer
#  is_practice_question      :boolean
#

class CourseStep < ApplicationRecord
  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :course_lesson
  belongs_to :related_course_step, class_name: 'CourseStep',
             foreign_key: :related_course_step_id, optional: true
  has_one :course_quiz
  has_one :course_video
  has_one :course_note
  has_one :course_practice_question
  has_one :constructed_response
  has_one :video_resource, inverse_of: :course_step
  has_many :course_resources
  has_many :quiz_questions
  has_many :course_step_logs
  has_many :course_lesson_logs, class_name: 'CourseLessonLog',
           foreign_key: :latest_course_step_id

  delegate :course, to: :course_lesson, allow_nil: true

  accepts_nested_attributes_for :course_quiz
  accepts_nested_attributes_for :course_video
  accepts_nested_attributes_for :course_practice_question
  accepts_nested_attributes_for :constructed_response
  accepts_nested_attributes_for :video_resource, reject_if: ->(attributes) { nested_video_resource_is_blank?(attributes) }
  accepts_nested_attributes_for :course_note, reject_if: ->(attributes) { nested_resource_is_blank?(attributes) }, allow_destroy: true

  # validation
  validates :course_lesson, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :name_url, presence: true, uniqueness: { scope: :course_lesson_id,
                                                     message: 'must be unique within the course module' }
  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :description) }
  before_save :sanitize_name_url, :log_count_fields
  after_save :update_parent

  # scopes
  scope :all_in_order,             -> { order(:sorting_order, :name).where(destroyed_at: nil) }
  scope :all_active,               -> { where(active: true, destroyed_at: nil) }
  scope :all_videos,               -> { where(is_video: true) }
  scope :all_quizzes,              -> { where(is_quiz: true) }
  scope :all_notes,                -> { where(is_note: true) }
  scope :all_constructed_response, -> { where(is_constructed_response: true) }

  # class methods

  # instance methods

  ## Parent & Child associations ##

  def parent
    course_lesson
  end

  #######################################################################

  ## Methods allow for navigation from one CME to the next #

  def array_of_sibling_ids
    course_lesson.course_steps.all_active.all_in_order.map(&:id)
  end

  def my_position_among_siblings
    array_of_sibling_ids.index(id)
  end

  def with_active_parents?
    course_lesson.active && course_lesson.course_section.active
  end

  def next_element
    return unless active && with_active_parents? && my_position_among_siblings

    return unless my_position_among_siblings < (array_of_sibling_ids.length - 1)

    # Find the next CME in the current CM
    CourseStep.find(array_of_sibling_ids[my_position_among_siblings + 1])
  end

  def previous_element
    return if !course_lesson.previous_module_id && my_position_among_siblings.zero?

    evaluate_previous_element(my_position_among_siblings, course_lesson, array_of_sibling_ids)
  end

  #######################################################################

  ## Archivable ability ##

  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list << course_video if course_video
    the_list << course_quiz if course_quiz
    the_list << course_note if course_note
    the_list << constructed_response if constructed_response
    the_list += quiz_questions.to_a
    the_list
  end

  #######################################################################

  ## User Course Tracking ##

  def completed_by_user(user_id)
    cmeuls = course_step_logs.where(user_id: user_id)
    array = cmeuls.all.map(&:element_completed)
    array.include? true
  end

  def started_by_user(user_id)
    cmeuls = course_step_logs.where(user_id: user_id)
    cmeuls.any?
  end

  def previous_cme_restriction(scul)
    if related_course_step&.active
      if scul
        course_lesson_log = scul.course_lesson_logs.for_course_lesson(course_lesson_id).last
        if course_lesson_log
          !course_lesson_log.completed_course_step_logs.map(&:course_step_id).include?(related_course_step_id)
        else
          true
        end
      else
        true
      end
    else
      false
    end
  end

  def available_for_complimentary(scul = nil)
    if related_course_step_id && previous_cme_restriction(scul)
      { view: false, reason: 'related-lesson-restriction' }
    else
      { view: true, reason: nil }
    end
  end

  def available_to_user(user, valid_subscription, scul = nil)
    previous_restriction = previous_cme_restriction(scul)

    result =
      if user.show_verify_email_message? && !user.valid_subscription?
        { view: false, reason: 'verification-required' }
      elsif user.verify_remain_days.zero? && !user.valid_subscription? && !user.email_verified
        { view: false, reason: 'verification-required' }
      elsif user.complimentary_user? || user.non_student_user? || user.lifetime_subscriber?(course.group) || user.program_access?(course.group)
        available_for_complimentary(scul)
      elsif user.program_access?(course.id)
        available_for_complimentary(scul)
      elsif user.standard_student_user?
        if valid_subscription
          if related_course_step && previous_restriction
            { view: false, reason: 'related-lesson-restriction' }
          else
            { view: true, reason: nil }
          end
        elsif (course_lesson.free || available_on_trial) && related_course_step && previous_restriction
          { view: false, reason: 'related-lesson-restriction' }
        else
          (course_lesson.free || available_on_trial) ? { view: true, reason: nil } : { view: false, reason: 'invalid-subscription' }
        end
      else
        { view: false, reason: nil }
      end

    result

    # Return true/false and reason
    # false will display lock icon
    # reason will populate modal
  end

  ########################################################################

  ## Model info for Views ##

  def type_name
    if is_quiz
      'Quiz'
    elsif is_video
      'Video'
    elsif is_note
      'Notes'
    elsif is_practice_question
      'Practice Questions'
    elsif is_constructed_response
      'Constructed Response'
    else
      'Unknown'
    end
  end

  def icon_label
    if is_video
      'smart_display'
    elsif is_quiz
      'quiz'
    elsif is_note
      'file_present'
    elsif is_practice_question
      'grid_on'
    elsif is_constructed_response
      'grid_on'
    else
      'checked'
    end
  end

  def cme_is_video?
    is_video
  end

  def self.nested_resource_is_blank?(attributes)
    attributes['name'].blank? &&
      attributes['description'].blank? &&
      attributes['upload'].blank? &&
      attributes['the_url'].blank?
  end

  def self.nested_video_resource_is_blank?(attributes)
    attributes['question'].blank? && attributes['name'].blank? && attributes['notes'].blank?
  end

  private

  def log_count_fields
    if is_video && course_video
      self.duration = course_video.duration
      self.estimated_time_in_seconds = duration.round if duration
    elsif is_constructed_response
      self.estimated_time_in_seconds = 900
    elsif is_quiz && course_quiz
      # Note: number_of_questions is the number selected in dropdown to be asked in the quiz, not the number of questions created for the quiz.
      self.number_of_questions = try(:course_quiz).try(:number_of_questions)
      # Note: It no value is set in the form for estimated_time_in_seconds set it to 60 seconds for each question asked
      self.estimated_time_in_seconds = (number_of_questions * 60) if estimated_time_in_seconds.nil?
    else
      true
    end
  end

  def update_parent
    course_lesson.try(:update_video_and_quiz_counts)
  end

  def evaluate_previous_element(prev_index, course_lesson, array_of_sibling_ids)
    if prev_index&.zero?
      course_lesson.previous_module.last_active_cme
    elsif prev_index&.positive?
      CourseStep.find(array_of_sibling_ids[prev_index - 1])
    end
  end
end
