# frozen_string_literal: true

# == Schema Information
#
# Table name: courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default("false"), not null
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
#  preview                                 :boolean          default("false")
#  computer_based                          :boolean          default("false")
#  highlight_colour                        :string           default("#ef475d")
#  category_label                          :string
#  icon_label                              :string
#  constructed_response_count              :integer          default("0")
#  completion_cme_count                    :integer
#  release_date                            :date
#  seo_title                               :string
#  seo_description                         :string
#  has_correction_packs                    :boolean          default("false")
#  short_description                       :text
#  on_welcome_page                         :boolean          default("false")
#  unit_label                              :string
#  level_id                                :integer
#  accredible_group_id                     :integer
#

class Course < ApplicationRecord
  include Archivable
  include Filterable
  include LearnSignalModelExtras

  # relationships
  belongs_to :exam_body
  belongs_to :group
  belongs_to :level
  has_many :product
  has_many :course_tutors
  has_many :home_pages
  has_many :course_resources
  has_many :orders
  has_many :cbes
  has_many :mock_exams
  has_many :exam_sittings
  has_many :enrollments
  has_many :course_logs
  has_many :course_sections
  has_many :course_section_logs
  has_many :course_lessons
  has_many :course_lesson_logs
  has_many :course_steps, through: :course_lessons
  has_many :course_quizzes, through: :course_steps
  has_many :related_course_step, through: :course_steps
  has_many :course_step_logs
  has_one :free_lesson, -> { where(free: true) }, class_name: 'CourseLesson'
  has_attached_file :background_image, default_url: 'images/home_explore2.jpg'

  accepts_nested_attributes_for :course_resources
  accepts_nested_attributes_for :course_sections

  # validation
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :category_label, presence: true, length: { maximum: 255 }
  validates :icon_label, presence: true, length: { maximum: 255 }
  validates :name_url, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :group_id, presence: true
  validates :level_id, presence: true
  validates :quiz_pass_rate, presence: true
  validates :survey_url, presence: true, length: { maximum: 255 }
  validates :accredible_group_id, presence: true, numericality: { only_integer: true }, if: :emit_certificate?
  validates_attachment_content_type :background_image, content_type: /\Aimage\/.*\Z/

  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_save :sanitize_name_url, :set_count_fields
  before_destroy :check_dependencies

  # scopes
  scope :all_live, -> { where(active: true, preview: false).includes(:course_lessons).where(course_lessons: { active: true }) }
  scope :all_active, -> { where(active: true) }
  scope :with_active_children, -> { where(active: true).includes(:course_lessons).where(course_lessons: { active: true }) }
  scope :all_preview, -> { where(preview: true) }
  scope :all_computer_based, -> { where(computer_based: true) }
  scope :all_standard, -> { where(computer_based: false) }
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }

  search_scope :by_group, ->(group_id) { (where group_id: group_id) if group_id.present? }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

  def self.search(search)
    if search
      where('name ILIKE ? OR description ILIKE ?', "%#{search}%", "%#{search}%")
    else
      Course.all_active.all_in_order
    end
  end

  ## Structures data in CSV format for Excel downloads ##
  def self.to_csv(options = {})
    #attributes are either model attributes or data generate in methods below
    attributes = %w[name new_enrollments total_enrollments active_enrollments non_expired_enrollments expired_enrollments completed_enrollments]
    CSV.generate(options) do |csv|
      csv << attributes

      all.find_each do |course|
        csv << attributes.map { |attr| course.send(attr) }
      end
    end
  end

  def duplicate
    new_course = deep_clone include: [
      :course_resources,
      course_sections: {
        course_lessons: {
          course_steps: [
            :related_course_step,
            :course_note,
            :video_resource,
            :course_video,
            constructed_response: {
              scenario: {
                scenario_questions: :scenario_answer_templates
              }
            },
            course_quiz: {
              quiz_questions: [
                :quiz_solutions,
                :quiz_contents,
                quiz_answers: :quiz_contents
              ]
            }
          ]
        }
      }
    ]

    ActiveRecord::Base.transaction do
      new_course.update!(name: "#{name} copy", name_url: "#{name_url}_copy", active: false) &&
        new_course.course_sections.map { |s| s.course_lessons.update_all(course_id: new_course.id) } &&
        update_all_files(new_course)
    end

    new_course
  rescue ActiveRecord::RecordInvalid => e
    Airbrake.notify(e)
    Appsignal.send_error(e)
    e
  end

  def update_all_files(new_course)
    new_course.course_steps.all_notes.each do |note|
      course_note = note.course_note
      old_note = course_steps.all_notes.find_by(name: note.name,
                                                name_url: note.name_url,
                                                temporary_label: note.temporary_label,
                                                sorting_order: note.sorting_order).course_note
      course_note.upload = old_note.upload
      course_note.save
    end

    new_course.course_resources.each do |resource|
      old_resource = course_resources.find_by(name: resource.name,
                                              description: resource.description,
                                              file_upload_file_name: resource.file_upload_file_name,
                                              file_upload_file_size: resource.file_upload_file_size)
      resource.file_upload = old_resource.file_upload
      resource.save
    end
  end

  # instance methods

  ## Parent & Child associations ##
  def parent
    group
  end

  def children
    course_sections.all
  end

  def active_children
    children.all_active.all_in_order
  end

  def valid_children
    children.all_active.all_in_order
  end

  def first_active_child
    active_children.first
  end

  def first_active_cme
    active_children.first.try(:first_active_cme)
  end

  #######################################################################

  ## Archivable ability ##
  def destroyable?
    self.course_lessons.empty?
  end

  def destroyable_children
    the_list = []
    the_list += self.course_sections.to_a
    the_list
  end

  ## Keeping Model Count Attributes Up-to-date ##
  ### Triggered by Child Model ###
  # Count of all CMEs in the course
  # Count CMEs which count towards completion of the Course
  def recalculate_fields
    cme_count            = valid_children.sum(:cme_count)
    completion_cme_count = valid_children.all_for_completion.sum(:cme_count)
    quiz_count           = valid_children.sum(:quiz_count)
    video_count          = valid_children.sum(:video_count)
    cr_count             = valid_children.sum(:constructed_response_count)

    update_attributes(cme_count: cme_count, completion_cme_count: completion_cme_count,
                      video_count: video_count, quiz_count: quiz_count,
                      constructed_response_count: cr_count)
  end

  ### Callback before_save ###
  # Count of all CMEs in the course
  # Count CMEs which count towards completion of the Course
  def set_count_fields
    self.cme_count                  = valid_children.sum(:cme_count)
    self.completion_cme_count       = valid_children.all_for_completion.sum(:cme_count)
    self.quiz_count                 = valid_children.sum(:quiz_count)
    self.video_count                = valid_children.sum(:video_count)
    self.constructed_response_count = valid_children.sum(:constructed_response_count)
  end

  ########################################################################

  ## User Course Tracking ##
  def enrolled_user_ids
    enrollments.map(&:user_id)
  end

  def active_enrollment_user_ids
    enrollments.all_active.map(&:user_id)
  end

  def valid_enrollment_user_ids
    enrollments.all_valid.map(&:user_id)
  end

  def started_by_user(user_id)
    course_logs.for_user(user_id).first
  end

  def completed_by_user(user_id)
    percentage_complete_by_user(user_id) >= 100
  end

  def percentage_complete_by_user(user_id)
    if cme_count.nil?
      0
    elsif cme_count.positive?
      (number_complete_by_user(user_id) / cme_count.to_f * 100).to_i
    else
      0
    end
  end

  def number_complete_by_user(user_id)
    log = course_logs.for_user(user_id).first
    log.try(:count_of_cmes_completed)
  end

  def update_all_course_logs
    CourseLessonLogsWorker.perform_async(id)
  end

  def free_course_steps
    return unless course_sections.all_in_order.first

    section_lesson_ids = course_sections.all_in_order.first.course_lessons.all_in_order.map(&:id)
    course_steps.where(course_lesson_id: section_lesson_ids, active: true, available_on_trial: true).includes(:course_lesson).order("course_lessons.sorting_order asc")
  end

  ########################################################################

  ## Used by self.to_csv above ##
  def new_enrollments
    enrollments.this_week.count
  end

  def active_enrollments
    enrollments.all_active.count
  end

  def expired_enrollments
    enrollments.all_expired.count
  end

  def non_expired_enrollments
    enrollments.all_not_expired.count
  end

  def completed_enrollments
    enrollments.all_completed.count
  end

  def total_enrollments
    enrollments.count
  end

  ########################################################################

  ## Misc. ##

  def home_page
    home_pages.all_in_order.first
  end

  def emit_certificate?
    exam_body&.emit_certificate
  end

  protected

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end
end
