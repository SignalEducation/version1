# == Schema Information
#
# Table name: subject_course_user_logs
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  session_guid                    :string
#  subject_course_id               :integer
#  percentage_complete             :integer          default(0)
#  count_of_cmes_completed         :integer          default(0)
#  latest_course_module_element_id :integer
#  completed                       :boolean          default(FALSE)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  count_of_questions_correct      :integer
#  count_of_questions_taken        :integer
#  count_of_videos_taken           :integer
#  count_of_quizzes_taken          :integer
#  completed_at                    :datetime
#

class SubjectCourseUserLog < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :session_guid, :subject_course_id, :completed_at

  # Constants

  # relationships
  belongs_to :user
  belongs_to :subject_course
  belongs_to :latest_course_module_element, class_name: 'CourseModuleElement',
             foreign_key: :latest_course_module_element_id
  has_many :enrollments
  has_many :student_exam_tracks
  has_many :course_module_element_user_logs


  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, allow_nil: true, length: { maximum: 255 }

  # callbacks
  before_destroy :check_dependencies
  after_save :update_enrollment
  after_save :check_for_completion

  # scopes
  scope :all_in_order, -> { order(user_id: :asc, updated_at: :desc) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :for_subject_course, lambda { |course_id| where(subject_course_id: course_id) }


  # class methods

  # instance methods
  def destroyable?
    self.student_exam_tracks.empty?
  end

  def elements_total
    self.subject_course.try(:cme_count) || 0
  end

  def active_enrollment
    self.enrollments.where(active: true).last
  end

  def update_enrollment
    self.active_enrollment.touch if self.active_enrollment && !self.active_enrollment.expired
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
    self.count_of_cmes_completed = self.student_exam_tracks.with_active_cmes.sum(:count_of_cmes_completed)
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100
    self.count_of_questions_correct = self.student_exam_tracks.with_active_cmes.sum(:count_of_questions_correct)
    self.count_of_questions_taken = self.student_exam_tracks.with_active_cmes.sum(:count_of_questions_taken)
    self.count_of_videos_taken = self.student_exam_tracks.with_active_cmes.sum(:count_of_videos_taken)
    self.count_of_quizzes_taken = self.student_exam_tracks.with_active_cmes.sum(:count_of_quizzes_taken)
    unless self.percentage_complete.nil?
      self.completed = true if (self.percentage_complete > 99)
    end
    self.save
  end

  def student_exam_track_course_module_ids
    self.student_exam_tracks.map(&:course_module_id)
  end

  def old_sets
    StudentExamTrack.for_user(self.user_id).where(subject_course_id: self.subject_course_id)
  end

  def old_cmeuls
    CourseModuleElementUserLog.for_user(self.user_id).where(subject_course_id: self.subject_course_id)
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def check_for_completion
    unless Rails.env.test?
      if self.completed && !self.completed_at && self.subject_course.survey_url
        self.update_attribute(:completed_at, Proc.new{Time.now}.call)
        MandrillWorker.perform_async(self.user_id, 'send_survey_email', self.subject_course.survey_url)
      end
    end
  end

end
