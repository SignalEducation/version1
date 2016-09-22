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
#

class SubjectCourseUserLog < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :session_guid, :subject_course_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :subject_course
  belongs_to :latest_course_module_element, class_name: 'CourseModuleElement',
             foreign_key: :latest_course_module_element_id
  has_many :completion_certificates
  has_one :enrollment


  # validation
  validates :user_id, presence: true
  validates :session_guid, presence: true, length: { maximum: 255 }
  validates :subject_course_id, presence: true

  # callbacks
  before_destroy :check_dependencies
  after_create :start_course_intercom_event if Rails.env.production? || Rails.env.staging?

  # scopes
  scope :all_in_order, -> { order(user_id: :asc, updated_at: :desc) }
  scope :for_session_guid, lambda { |the_guid| where(session_guid: the_guid) }
  scope :for_unknown_users, -> { where(user_id: nil) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }


  # class methods
  def self.assign_user_to_session_guid(the_user_id, the_session_guid)
    # activate this with the following:
    # SubjectCourseUserLog.assign_user_to_session_guid(123, 'abcde123')
    SubjectCourseUserLog.for_session_guid(the_session_guid).for_unknown_users.update_all(user_id: the_user_id)
    user_logs = SubjectCourseUserLog.for_user_or_session(the_user_id, the_session_guid)
    log_ids = user_logs.map(&:subject_course_id)
    duplicate_log_sc_ids = log_ids.select{ |e| log_ids.count(e) > 1 }.uniq
    duplicate_log_sc_ids.each do |duplicate_sc_id|
      # find the SCUL's for the user, for the SC_id
      duplicate_logs = SubjectCourseUserLog.where(user_id: the_user_id, subject_course_id: duplicate_sc_id).order(:updated_at)
      # build a new SET combining all of the data
      new_one = SubjectCourseUserLog.new(
          user_id: the_user_id,
          session_guid: the_session_guid,
          latest_course_module_element_id: duplicate_logs.last.latest_course_module_element_id,
          subject_course_id: duplicate_sc_id,
      )
      new_one.recalculate_completeness # includes a 'save'
      # delete the previous SETs
      duplicate_logs.destroy_all
    end
    return true
  end

  def self.for_user_or_session(the_user_id, the_session_guid)
    if the_user_id
      where(user_id: the_user_id)
    else
      where(session_guid: the_session_guid, user_id: nil)
    end
  end

  # instance methods
  def destroyable?
    self.student_exam_tracks.empty?
  end

  def elements_total
    self.subject_course.try(:cme_count) || 0
  end

  def last_element
    CourseModuleElement.find(self.latest_course_module_element_id)
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
      self.completed = false if (self.percentage_complete < 100)
    end
    self.save
  end

  def student_exam_tracks
    StudentExamTrack.for_user_or_session(self.user_id, self.session_guid).where(subject_course_id: self.subject_course_id)
  end

  def start_course_intercom_event
    IntercomCourseStartedEventWorker.perform_async(self.try(:user_id), self.subject_course.name)
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
