# == Schema Information
#
# Table name: course_module_elements
#
#  id                               :integer          not null, primary key
#  name                             :string
#  name_url                         :string
#  description                      :text
#  estimated_time_in_seconds        :integer
#  course_module_id                 :integer
#  sorting_order                    :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  is_video                         :boolean          default(FALSE), not null
#  is_quiz                          :boolean          default(FALSE), not null
#  active                           :boolean          default(TRUE), not null
#  seo_description                  :string
#  seo_no_index                     :boolean          default(FALSE)
#  destroyed_at                     :datetime
#  number_of_questions              :integer          default(0)
#  duration                         :float            default(0.0)
#  temporary_label                  :string
#  is_constructed_response          :boolean          default(FALSE), not null
#  available_on_trial               :boolean          default(FALSE)
#  related_course_module_element_id :integer
#

class CourseModuleElement < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :course_module
  belongs_to :related_course_module_element, class_name: 'CourseModuleElement',
             foreign_key: :related_course_module_element_id, optional: true
  has_one :course_module_element_quiz
  has_one :course_module_element_video
  has_one :constructed_response
  has_one :video_resource, inverse_of: :course_module_element
  has_many :quiz_questions
  has_many :course_module_element_resources
  has_many :course_module_element_user_logs
  has_many :student_exam_tracks, class_name: 'StudentExamTrack',
           foreign_key: :latest_course_module_element_id

  accepts_nested_attributes_for :course_module_element_quiz
  accepts_nested_attributes_for :course_module_element_video
  accepts_nested_attributes_for :constructed_response
  accepts_nested_attributes_for :video_resource,
                                reject_if: lambda { |attributes| nested_video_resource_is_blank?(attributes) }
  accepts_nested_attributes_for :course_module_element_resources,
                                reject_if: lambda { |attributes| nested_resource_is_blank?(attributes) }, allow_destroy: true

  # validation
  validates :course_module_id, presence: true
  validates :name, presence: true, length: {maximum: 255}
  validates :name_url, uniqueness: { scope: :course_module,
                                     message: "must be unique within the course module" }
  validates :description, presence: true, if: :cme_is_video?
  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :description) }
  before_save :sanitize_name_url, :log_count_fields
  after_save :update_parent

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :name).where(destroyed_at: nil) }
  scope :all_active, -> { where(active: true, destroyed_at: nil) }
  scope :all_videos, -> { where(is_video: true) }
  scope :all_quizzes, -> { where(is_quiz: true) }
  scope :all_constructed_response, -> { where(is_constructed_response: true) }

  # class methods

  # instance methods

  ## Parent & Child associations ##

  def parent
    self.course_module
  end


  #######################################################################

  ## Methods allow for navigation from one CME to the next #


  def array_of_sibling_ids
    self.course_module.course_module_elements.all_active.all_in_order.map(&:id)
  end

  def my_position_among_siblings
    self.array_of_sibling_ids.index(self.id)
  end

  def with_active_parents?
    course_module.active && course_module.course_section.active
  end

  def next_element
    #TODO - need to factor in whether the next element is available to the student [trial or restricted]
    # And if the next element is active

    if self.active && self.with_active_parents? && self.my_position_among_siblings
      if self.my_position_among_siblings < (self.array_of_sibling_ids.length - 1)
        # Find the next CME in the current CM
        CourseModuleElement.find(self.array_of_sibling_ids[self.my_position_among_siblings + 1])
      elsif self.my_position_among_siblings == (self.array_of_sibling_ids.length - 1) && (self.course_module.next_module && self.course_module.next_module.active_children.any?)
        # There is no next CME in current CM - find first CME in next CM
        course_module.next_module.first_active_cme
      else
        # There is no next CM in current CS - return the CourseSection
        course_module.course_section
      end
    else
      course_module.course_section.subject_course
    end
  end

  def previous_element
    if self.my_position_among_siblings && self.my_position_among_siblings > 0
      CourseModuleElement.find(self.array_of_sibling_ids[self.my_position_among_siblings - 1])
    else
      prev_id = self.course_module.previous_module.try(:course_module_elements).try(:all_active).try(:all_in_order).try(:last).try(:id)
      CourseModuleElement.find(prev_id) if prev_id
    end
  end


  #######################################################################

  ## Archivable ability ##

  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list << self.course_module_element_video if self.course_module_element_video
    the_list << self.course_module_element_quiz if self.course_module_element_quiz
    the_list << self.constructed_response if self.constructed_response
    the_list += self.course_module_element_resources.to_a
    the_list += self.quiz_questions.to_a
    the_list
  end


  #######################################################################

  ## User Course Tracking ##

  def completed_by_user(user_id)
    cmeuls = self.course_module_element_user_logs.where(user_id: user_id)
    array = cmeuls.all.map(&:element_completed)
    array.include? true
  end

  def started_by_user(user_id)
    cmeuls = self.course_module_element_user_logs.where(user_id: user_id)
    cmeuls.any?
  end

  def previous_cme_restriction(scul)

    if self.related_course_module_element_id

      if scul
        student_exam_track = scul.student_exam_tracks.for_course_module(self.course_module_id).last
        if student_exam_track
          !student_exam_track.completed_cme_user_logs.map(&:course_module_element_id).include?(self.related_course_module_element_id)
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

  def available_for_trial(scul=nil)
    if self.related_course_module_element_id && self.previous_cme_restriction(scul)
      {view: false, reason: 'related-lesson-restriction'}
    else
      self.available_on_trial ? {view: true, reason: nil} : {view: false, reason: 'trial-restriction'}

    end
  end

  def available_for_subscription(user, scul=nil)
    if self.related_course_module_element_id && self.previous_cme_restriction(scul)
      {view: false, reason: 'related-lesson-restriction'}
    else
      if user.valid_subscription?
        {view: true, reason: nil}
      else
        self.available_on_trial ? {view: true, reason: nil} : {view: false, reason: 'invalid-subscription'}
      end
    end
  end

  def available_for_complimentary(scul=nil)
    if self.related_course_module_element_id && self.previous_cme_restriction(scul)
      {view: false, reason: 'related-lesson-restriction'}
    else
      {view: true, reason: nil}
    end
  end

  def available_to_user(user, scul)
    result = {view: false, reason: nil}


    case user.account_type

    when 'Trial'
      result = available_for_trial(scul)
    when 'Subscription'
      result = available_for_subscription(user, scul)
    when 'Complimentary'
      result = available_for_complimentary(scul)
    else
      result[:reason] = 'account-issue'
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
    elsif constructed_response
      'Constructed Response'
    else
      'Unknown'
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
    if self.is_video && course_module_element_video
      self.duration = self.course_module_element_video.duration
      self.estimated_time_in_seconds = self.duration.round if self.duration
    elsif self.is_constructed_response
      self.estimated_time_in_seconds = 900
    elsif self.is_quiz && course_module_element_quiz
      #Note: number_of_questions is the number selected in dropdown to be asked in the quiz, not the number of questions created for the quiz.
      self.number_of_questions = self.try(:course_module_element_quiz).try(:number_of_questions)
      #Note: It no value is set in the form for estimated_time_in_seconds set it to 60 seconds for each question asked
      self.estimated_time_in_seconds = (self.number_of_questions * 60) if self.estimated_time_in_seconds.nil?
    else
      true
    end
  end

  def update_parent
    self.course_module.try(:update_video_and_quiz_counts)
  end

end
