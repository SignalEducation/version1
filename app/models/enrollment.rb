# == Schema Information
#
# Table name: enrollments
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  course_id           :integer
#  course_log_id       :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  active              :boolean          default("false")
#  exam_body_id        :integer
#  exam_date           :date
#  expired             :boolean          default("false")
#  paused              :boolean          default("false")
#  notifications       :boolean          default("true")
#  exam_sitting_id     :integer
#  computer_based_exam :boolean          default("false")
#  percentage_complete :integer          default("0")
#

class Enrollment < ApplicationRecord
  # Constants

  # relationships
  belongs_to :exam_body, optional: true
  belongs_to :exam_sitting, optional: true
  belongs_to :user, optional: true
  belongs_to :course, optional: true
  belongs_to :course_log, optional: true

  # validation
  validates :user_id, presence: true
  validates :course_id, presence: true
  validates :course_log_id, presence: true
  validates :exam_body_id, presence: true
  validates :exam_date, allow_nil: true, inclusion:
      { in: Time.zone.today..Time.zone.today + 2.years, message: '%{value} is not a valid date' }


  # callbacks
  before_destroy :check_dependencies
  before_validation :create_course_log, unless: :course_log_id
  before_create :set_percentage_complete, if: :course_log_id
  after_create :create_expiration_worker, :deactivate_siblings
  after_update :create_expiration_worker, if: :exam_date_changed?

  # scopes
  scope :all_in_order,              -> { order(:active, :created_at) }
  scope :all_in_admin_order,        -> { order(:course_id, :created_at) }
  scope :all_in_exam_sitting_order, -> { order(:exam_sitting_id) }
  scope :all_reverse_order,         -> { order(created_at: :desc) }
  scope :all_in_exam_order,         -> { order(:exam_sitting_id) }
  scope :all_in_recent_order,       -> { order(updated_at: :desc) }
  scope :all_active,                -> { includes(:course).where(active: true) }
  scope :all_not_active,            -> { includes(:course).where(active: false) }
  scope :all_expired,               -> { where(expired: true) }
  scope :all_valid,                 -> { where(active: true, expired: false) }
  scope :all_not_expired,           -> { where(expired: false) }
  scope :for_course,                ->(course_id) { where(course_id: course_id) }
  scope :for_user,                  ->(user_id) { where(user_id: user_id) }
  scope :for_course_and_user,       ->(course_id, user_id) { where(course_id: course_id, user_id: user_id) }
  scope :by_sitting_date,           -> { includes(:exam_sitting).order('exam_sittings.date desc') }
  scope :this_week,                 -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }

  scope :all_completed, lambda {
    joins(:course_log).
      where('course_logs.percentage_complete > 99')
  }

  scope :for_active_course, lambda {
    includes(:course).
      where(active: true, expired: false).
      references(:courses).
      where('courses.active = ?', true)
  }

  # class methods
  def self.search(search)
    search.present? ? joins(:user).where('users.email ILIKE ? ', "%#{search}%") : all
  end

  def self.by_sitting(exam_sitting)
    if exam_sitting && exam_sitting[:id]
      where(exam_sitting_id: exam_sitting[:id])
    else
      all
    end
  end

  def self.create_on_register_login(user, course_id)
    course = Course.where(id: course_id).first
    exam_sitting = course.exam_sittings.all_active.all_in_order.first
    if course&.active && exam_sitting
      existing_enrollment = user.enrollments.where(exam_sitting_id: exam_sitting).all_active.all_not_expired.last
      if existing_enrollment
        enrollment = existing_enrollment.update_attribute(:notifications, true)
        message = "Thank you. You have successfully registered for the #{existing_enrollment&.course&.name} Bootcamp"
      else
        enrollment = Enrollment.create!(user_id: user.id, active: true, course_id: course.id,
                           exam_sitting_id: exam_sitting.id,
                           exam_body_id: course.exam_body_id, notifications: true)
        message = "Thank you. You have successfully enrolled in #{enrollment&.course&.name} and opted into Bootcamp"
      end
    else
      message = "Sorry! Bootcamp is not currently available #{'for ' + course&.name}"
    end
    return enrollment, message
  end

  # instance methods
  def destroyable?
    false # Can never be destroyed because the CSV data files will not be accurate
  end

  def valid_enrollment?
    self.active && !self.expired
  end

  def enrollment_date
    if self.exam_date && self.computer_based_exam
      self.exam_date
    elsif self.exam_date && !self.exam_sitting_id
      #For Old Enrollments without ExamSittingIds
      self.exam_date
    else
      self.exam_sitting.date if self.exam_sitting
    end
  end

  def student_number
    self.user.exam_body_user_details.for_exam_body(self.course.exam_body_id).first.try(:student_number)
  end

  def alternate_exam_sittings
    ExamSitting.where(active: true, computer_based: false, course_id: course.id,
                                       exam_body_id: course.exam_body_id).all_in_order
  end

  def sibling_enrollments
    self.course.enrollments.where(user_id: self.user_id).where.not(id: self.id)
  end

  def display_percentage_complete
    self.percentage_complete.to_s << '%'
  end

  def status
    self.expired ? 'Expired' : 'Active'
  end

  def days_until_exam
    current_date = Proc.new{Time.now.to_date}.call
    if self.exam_date && self.computer_based_exam
      self.exam_date >= current_date ? (self.exam_date - current_date).to_i : 0
    elsif self.exam_date && !self.exam_sitting_id
      #For Old Enrollments without ExamSittingIds
      self.exam_date >= current_date ? (self.exam_date - current_date).to_i : 0
    else
      if self.exam_sitting && self.exam_sitting.date
        self.exam_sitting.date >= current_date ? (self.exam_sitting.date - current_date).to_i : 0
      else
        0
      end
    end
  end

  protected

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end

  def deactivate_siblings
    return unless sibling_enrollments.any?

    sibling_enrollments.each do |enrollment|
      enrollment.update_attribute(:active, false)
    end
  end

  def create_course_log
    course_log = CourseLog.create!(user_id: user_id, session_guid: user.try(:session_guid), course_id: course_id)
    self.course_log_id = course_log.id
  end

  def set_percentage_complete
    self.percentage_complete = course_log.percentage_complete
  end

  def create_expiration_worker
    return unless computer_based_exam && exam_date

    EnrollmentExpirationWorker.perform_at(exam_date.to_datetime + 23.hours, id) unless Rails.env.test?
  end
end
