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
#  percentage_complete             :integer          default(0)
#  count_of_cmes_completed         :integer          default(0)
#

class StudentExamTrack < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :exam_level_id, :exam_section_id,
                  :latest_course_module_element_id, :exam_schedule_id,
                  :session_guid, :course_module_id, :jumbo_quiz_taken,                                   :percentage_complete, :count_of_cmes_completed

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

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :for_session_guid, lambda { |the_guid| where(session_guid: the_guid) }
  scope :for_unknown_users, -> { where(user_id: nil) }

  # class methods
  def self.assign_user_to_session_guid(the_user_id, the_session_guid)
    # activate this with the following:
    # StudentExamTrack.assign_user_to_session_guid(123, 'abcde123')
    StudentExamTrack.for_session_guid(the_session_guid).for_unknown_users.update_all(user_id: the_user_id)
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

  def latest_cme_user_logs
    self.cme_user_logs.latest_only
  end

  def elements_total
    self.course_module.children.count + (self.course_module.course_module_jumbo_quiz ? 1 : 0)
  end

  def elements_complete
    self.latest_cme_user_logs.count
  end

  def destroyable?
    true
  end

  def recalculate_completeness
    self.count_of_cmes_completed = self.cme_user_logs.latest_only.all_completed.count
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.course_module.children_available_count ) * 100
    self.save(callbacks: false)
  end

  protected

end
