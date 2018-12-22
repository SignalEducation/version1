# == Schema Information
#
# Table name: course_sections
#
#  id                        :integer          not null, primary key
#  subject_course_id         :integer
#  name                      :string
#  name_url                  :string
#  sorting_order             :integer
#  active                    :boolean          default(FALSE)
#  counts_towards_completion :boolean          default(FALSE)
#  assumed_knowledge         :boolean          default(FALSE)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  cme_count                 :integer          default(0)
#  video_count               :integer          default(0)
#  quiz_count                :integer          default(0)
#  destroyed_at              :datetime
#

class CourseSection < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :subject_course_id, :name, :name_url, :sorting_order, :active,
                  :counts_towards_completion, :assumed_knowledge, :cme_count,
                  :video_count, :quiz_count, :_destroy, :course_modules_attributes

  # Constants

  # relationships
  belongs_to :subject_course
  has_many :course_section_user_logs
  has_many :course_modules
  has_many :student_exam_tracks
  has_many :course_module_element_user_logs
  has_many :course_module_elements
  accepts_nested_attributes_for :course_modules

  # validation
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true, uniqueness: { scope: :subject_course,
                                 message: "must be unique within a course" }
  validates :sorting_order, presence: true

  # callbacks
  before_destroy :check_dependencies
  before_save :set_count_fields, :sanitize_name_url
  after_update :update_parent

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :subject_course_id) }
  scope :all_active, -> { where(active: true) }
  scope :all_for_completion, -> { where(counts_towards_completion: true) }

  # class methods

  # instance methods

  ## Parent & Child associations ##
  def parent
    self.subject_course
  end

  def children
    self.course_modules.all
  end

  def active_children
    self.children.all_active.all_in_order
  end

  def first_active_course_module
    self.active_children.first
  end

  def first_active_cme
    self.first_active_course_module.first_active_cme
  end

  def children_available_count
    self.active_children.all_active.count
  end


  #######################################################################

  ## Archivable ability ##

  def destroyable?
    true
  end

  def destroyable_children
    # not destroyable:
    # - self.course_module_element_user_logs
    # - self.student_exam_tracks.empty?
    the_list = []
    the_list += self.course_modules.to_a
    the_list
  end

  #######################################################################

  ## Keeping Model Count Attributes Up-to-Date ##
  ### Triggered by Child Model ###
  def recalculate_fields
    # Temp change here - active_children to valid_children
    # filter out the test boolean true records so as not to count these in the %_complete

    cme_count = self.active_children.sum(:cme_count)
    quiz_count = self.active_children.sum(:quiz_count)
    video_count = self.active_children.sum(:video_count)

    self.update_attributes(cme_count: cme_count, quiz_count: quiz_count, video_count: video_count)
  end



  ########################################################################

  protected

  def set_count_fields
    self.cme_count = self.active_children.sum(:cme_count)
    self.quiz_count = self.active_children.sum(:quiz_count)
    self.video_count = self.active_children.sum(:video_count)
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
