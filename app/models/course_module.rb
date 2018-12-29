# == Schema Information
#
# Table name: course_modules
#
#  id                         :integer          not null, primary key
#  name                       :string
#  name_url                   :string
#  description                :text
#  sorting_order              :integer
#  estimated_time_in_seconds  :integer
#  active                     :boolean          default(FALSE), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  cme_count                  :integer          default(0)
#  seo_description            :string
#  seo_no_index               :boolean          default(FALSE)
#  destroyed_at               :datetime
#  number_of_questions        :integer          default(0)
#  subject_course_id          :integer
#  video_duration             :float            default(0.0)
#  video_count                :integer          default(0)
#  quiz_count                 :integer          default(0)
#  highlight_colour           :string
#  tuition                    :boolean          default(FALSE)
#  test                       :boolean          default(FALSE)
#  revision                   :boolean          default(FALSE)
#  course_section_id          :integer
#  constructed_response_count :integer          default(0)
#

class CourseModule < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :name, :name_url, :description, :sorting_order,
                  :active, :cme_count, :subject_course_id,
                  :highlight_colour, :quiz_count,
                  :video_count, :course_module_elements_attributes,
                  :course_section_id, :constructed_response_count

  # Constants

  # relationships
  belongs_to :subject_course
  belongs_to :course_section
  has_many :student_exam_tracks
  has_many :course_module_elements
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :course_module_element_videos, through: :course_module_elements
  has_many :course_module_element_user_logs

  accepts_nested_attributes_for :course_module_elements

  # validation
  validates :subject_course_id, presence: true
  validates :course_section_id, presence: true
  validates :name, presence: true,
            uniqueness: {scope: :course_section}, length: {maximum: 255}
  validates :name_url, presence: true, uniqueness: { scope: :course_section,
                                     message: "must be unique within the course section" }

  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :description) }
  before_create :set_sorting_order
  before_save :set_count_fields, :sanitize_name_url
  after_update :update_parent

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_section_id) }
  scope :all_active, -> { where(active: true, destroyed_at: nil) }
  scope :all_inactive, -> { where(active: false) }
  scope :with_url, lambda { |the_url| where(name_url: the_url) }

  # class methods

  # instance methods

  ## Parent & Child associations ##
  def parent
    self.course_section
  end

  def children
    self.course_module_elements.all
  end

  def active_children
    self.children.all_active.all_in_order
  end

  def first_active_cme
    self.active_children.first
  end

  def children_available_count
    self.active_children.all_active.count
  end

  #######################################################################

  ## Methods allow for navigation from one CM to the next ##

  #TODO - these do not work when latest course modules are made inactive
  # Needs a fallback

  def array_of_sibling_ids
    self.parent.course_modules.all_active.all_in_order.map(&:id)
  end

  def my_position_among_siblings
    self.array_of_sibling_ids.index(self.id)
  end

  def next_module
    CourseModule.find_by_id(self.next_module_id) || nil
  end

  def next_module_id
    if self.my_position_among_siblings < (self.array_of_sibling_ids.length - 1)
      self.array_of_sibling_ids[self.my_position_among_siblings + 1]
    else
      nil
    end
  end

  def previous_module
    CourseModule.find_by_id(self.previous_module_id) || nil
  end

  def previous_module_id
    if self.my_position_among_siblings > 0
      self.array_of_sibling_ids[self.my_position_among_siblings - 1]
    else
      nil
    end
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
    the_list += self.course_module_elements.to_a
    the_list
  end


  #######################################################################

  ## Keeping Model Count Attributes Up-to-Date ##

  ### Triggered by child CME after_save callback ###
  def update_video_and_quiz_counts
    quiz_count = self.active_children.all_active.all_quizzes.count
    video_count = self.active_children.all_active.all_videos.count
    cr_count = self.active_children.all_active.all_constructed_response.count

    self.update_attributes(quiz_count: quiz_count, video_count: video_count,
                           constructed_response_count: cr_count,
                           cme_count: quiz_count + video_count + cr_count)
  end


  ########################################################################

  ## User Course Tracking ##

  def completed_by_user(user_id)
    self.percentage_complete_by_user(user_id) >= 100
  end

  def percentage_complete_by_user(user_id)
    set = self.student_exam_tracks.where(user_id: user_id).last
    set.try(:percentage_complete) || 0
  end

  def completed_for_enrollment(enrollment_id)
    self.percentage_complete_for_enrollment(enrollment_id) >= 100
  end

  def percentage_complete_for_enrollment(enrollment_id)
    enrollment = Enrollment.where(id: enrollment_id).first
    if enrollment
      #TODO - investigate why two SET records exist
      # Created At - [Thu, 11 Oct 2018 18:07:25 IST +01:00, Thu, 11 Oct 2018 18:05:52 IST +01:00]
      set = enrollment.subject_course_user_log.student_exam_tracks.where(course_module_id: self.id).all_in_order.first
      set.try(:percentage_complete) || 0
    else
      0
    end
  end


  ########################################################################


  protected

  def set_count_fields
    self.quiz_count = self.active_children.all_active.all_quizzes.count
    self.video_count = self.active_children.all_active.all_videos.count
    self.cme_count = children_available_count
  end

  def update_parent
    self.parent.try(:recalculate_fields)
  end

end
