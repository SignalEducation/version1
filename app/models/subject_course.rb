# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  email_content                           :text
#  external_url_name                       :string
#  external_url                            :string
#  exam_body_id                            :integer
#  survey_url                              :string
#  group_id                                :integer
#  quiz_pass_rate                          :integer
#  total_estimated_time_in_seconds         :integer
#  background_image_file_name              :string
#  background_image_content_type           :string
#  background_image_file_size              :integer
#  background_image_updated_at             :datetime
#

class SubjectCourse < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :name, :name_url, :sorting_order, :active,
                  :cme_count, :description, :short_description,
                  :default_number_of_possible_exam_answers,
                  :email_content, :external_url, :external_url_name,
                  :quiz_count, :question_count, :video_count,
                  :total_video_duration, :exam_body_id, :survey_url,
                  :group_id, :quiz_pass_rate, :total_estimated_time_in_seconds,
                  :background_image

  # Constants

  # relationships
  belongs_to :exam_body
  belongs_to :group
  has_and_belongs_to_many :users
  has_many :course_modules
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :quiz_questions
  has_many :enrollments
  has_many :home_pages
  has_many :student_exam_tracks
  has_many :subject_course_user_logs
  has_many :subject_course_resources
  has_many :orders
  has_many :white_papers
  has_many :mock_exams
  has_many :exam_sittings
  has_attached_file :background_image, default_url: "images/home_explore2.jpg"


  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true,
            length: {maximum: 255}
  validates :description, presence: true
  #validates :group_id, presence: true
  validates :quiz_pass_rate, presence: true
  validates :short_description, allow_nil: true, length: {maximum: 255}
  validates_attachment_content_type :background_image, content_type: /\Aimage\/.*\Z/


  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_save :sanitize_name_url, :set_count_fields
  before_destroy :check_dependencies
  after_create :update_sitemap

  # scopes
  scope :all_active, -> { where(active: true).includes(:course_modules).where(course_modules: {active: true}) }
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

  def self.search(search)
    if search
      where('name ILIKE ? OR description ILIKE ? OR short_description ILIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      SubjectCourse.all_active.all_in_order
    end
  end

  ## Structures data in CSV format for Excel downloads ##
  def self.to_csv(options = {})
    #attributes are either model attributes or data generate in methods below
    attributes = %w{name new_enrollments total_enrollments active_enrollments non_expired_enrollments expired_enrollments completed_enrollments}
    CSV.generate(options) do |csv|
      csv << attributes

      all.each do |course|
        csv << attributes.map{ |attr| course.send(attr) }
      end
    end
  end


  # instance methods

  ## Parent & Child associations ##
  def parent
    self.group
  end

  def children
    self.course_modules.all
  end

  def active_children
    self.children.all_active.all_in_order
  end

  def first_active_child
    self.active_children.first
  end

  def first_active_cme
    self.active_children.first.try(:first_active_cme)
  end

  def tuition_children?
    self.active_children.all_tuition.count >= 1
  end

  def test_children?
    self.active_children.all_test.count >= 1
  end

  def revision_children?
    self.active_children.all_revision.count >= 1
  end

  #######################################################################

  ## Archivable ability ##
  def destroyable?
    self.course_modules.empty?
  end

  def destroyable_children
    the_list = []
    the_list += self.course_modules.to_a
    the_list
  end

  ########################################################################


  ## Keeping Model Count Attributes Up-to-date ##

  ### Triggered by Child Model ###
  def recalculate_fields
    cme_count = self.active_children.sum(:cme_count)
    quiz_count = self.active_children.sum(:quiz_count)
    question_count = self.active_children.sum(:number_of_questions)
    video_count = self.active_children.sum(:video_count)
    video_duration = self.active_children.sum(:video_duration)
    total_estimated_time_in_seconds = self.active_children.sum(:estimated_time_in_seconds)

    self.update_attributes(cme_count: cme_count, quiz_count: quiz_count, question_count: question_count, video_count: video_count, total_video_duration: video_duration, total_estimated_time_in_seconds: total_estimated_time_in_seconds)
  end

  ### Callback before_save ###
  def set_count_fields
    self.cme_count = self.active_children.sum(:cme_count)
    self.quiz_count = self.active_children.sum(:quiz_count)
    self.question_count = self.active_children.sum(:number_of_questions)
    self.video_count = self.active_children.sum(:video_count)
    self.total_video_duration = self.active_children.sum(:video_duration)
    self.total_estimated_time_in_seconds = self.active_children.sum(:estimated_time_in_seconds)
  end


  ########################################################################

  ## User Course Tracking ##
  def enrolled_user_ids
    self.enrollments.map(&:user_id)
  end

  def active_enrollment_user_ids
    self.enrollments.all_active.map(&:user_id)
  end

  def started_by_user_or_guid(user_id, session_guid)
    self.subject_course_user_logs.for_user_or_session(user_id, session_guid).first
  end

  def completed_by_user_or_guid(user_id, session_guid)
    self.percentage_complete_by_user_or_guid(user_id, session_guid) == 100
  end

  def percentage_complete_by_user_or_guid(user_id, session_guid)
    if cme_count.nil?
      0
    else
      if self.cme_count > 0
        (self.number_complete_by_user_or_guid(user_id, session_guid).to_f / self.cme_count.to_f * 100).to_i
      else
        0
      end

    end
  end

  def number_complete_by_user_or_guid(user_id, session_guid)
    log = self.subject_course_user_logs.for_user_or_session(user_id, session_guid).first
    log.try(:count_of_cmes_completed)
  end

  def update_all_course_logs
    SubjectCourseUserLogWorker.perform_async(self.id)
  end

  ########################################################################

  ## Used by self.to_csv above ##
  def new_enrollments
    self.enrollments.this_week.count
  end

  def active_enrollments
    self.enrollments.all_active.count
  end

  def expired_enrollments
    self.enrollments.all_expired.count
  end

  def non_expired_enrollments
    self.enrollments.all_not_expired.count
  end

  def completed_enrollments
    self.enrollments.all_completed.count
  end

  def total_enrollments
    self.enrollments.count
  end

  ########################################################################

  ## Misc. ##

  def home_page
    self.home_pages.all_in_order.first
  end


  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  #TODO Why is this not called from anywhere? CRON??
  def update_course_logs
    SubjectCourseUserLogWorker.perform_async(self.id)
  end

end
