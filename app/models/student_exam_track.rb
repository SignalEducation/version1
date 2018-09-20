# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  latest_course_module_element_id      :integer
#  exam_schedule_id                     :integer
#  created_at                           :datetime
#  updated_at                           :datetime
#  session_guid                         :string
#  course_module_id                     :integer
#  percentage_complete                  :float            default(0.0)
#  count_of_cmes_completed              :integer          default(0)
#  subject_course_id                    :integer
#  count_of_questions_taken             :integer
#  count_of_questions_correct           :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  subject_course_user_log_id           :integer
#  count_of_constructed_responses_taken :integer
#

#This should have been called CourseModuleUserLog
class StudentExamTrack < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :latest_course_module_element_id,
                  :session_guid, :course_module_id, :percentage_complete,
                  :count_of_cmes_completed, :subject_course_id,
                  :subject_course_user_log_id

  # Constants

  # relationships
  belongs_to :user
  belongs_to :subject_course
  belongs_to :subject_course_user_log
  belongs_to :course_module
  belongs_to :latest_course_module_element, class_name: 'CourseModuleElement',
             foreign_key: :latest_course_module_element_id
  has_many :course_module_element_user_logs

  # validation
  validates :session_guid, allow_nil: true, length: { maximum: 255 }
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_user_log_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  after_save :update_subject_course_user_log

  # scopes
  scope :all_in_order, -> { order(user_id: :asc, updated_at: :desc) }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :with_active_cmes, -> { includes(:course_module).where('course_modules.active = ?', true).where('course_modules.cme_count > 0').references(:course_module) }
  scope :with_valid_course_module, -> { includes(:course_module).where('course_modules.active = ?', true).where('course_modules.test = ?', false).where('course_modules.cme_count > 0').references(:course_module) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }

  # class methods

  # instance methods
  def update_subject_course_user_log
    log = self.subject_course_user_log
    log.latest_course_module_element_id = self.latest_course_module_element_id
    log.recalculate_completeness # Includes a save
  end

  def completed_cme_user_logs
    self.course_module_element_user_logs.with_elements_active.all_completed
  end

  def destroyable?
    self.course_module_element_user_logs.empty?
  end

  def elements_total
    self.course_module.cme_count
  end

  def elements_complete
    self.latest_cme_user_logs.all_completed.with_elements_active.count
  end

  def latest_cme_user_logs
    self.course_module_element_user_logs.latest_only
  end

  def unique_logs
    self.course_module_element_user_logs.all_completed.with_elements_active.map(&:course_module_element_id).uniq
  end

  def enrollment
    self.subject_course_user_log.active_enrollment
  end

  def calculate_completeness
    self.count_of_cmes_completed = self.unique_logs.count
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100
    self.save!
  end

  def worker_update_completeness
    #This can only be called from the SubjectCourseUserLogWorker to ensure the parent SCUL is not updated
    questions_taken = completed_cme_user_logs.sum(:count_of_questions_taken)
    questions_correct = completed_cme_user_logs.sum(:count_of_questions_correct)
    video_ids = completed_cme_user_logs.where(is_video: true).map(&:course_module_element_id)
    unique_video_ids = video_ids.uniq
    quiz_ids = completed_cme_user_logs.where(is_quiz: true).map(&:course_module_element_id)
    unique_quiz_ids = quiz_ids.uniq
    constructed_response_ids = completed_cme_user_logs.where(is_constructed_response: true).map(&:course_module_element_id)
    unique_constructed_response_ids = constructed_response_ids.uniq
    videos_taken = unique_video_ids.count
    quizzes_taken = unique_quiz_ids.count
    constructed_responses_taken = unique_constructed_response_ids.count
    cmes_completed = self.unique_logs.count
    percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100
    self.update_attributes(count_of_questions_taken: questions_taken, count_of_questions_correct: questions_correct, count_of_videos_taken: videos_taken, count_of_quizzes_taken: quizzes_taken, count_of_constructed_responses_taken: constructed_responses_taken, count_of_cmes_completed: cmes_completed, percentage_complete: percentage_complete)
    ## TODO See Sidekiq Github wiki FAQ may be race condition issue ##
  end

  def recalculate_completeness
    #This is the only way an SET can be created; and can only be called externally from CMEUL callback
    self.count_of_questions_taken = completed_cme_user_logs.sum(:count_of_questions_taken)
    self.count_of_questions_correct = completed_cme_user_logs.sum(:count_of_questions_correct)
    video_ids = completed_cme_user_logs.where(is_video: true).map(&:course_module_element_id)
    unique_video_ids = video_ids.uniq
    quiz_ids = completed_cme_user_logs.where(is_quiz: true).map(&:course_module_element_id)
    unique_quiz_ids = quiz_ids.uniq

    constructed_response_ids = completed_cme_user_logs.where(is_constructed_response: true).map(&:course_module_element_id)
    unique_constructed_response_ids = constructed_response_ids.uniq

    self.count_of_videos_taken = unique_video_ids.count
    self.count_of_quizzes_taken = unique_quiz_ids.count

    self.count_of_constructed_responses_taken = unique_constructed_response_ids.count

    self.count_of_cmes_completed = (unique_video_ids.count + unique_quiz_ids.count + unique_constructed_response_ids.count)
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100.0

    begin
      self.save!

    rescue Exception => e
      puts "SQL error in #{ __method__ }"
      ActiveRecord::Base.connection.execute 'ROLLBACK'

      raise e
    end
    self
  end

  def old_subject_course_user_log
    SubjectCourseUserLog.for_user(self.user_id).where(subject_course_id: self.subject_course_id).first
  end

  protected

end
