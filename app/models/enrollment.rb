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

  # Constants

  # relationships
  belongs_to :exam_body
  belongs_to :exam_sitting
  belongs_to :user
  belongs_to :subject_course
  belongs_to :subject_course_user_log

  # validation
  validates :user_id, presence: true
  validates :subject_course_id, presence: true
  validates :subject_course_user_log_id, presence: true
  validates :exam_body_id, presence: true
  validates :exam_date, allow_nil: true, inclusion:
      {in: Date.today..Date.today + 2.years, message: "%{value} is not a valid date" }


  # callbacks
  before_destroy :check_dependencies
  before_validation :create_subject_course_user_log, unless: :subject_course_user_log_id
  before_create :set_percentage_complete, if: :subject_course_user_log_id
  after_create :create_expiration_worker, :deactivate_siblings
  after_update :create_expiration_worker, if: :exam_date_changed?

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
  scope :for_subject_course, lambda { |course_id| where(subject_course_id: course_id) }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :for_course_and_user, lambda { |course_id, user_id| where(subject_course_id: course_id, user_id: user_id) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :by_sitting, lambda { |sitting_id| where(exam_sitting_id: sitting_id) }

  scope :all_completed, ->() {
    joins(:subject_course_user_log).where('subject_course_user_logs.percentage_complete > 99')
  }

  # class methods
  def self.search(search)
    if search
      Enrollment.joins(:user).where('users.email ILIKE ? ', "%#{search}%")
    else
      Enrollment.paginate(per_page: 50, page: params[:page])
    end
  end

  def self.to_csv(options = {})
    attributes = %w{id user_id status f_name l_name course_name exam_sitting_name enrollment_date user_email date_of_birth student_number display_percentage_complete elements_complete_count course_elements_count }
    CSV.generate(options) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
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

  def f_name
    self.user.first_name
  end

  def l_name
    self.user.last_name
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

  def alternate_exam_sittings
    ExamSitting.where(active: true, computer_based: false, subject_course_id: subject_course.id,
                                       exam_body_id: subject_course.exam_body_id).all_in_order
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
      if self.exam_sitting && self.exam_sitting.date
        self.exam_sitting.date >= current_date ? (self.exam_sitting.date - current_date).to_i : 0
      else
        0
      end
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
        enrollment.update_attribute(:active, false)
      end
    end
  end

  def create_subject_course_user_log
    subject_course_user_log = SubjectCourseUserLog.create!(user_id: self.user_id,
                                                           session_guid: self.user.try(:session_guid),
                                                           subject_course_id: self.subject_course_id)
    self.subject_course_user_log_id = subject_course_user_log.id
  end

  def set_percentage_complete
    self.percentage_complete = subject_course_user_log.percentage_complete
  end

  def create_expiration_worker
    if self.computer_based_exam && self.exam_date
      EnrollmentExpirationWorker.perform_at(self.exam_date.to_datetime + 23.hours, self.id) unless Rails.env.test?
    end
  end

end
