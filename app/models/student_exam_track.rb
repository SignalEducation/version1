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
#

class StudentExamTrack < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :exam_level_id, :exam_section_id,
                  :latest_course_module_element_id, :exam_schedule_id,
                  :session_guid, :course_module_id, :jumbo_quiz_taken

  # Constants

  # relationships
  belongs_to :user
  belongs_to :exam_level
  belongs_to :exam_section
  belongs_to :latest_course_module_element, class_name: 'CourseModuleElement',
             foreign_key: :latest_course_module_element_id
  # todo belongs_to :exam_schedule

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_section_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :latest_course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_schedule_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, presence: true
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

end
