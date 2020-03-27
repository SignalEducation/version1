# == Schema Information
#
# Table name: course_sections
#
#  id                         :integer          not null, primary key
#  course_id          :integer
#  name                       :string
#  name_url                   :string
#  sorting_order              :integer
#  active                     :boolean          default("false")
#  counts_towards_completion  :boolean          default("false")
#  assumed_knowledge          :boolean          default("false")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  cme_count                  :integer          default("0")
#  video_count                :integer          default("0")
#  quiz_count                 :integer          default("0")
#  destroyed_at               :datetime
#  constructed_response_count :integer          default("0")
#

class CourseSection < ApplicationRecord

  include LearnSignalModelExtras
  #include Archivable

  # relationships
  belongs_to :course
  has_many :course_section_logs
  has_many :course_lessons
  has_many :course_lesson_logs
  has_many :course_step_logs
  accepts_nested_attributes_for :course_lessons

  # validation
  validates :course, presence: true
  validates :name, presence: true
  validates :name_url, presence: true, uniqueness: { scope: :course,
                                 message: "must be unique within a course" }
  #validates :sorting_order, presence: true

  # callbacks
  before_destroy :check_dependencies
  before_save :sanitize_name_url
  before_update :set_count_fields
  after_update :update_parent

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_id) }
  scope :all_active, -> { where(active: true) }
  scope :all_for_completion, -> { where(counts_towards_completion: true) }

  # class methods

  # instance methods

  ## Parent & Child associations ##
  def parent
    self.course
  end

  def children
    self.course_lessons.all
  end

  def active_children
    self.children.all_active.all_in_order
  end

  def first_active_course_lesson
    self.active_children.first
  end

  def first_active_cme
    self.first_active_course_lesson.first_active_cme
  end

  def children_available_count
    self.active_children.all_active.count
  end

  def all_content_restricted?
    child_array = active_children.map(&:all_content_restricted?)
    active_children.count == child_array.select { |child| child == true }.count
  end


  #######################################################################

  ## Archivable ability ##

  def destroyable?
    true
  end

  def destroyable_children
    # not destroyable:
    # - self.course_step_logs
    # - self.course_lesson_logs.empty?
    the_list = []
    the_list += self.course_lessons.to_a
    the_list
  end

  #######################################################################

  ## Keeping Model Count Attributes Up-to-Date ##
  ### Triggered by Child Model ###
  def recalculate_fields
    cme_count = self.active_children.sum(:cme_count)
    quiz_count = self.active_children.sum(:quiz_count)
    video_count = self.active_children.sum(:video_count)
    cr_count = self.active_children.sum(:constructed_response_count)

    self.update_attributes(cme_count: cme_count, quiz_count: quiz_count,
                           video_count: video_count, constructed_response_count: cr_count)
  end



  ########################################################################

  protected

  def set_count_fields
    self.cme_count = self.active_children.sum(:cme_count)
    self.quiz_count = self.active_children.sum(:quiz_count)
    self.video_count = self.active_children.sum(:video_count)
    self.constructed_response_count = self.active_children.sum(:constructed_response_count)
  end

  def update_parent
    self.parent.try(:recalculate_fields)
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
