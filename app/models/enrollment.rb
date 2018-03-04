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
#  exam_body_id               :integer
#  exam_date                  :date
#  expired                    :boolean          default(FALSE)
#  paused                     :boolean          default(FALSE)
#  notifications              :boolean          default(TRUE)
#  exam_sitting_id            :integer
#  computer_based_exam        :boolean          default(FALSE)
#  percentage_complete        :integer          default(0)
#

class Enrollment < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :subject_course_id, :subject_course_user_log_id, :active,
                  :exam_body_id, :exam_date, :expired, :notifications, :updated_at,
                  :exam_sitting_id, :computer_based_exam, :percentage_complete

  # Constants

  # relationships
  belongs_to :exam_body
  belongs_to :exam_sitting
  belongs_to :user
  belongs_to :subject_course
  belongs_to :subject_course_user_log

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_sitting_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_user_log_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_body_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}


  # callbacks
  before_destroy :check_dependencies
  after_create :create_expiration_worker, :deactivate_siblings, :create_intercom_event
  after_update :create_expiration_worker, if: :exam_date_changed?
  after_update :study_streak_email

  # scopes
  scope :all_in_order, -> { order(:active, :created_at) }
  scope :all_in_admin_order, -> { order(:subject_course_id, :created_at) }
  scope :all_in_exam_sitting_order, -> { order(:exam_sitting_id) }
  scope :all_reverse_order, -> { order(:created_at).reverse }
  scope :all_in_exam_order, -> { order(:exam_sitting_id) }
  scope :by_sitting_date, -> { order('exam_sittings.date').includes(:exam_sitting).reverse }
  scope :all_in_recent_order, -> { order(:updated_at).reverse }
  scope :all_active, -> { includes(:subject_course).where(active: true) }
  scope :all_not_active, -> { includes(:subject_course).where(active: false) }
  scope :all_expired, -> { where(expired: true) }
  scope :all_valid, -> { where(active: true, expired: false) }
  scope :all_not_expired, -> { where(expired: false) }
  scope :all_expired, -> { where(expired: true) }
  scope :for_subject_course, lambda { |course_id| where(subject_course_id: course_id) }
  scope :all_paused, -> { where(paused: true) }
  scope :all_un_paused, -> { where(paused: false) }
  scope :all_for_notifications, -> { where(notifications: true) }
  scope :all_not_for_notifications, -> { where(notifications: false) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }

  scope :all_completed, ->() {
    joins(:subject_course_user_log).where('subject_course_user_logs.percentage_complete > 99')
  }

  # class methods

  # instance methods
  def destroyable?
    false # Can never be destroyed because the CSV data files will not be accurate
  end

  def valid_enrollment?
    self.active && !self.expired
  end

  def self.to_csv(options = {})
    attributes = %w{id user_id status course_name exam_sitting_name enrollment_date user_email date_of_birth student_number display_percentage_complete elements_complete_count course_elements_count}
    CSV.generate(options) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def enrollment_date
    if self.exam_date && self.computer_based_exam
      self.exam_date
    elsif self.exam_date && !self.exam_sitting_id
      #For Old Enrollments without ExamSittingIds
      self.exam_date
    else
      self.exam_sitting.date
    end
  end

  def course_name
    self.subject_course.try(:name)
  end

  def exam_sitting_name
    self.exam_sitting.try(:name)
  end

  def user_email
    self.user.email
  end

  def student_number
    self.user.student_number
  end

  def date_of_birth
    self.user.try(:date_of_birth)
  end

  def display_percentage_complete
    self.percentage_complete.to_s << '%'
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

  def sibling_enrollments
    self.subject_course.enrollments.where(user_id: self.user_id).where.not(id: self.id)
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
      self.exam_sitting.date >= current_date ? (self.exam_sitting.date - current_date).to_i : 0
    end

  end



  def find_and_set_exam_sitting_id
    if self.exam_date
      exam_sitting = ExamSitting.where(subject_course_id: self.subject_course_id, date: self.exam_date, computer_based: false).first

      if exam_sitting
        sitting_id = exam_sitting.id
        percentage = self.subject_course_user_log_id ? self.subject_course_user_log.percentage_complete : 0
        expiration = exam_sitting.active ? false : true
        self.update_columns(exam_sitting_id: sitting_id, percentage_complete: percentage, expired: expiration)
      else
        sitting = ExamSitting.where(subject_course_id: self.subject_course_id, computer_based: false).first

        sitting_id = sitting.id
        percentage = self.subject_course_user_log_id ? self.subject_course_user_log.percentage_complete : 0
        expiration = sitting.active ? false : true
        self.update_columns(exam_sitting_id: sitting_id, percentage_complete: percentage, expired: expiration)

      end
    else
      exam_sitting = ExamSitting.where(name: 'Missing date value enrolments').first
      percentage = self.subject_course_user_log_id ? self.subject_course_user_log.percentage_complete : 0
      self.update_columns(expired: true, exam_sitting_id: exam_sitting.id, percentage_complete: percentage)
    end

  end


  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def deactivate_siblings
    if self.sibling_enrollments.any?
      self.sibling_enrollments.each do |enrollment|
        enrollment.update_attributes(active: false, notifications: false)
      end
    end
  end

  def create_expiration_worker
    if self.computer_based_exam && self.exam_date
      EnrollmentExpirationWorker.perform_at(self.exam_date.to_datetime + 23.hours, self.id)
    end
  end

  def create_intercom_event
    IntercomCourseEnrolledEventWorker.perform_async(self.user_id, self.subject_course.name, self.exam_date)
  end

  def study_streak_email
    if !self.expired && self.active && self.subject_course_user_log_id
      yesterdays_log_ids = []
      time_now = Proc.new{Time.now}.call
      scul = self.subject_course_user_log

      scul.course_module_element_user_logs.each do |log|
        if log.updated_at > (time_now - 1.day)
          yesterdays_log_ids << log.id
        end
      end

      if yesterdays_log_ids.count >= 2 && scul.last_element && scul.last_element.next_element
        EnrollmentEmailWorker.perform_at(24.hours, self.user.email, scul.id, time_now.to_i, 'send_study_streak_email') unless Rails.env.test?
      end
    end
  end

end
