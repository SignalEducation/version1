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
#  description                             :text
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  default_number_of_possible_exam_answers :integer
#  destroyed_at                            :datetime
#  exam_body_id                            :integer
#  survey_url                              :string
#  group_id                                :integer
#  quiz_pass_rate                          :integer
#  background_image_file_name              :string
#  background_image_content_type           :string
#  background_image_file_size              :integer
#  background_image_updated_at             :datetime
#  preview                                 :boolean          default(FALSE)
#  computer_based                          :boolean          default(FALSE)
#  highlight_colour                        :string           default("#ef475d")
#  category_label                          :string
#  icon_label                              :string
#  constructed_response_count              :integer          default(0)
#  completion_cme_count                    :integer
#  release_date                            :date
#  seo_title                               :string
#  seo_description                         :string
#

class SubjectCourse < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :exam_body
  belongs_to :group
  has_many :course_tutor_details
  has_many :home_pages
  has_many :subject_course_resources
  has_many :orders
  has_many :mock_exams
  has_many :exam_sittings
  has_many :enrollments
  has_many :subject_course_user_logs
  has_many :course_sections
  has_many :course_section_user_logs
  has_many :course_modules
  has_many :student_exam_tracks
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_user_logs
  has_attached_file :background_image, default_url: "images/home_explore2.jpg"

  accepts_nested_attributes_for :subject_course_resources
  accepts_nested_attributes_for :course_sections

  # validation
  validates :name, presence: true, uniqueness: true, length: {maximum: 255}
  validates :category_label, presence: true, length: {maximum: 255}
  validates :icon_label, presence: true, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: true, length: {maximum: 255}
  validates :description, presence: true
  validates :group_id, presence: true
  validates :quiz_pass_rate, presence: true
  validates :survey_url, presence: true, length: {maximum: 255}
  validates_attachment_content_type :background_image, content_type: /\Aimage\/.*\Z/


  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_save :sanitize_name_url, :set_count_fields
  before_destroy :check_dependencies
  #after_create :update_sitemap

  # scopes
  scope :all_live, -> { where(active: true, preview: false).includes(:course_modules).where(course_modules: {active: true}) }
  scope :all_active, -> { where(active: true) }
  scope :with_active_children, -> { where(active: true).includes(:course_modules).where(course_modules: {active: true}) }
  scope :all_preview, -> { where(preview: true) }
  scope :all_computer_based, -> { where(computer_based: true) }
  scope :all_standard, -> { where(computer_based: false) }
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

  def self.search(search)
    if search
      where('name ILIKE ? OR description ILIKE ?', "%#{search}%", "%#{search}%")
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
    self.course_sections.all
  end

  def active_children
    self.children.all_active.all_in_order
  end

  def valid_children
    self.children.all_active.all_in_order
  end

  def first_active_child
    self.active_children.first
  end

  def first_active_cme
    self.active_children.first.try(:first_active_cme)
  end


  #######################################################################

  ## Archivable ability ##
  def destroyable?
    self.course_modules.empty?
  end

  def destroyable_children
    the_list = []
    the_list += self.course_sections.to_a
    the_list
  end

  ########################################################################


  ## Keeping Model Count Attributes Up-to-date ##

  ### Triggered by Child Model ###
  def recalculate_fields
    #Count of all CMEs in the course
    cme_count = valid_children.sum(:cme_count)
    #Count CMEs which count towards completion of the Course
    completion_cme_count = valid_children.all_for_completion.sum(:cme_count)

    quiz_count = valid_children.sum(:quiz_count)
    video_count = valid_children.sum(:video_count)
    cr_count = valid_children.sum(:constructed_response_count)

    self.update_attributes(cme_count: cme_count, completion_cme_count: completion_cme_count,
                           video_count: video_count, quiz_count: quiz_count,
                           constructed_response_count: cr_count)
  end

  ### Callback before_save ###
  def set_count_fields
    #Count of all CMEs in the course
    self.cme_count = valid_children.sum(:cme_count)
    #Count CMEs which count towards completion of the Course
    self.completion_cme_count = valid_children.all_for_completion.sum(:cme_count)

    self.quiz_count = valid_children.sum(:quiz_count)
    self.video_count = valid_children.sum(:video_count)
    self.constructed_response_count = valid_children.sum(:constructed_response_count)
  end


  ########################################################################


  ## User Course Tracking ##
  def enrolled_user_ids
    self.enrollments.map(&:user_id)
  end

  def active_enrollment_user_ids
    self.enrollments.all_active.map(&:user_id)
  end

  def valid_enrollment_user_ids
    self.enrollments.all_valid.map(&:user_id)
  end

  def started_by_user(user_id)
    self.subject_course_user_logs.for_user(user_id).first
  end

  def completed_by_user(user_id)
    self.percentage_complete_by_user(user_id) >= 100
  end

  def percentage_complete_by_user(user_id)
    if cme_count.nil?
      0
    else
      if self.cme_count > 0
        (self.number_complete_by_user(user_id).to_f / self.cme_count.to_f * 100).to_i
      else
        0
      end

    end
  end

  def number_complete_by_user(user_id)
    log = self.subject_course_user_logs.for_user(user_id).first
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


end
