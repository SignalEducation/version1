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
#

class Enrollment < ActiveRecord::Base

  # attr-accessible
  attr_accessible :user_id, :subject_course_id, :subject_course_user_log_id, :active,
                  :exam_body_id, :exam_date, :expired, :notifications, :updated_at

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
  validates :exam_body_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}


  # callbacks
  before_destroy :check_dependencies
  after_create :create_expiration_worker, :deactivate_siblings
  after_update :create_expiration_worker, if: :exam_date_changed?

  # scopes
  scope :all_in_order, -> { order(:active, :created_at) }
  scope :all_in_admin_order, -> { order(:subject_course_id, :created_at) }
  scope :all_active, -> { includes(:subject_course).where(active: true) }
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
    false
  end

  def valid_enrollment?
    self.active && !self.expired
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

  def student_number
    self.user.student_number
  end

  def date_of_birth
    self.user.try(:date_of_birth)
  end

  def percentage_complete
    course_log = self.subject_course_user_log
    if course_log
      percentage = course_log.percentage_complete
      percentage.to_s << '%' if percentage
    end
  end

  def rounded_percentage_complete
    course_log = self.subject_course_user_log
    if course_log
      percentage = course_log.percentage_complete
      percentage.between?(25,50)
      if percentage && (percentage.between?(25,49))
        '25%'
      elsif percentage && (percentage.between?(50,74))
        '50%'
      elsif percentage && (percentage.between?(75,99))
        '75%'
      elsif percentage && (percentage == 100)
        '100%'
      end
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

  def sibling_enrollments
    self.user.enrollments.where(subject_course_id: self.subject_course_id).where.not(id: self.id)
  end

  def status
    self.expired ? 'Expired' : 'Active'
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
    if self.user.individual_student?
      EnrollmentExpirationWorker.perform_at(self.exam_date.to_datetime + 23.hours, self.id)
    end
  end

end
