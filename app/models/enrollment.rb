# == Schema Information
#
# Table name: enrollments
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subject_course_id          :integer
#  subject_course_user_log_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  active                     :boolean          default(FALSE)
#  student_number             :string
#  exam_body_id               :integer
#  exam_date                  :date
#  registered                 :boolean          default(FALSE)
#

class Enrollment < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :subject_course_id, :subject_course_user_log_id, :active, :student_number, :exam_body_id, :exam_date, :registered

  # Constants

  # relationships
  belongs_to :exam_body
  belongs_to :user
  belongs_to :subject_course
  belongs_to :subject_course_user_log

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_user_log_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies
  before_validation :set_empty_strings_to_nil
  after_create :course_enrollment_intercom_event

  # scopes
  scope :all_in_order, -> { order(created_at: :desc) }
  scope :all_active, -> { includes(:subject_course).where(active: true) }
  scope :all_paused, -> { where(active: false) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }

  scope :all_completed, ->() {
    joins(:subject_course_user_log).where('subject_course_user_logs.percentage_complete > 99')
  }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def set_empty_strings_to_nil
    self.student_number = nil if self.student_number && self.student_number.empty?
  end

  def self.to_csv(options = {})
    attributes = %w{id course_name exam_date user_email date_of_birth student_number percentage_complete elements_complete_count course_elements_count}
    CSV.generate(options) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def course_name
    self.subject_course.name
  end

  def user_email
    self.user.email
  end

  def date_of_birth
    self.user.try(:date_of_birth)
  end

  def percentage_complete
    course_log = self.subject_course_user_log
    if course_log
      percentage = course_log.percentage_complete
      percentage.to_s << ' %' if percentage
    end
  end

  def elements_complete_count
    course_log = self.subject_course_user_log
    if course_log
      percentage = course_log.count_of_cmes_completed
      percentage
    end
  end

  def course_elements_count
    course_log = self.subject_course_user_log
    if course_log
      course_log.elements_total
    end
  end


  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def course_enrollment_intercom_event
    IntercomCourseEnrolledEventWorker.perform_async(self.try(:user_id), self.subject_course.name)
    IntercomExamSittingEventWorker.perform_async(self.try(:user_id), self.exam_date, self.exam_body.name)
  end

end
