# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  exam_level_id                   :integer
#  exam_section_id                 :integer
#  latest_course_module_element_id :integer
#  exam_schedule_id                :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  session_guid                    :string(255)
#  course_module_id                :integer
#  jumbo_quiz_taken                :boolean          default(FALSE)
#  percentage_complete             :float            default(0.0)
#  count_of_cmes_completed         :integer          default(0)
#

class StudentExamTrack < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :exam_level_id, :exam_section_id,
                  :latest_course_module_element_id, :exam_schedule_id,
                  :session_guid, :course_module_id, :jumbo_quiz_taken,
                  :percentage_complete, :count_of_cmes_completed

  # Constants

  # relationships
  belongs_to :user
  belongs_to :exam_level
  belongs_to :exam_section
  belongs_to :course_module
  belongs_to :latest_course_module_element, class_name: 'CourseModuleElement',
             foreign_key: :latest_course_module_element_id
  # todo belongs_to :exam_schedule

  # validation
  validates :user_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_section_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :latest_course_module_element_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_schedule_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, presence: true
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  after_save :send_cm_complete_to_mixpanel

  # scopes
  scope :all_in_order, -> { order(user_id: :asc, updated_at: :desc) }
  scope :for_session_guid, lambda { |the_guid| where(session_guid: the_guid) }
  scope :for_unknown_users, -> { where(user_id: nil) }
  scope :with_active_cmes, -> { includes(:course_module).where('course_modules.cme_count > 0').references(:course_module) }

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
              exam_level_id: duplicate_sets.last.exam_level_id,
              exam_section_id: duplicate_sets.last.exam_section_id,
              latest_course_module_element_id: duplicate_sets.last.latest_course_module_element_id,
              exam_schedule_id: duplicate_sets.last.exam_schedule_id,
              course_module_id: duplicate_cm_id,
              jumbo_quiz_taken: duplicate_sets.map(&:jumbo_quiz_taken).any?,
      )
      new_one.recalculate_completeness # includes a 'save'
      # delete the previous SETs
      duplicate_sets.destroy_all
    end
    # put on a happy face
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
  def cme_user_logs
    CourseModuleElementUserLog.for_user_or_session(self.user_id, self.session_guid).where(course_module_id: self.course_module_id)
  end

  def destroyable?
    true
  end

  def elements_total
    self.course_module.cme_count
  end

  def elements_complete
    self.latest_cme_user_logs.latest_only.all_completed.with_elements_active.count + (self.jumbo_quiz_taken ? 1 : 0)
  end

  def latest_cme_user_logs
    self.cme_user_logs.latest_only
  end

  def recalculate_completeness
    self.count_of_cmes_completed = self.cme_user_logs.latest_only.all_completed.with_elements_active.count
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100
    self.save(callbacks: false)
  end

  protected

  def send_cm_complete_to_mixpanel
    if self.percentage_complete.round(2) > 99
      MixpanelCourseModuleCompleteWorker.perform_async(
              self.user_id,
              self.course_module.name,
              self.exam_section.try(:name),
              self.exam_level.name,
              self.exam_level.parent.name,
              self.course_module.institution.name,
              self.course_module.institution.subject_area.name,
              self.course_module.course_module_elements.all_active.all_videos.count,
              self.course_module.course_module_elements.all_active.all_quizzes.count + (self.course_module.course_module_jumbo_quiz ? 1 : 0)
      )
    end
  end

end
