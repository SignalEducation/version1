# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  latest_course_module_element_id :integer
#  exam_schedule_id                :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  session_guid                    :string
#  course_module_id                :integer
#  percentage_complete             :float            default(0.0)
#  count_of_cmes_completed         :integer          default(0)
#  subject_course_id               :integer
#  count_of_questions_taken        :integer
#  count_of_questions_correct      :integer
#  count_of_quizzes_taken          :integer
#  count_of_videos_taken           :integer
#  subject_course_user_log_id      :integer
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

  # validation
  validates :subject_course_id, presence: true
  validates :subject_course_user_log_id, allow_nil: true, numericality: {only_integer: true,
                                                                        greater_than: 0}
  validates :session_guid, presence: true, length: { maximum: 255 }
  validates :course_module_id, presence: true

  # callbacks
  after_save :create_or_update_subject_course_user_log

  # scopes
  scope :all_in_order, -> { order(user_id: :asc, updated_at: :desc) }
  scope :for_session_guid, lambda { |the_guid| where(session_guid: the_guid) }
  scope :for_unknown_users, -> { where(user_id: nil) }
  scope :with_active_cmes, -> { includes(:course_module).where('course_modules.active = ?', true).where('course_modules.cme_count > 0').references(:course_module) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }

  # class methods
  def self.assign_user_to_session_guid(the_user_id, the_session_guid)
    # activate this with the following:
    # StudentExamTrack.assign_user_to_session_guid(123, 'abcde123')
    StudentExamTrack.for_session_guid(the_session_guid).for_unknown_users.update_all(user_id: the_user_id)
    user_tracks = StudentExamTrack.for_user_or_session(the_user_id, the_session_guid)
    set_ids = user_tracks.map(&:course_module_id)
    duplicate_set_cm_ids = set_ids.select{ |e| set_ids.count(e) > 1 }.uniq
    duplicate_set_cm_ids.each do |duplicate_cm_id|
      # find the SETs for the user, for the CM-id
      duplicate_sets = StudentExamTrack.where(user_id: the_user_id, course_module_id: duplicate_cm_id).order(:updated_at)
      # build a new SET combining all of the data
      new_one = StudentExamTrack.new(
              user_id: the_user_id,
              session_guid: the_session_guid,
              subject_course_id: duplicate_sets.last.subject_course_id,
              latest_course_module_element_id: duplicate_sets.last.latest_course_module_element_id,
              course_module_id: duplicate_cm_id
      )
      new_one.calculate_completeness # includes a 'save'
      # delete the previous SETs
      duplicate_sets.destroy_all
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
  def create_or_update_subject_course_user_log
    log = self.subject_course_user_log || SubjectCourseUserLog.new(user_id: self.user_id, session_guid: self.session_guid, subject_course_id: self.subject_course_id)
    log.subject_course_id ||= self.try(:subject_course_id)
    log.latest_course_module_element_id = self.latest_course_module_element_id
    log.recalculate_completeness # Includes a save
  end

  def cme_user_logs
    CourseModuleElementUserLog.for_user_or_session(self.user_id, self.session_guid).where(course_module_id: self.course_module_id)
  end

  def completed_cme_user_logs
    cme_user_logs.all_completed.with_elements_active
  end

  def destroyable?
    self.cme_user_logs.empty?
  end

  def elements_total
    self.course_module.cme_count
  end

  def elements_complete
    self.latest_cme_user_logs.all_completed.with_elements_active.count
  end

  def latest_cme_user_logs
    self.cme_user_logs.latest_only
  end

  def unique_logs
    cme_user_logs.all_completed.with_elements_active.map(&:course_module_element_id).uniq
  end

  def calculate_completeness
    self.count_of_cmes_completed = self.unique_logs.count
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100
    self.save!
  end

  def worker_update_completeness
    #This can only be called from the StudentExamTrackWorker to ensure the parent SCUL is not updated
    questions_taken = completed_cme_user_logs.sum(:count_of_questions_taken)
    questions_correct = completed_cme_user_logs.sum(:count_of_questions_correct)
    video_ids = completed_cme_user_logs.where(is_video: true).map(&:course_module_element_id)
    unique_video_ids = video_ids.uniq
    quiz_ids = completed_cme_user_logs.where(is_quiz: true).map(&:course_module_element_id)
    unique_quiz_ids = quiz_ids.uniq
    videos_taken = unique_video_ids.count
    quizzes_taken = unique_quiz_ids.count
    cmes_completed = self.unique_logs.count
    percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100
    self.update_attributes(count_of_questions_taken: questions_taken, count_of_questions_correct: questions_correct, count_of_videos_taken: videos_taken, count_of_quizzes_taken: quizzes_taken, count_of_cmes_completed: cmes_completed, percentage_complete: percentage_complete)
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
    self.count_of_videos_taken = unique_video_ids.count
    self.count_of_quizzes_taken = unique_quiz_ids.count
    self.count_of_cmes_completed = (unique_video_ids.count + unique_quiz_ids.count)
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100.0

    begin
      self.save!

    rescue Exception => e
      puts "SQL error in #{ __method__ }"
      ActiveRecord::Base.connection.execute 'ROLLBACK'

      raise e
    end
    ## TODO See Sidekiq Github wiki FAQ may be race condition issue ##
  end

  def subject_course_user_log
    SubjectCourseUserLog.for_user_or_session(self.user_id, self.session_guid).where(subject_course_id: self.subject_course_id).first
  end

  protected

end
