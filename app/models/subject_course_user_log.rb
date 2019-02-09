# == Schema Information
#
# Table name: subject_course_user_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  session_guid                         :string
#  subject_course_id                    :integer
#  percentage_complete                  :integer          default(0)
#  count_of_cmes_completed              :integer          default(0)
#  latest_course_module_element_id      :integer
#  completed                            :boolean          default(FALSE)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  count_of_questions_correct           :integer
#  count_of_questions_taken             :integer
#  count_of_videos_taken                :integer
#  count_of_quizzes_taken               :integer
#  completed_at                         :datetime
#  count_of_constructed_responses_taken :integer
#

class SubjectCourseUserLog < ActiveRecord::Base

  # Constants

  # relationships
  belongs_to :user
  belongs_to :subject_course
  belongs_to :latest_course_module_element, class_name: 'CourseModuleElement',
             foreign_key: :latest_course_module_element_id
  has_many :enrollments
  has_many :course_section_user_logs
  has_many :student_exam_tracks
  has_many :course_module_element_user_logs


  # validation
  validates :user_id, presence: true
  validates :subject_course_id, presence: true
  validates :percentage_complete, presence: true

  # callbacks
  before_destroy :check_dependencies
  after_save :update_enrollment

  # scopes
  scope :all_in_order, -> { order(:user_id, :created_at) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :for_subject_course, lambda { |course_id| where(subject_course_id: course_id) }


  # class methods

  # instance methods
  def destroyable?
    self.course_section_user_logs.empty? && self.student_exam_tracks.empty?
  end

  def elements_total
    self.subject_course.try(:cme_count) || 0
  end

  def elements_total_for_completion
    self.subject_course.course_sections.all_for_completion.sum(:cme_count)
  end

  def active_enrollment
    self.enrollments.where(active: true).last
  end

  def update_enrollment
    if self.active_enrollment && !self.active_enrollment.expired
      self.active_enrollment.update_attribute(:percentage_complete, self.percentage_complete)
      self.update_attribute(:completed_at, Proc.new{Time.now}.call) if self.completed && !self.completed_at
    end
  end

  def last_element
    ###
    ###
    ###
    cme = CourseModuleElement.where(id: self.latest_course_module_element_id).first
    back_up_cme = self.subject_course.first_active_cme
    if cme
      return cme
    else
      return back_up_cme
    end
  end

  def recalculate_completeness
    self.count_of_videos_taken = self.course_section_user_logs.with_valid_course_section.sum(:count_of_videos_taken)
    self.count_of_quizzes_taken = self.course_section_user_logs.with_valid_course_section.sum(:count_of_quizzes_taken)
    self.count_of_constructed_responses_taken = self.course_section_user_logs.with_valid_course_section.sum(:count_of_constructed_responses_taken)
    self.count_of_cmes_completed = self.course_section_user_logs.with_valid_course_section.sum(:count_of_cmes_completed)

    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total_for_completion.to_f) * 100 if self.elements_total_for_completion > 0

    self.completed = true if (self.percentage_complete > 99) unless self.percentage_complete.nil?
    self.save!
  end

  def student_exam_track_course_module_ids
    self.student_exam_tracks.map(&:course_module_id)
  end


  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end


end
