# frozen_string_literal: true

# == Schema Information
#
# Table name: course_lessons
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  name_url                   :string(255)
#  description                :text
#  sorting_order              :integer
#  estimated_time_in_seconds  :integer
#  active                     :boolean          default("false"), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  cme_count                  :integer          default("0")
#  seo_description            :string(255)
#  seo_no_index               :boolean          default("false")
#  destroyed_at               :datetime
#  number_of_questions        :integer          default("0")
#  course_id                  :integer
#  video_duration             :float            default("0.0")
#  video_count                :integer          default("0")
#  quiz_count                 :integer          default("0")
#  highlight_colour           :string
#  tuition                    :boolean          default("false")
#  test                       :boolean          default("false")
#  revision                   :boolean          default("false")
#  course_section_id          :integer
#  constructed_response_count :integer          default("0")
#  temporary_label            :string
#

class CourseLesson < ApplicationRecord
  include LearnSignalModelExtras
  include Archivable

  # relationships
  belongs_to :course
  belongs_to :course_section
  has_many :course_lesson_logs
  has_many :course_steps
  has_many :course_quizzes, through: :course_steps
  has_many :course_videos, through: :course_steps
  has_many :course_step_logs

  accepts_nested_attributes_for :course_steps

  # validation
  validates :course, presence: true
  validates :course_section, presence: true
  validates :name, presence: true, uniqueness: {
    scope: :course_section_id,
    message: 'must be unique within the course section'
  }
  validates :name_url, presence: true, uniqueness: {
    scope: :course_section_id,
    message: 'must be unique within the course section'
  }

  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :description) }
  before_create :set_sorting_order
  before_save :set_count_fields, :sanitize_name_url
  after_update :update_parent

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_section_id) }
  scope :all_active,   -> { where(active: true, destroyed_at: nil) }
  scope :all_valid,    -> { where(active: true).includes(:course_steps).where(course_steps: { active: true }) }
  scope :all_inactive, -> { where(active: false) }
  scope :with_url,     ->(the_url) { where(name_url: the_url) }

  ## Parent & Child associations ##
  def parent
    course_section
  end

  def children
    course_steps.all
  end

  def active_children
    children.all_active.all_in_order
  end

  def first_active_cme
    active_children.first
  end

  def children_available_count
    active_children.count
  end

  #######################################################################

  ## Methods allow for navigation from one CM to the next ##

  # TODO, these do not work when latest course modules are made inactive
  # Needs a fallback

  def array_of_sibling_ids
    parent.course_lessons.all_active.all_in_order.map(&:id)
  end

  def my_position_among_siblings
    array_of_sibling_ids.index(id)
  end

  def next_module
    CourseLesson.find_by_id(next_module_id) || nil
  end

  def next_module_id
    return unless my_position_among_siblings && my_position_among_siblings < (array_of_sibling_ids.length - 1)

    array_of_sibling_ids[my_position_among_siblings + 1]
  end

  def previous_module
    CourseLesson.find(previous_module_id) || nil
  end

  def previous_module_id
    return unless my_position_among_siblings > 0

    array_of_sibling_ids[my_position_among_siblings - 1]
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
    the_list += course_steps.to_a
    the_list
  end

  #######################################################################

  ## Keeping Model Count Attributes Up-to-Date ##

  ### Triggered by child CME after_save callback ###
  def update_video_and_quiz_counts
    quiz_count  = active_children.all_active.all_quizzes.count
    video_count = active_children.all_active.all_videos.count
    cr_count    = active_children.all_active.all_constructed_response.count

    update_attributes(quiz_count: quiz_count, video_count: video_count,
                      constructed_response_count: cr_count,
                      cme_count: quiz_count + video_count + cr_count)
  end

  ########################################################################

  ## User Course Tracking ##

  def completed_by_user(user_id)
    percentage_complete_by_user(user_id) >= 100
  end

  def percentage_complete_by_user(user_id)
    set = course_lesson_logs.where(user_id: user_id).last
    set.try(:percentage_complete) || 0
  end

  def completed_for_scul(scul_id)
    percentage_complete_for_scul(scul_id) >= 100
  end

  def percentage_complete_for_scul(scul_id)
    scul = CourseLog.find(id: scul_id)

    if scul
      # TODO, investigate why two SET records exist
      # Created At - [Thu, 11 Oct 2018 18:07:25 IST +01:00, Thu, 11 Oct 2018 18:05:52 IST +01:00]
      set = scul.course_lesson_logs.where(course_lesson_id: id).all_in_order.first
      set.try(:percentage_complete) || 0.0
    else
      0.0
    end
  end

  def all_content_restricted?
    active_children.count == active_children.where(available_on_trial: false).count
  end

  ########################################################################

  protected

  def set_count_fields
    self.quiz_count                 = active_children.all_quizzes.count
    self.video_count                = active_children.all_videos.count
    self.cme_count                  = children_available_count
    self.constructed_response_count = active_children.all_constructed_response.count
  end

  def update_parent
    parent.try(:recalculate_fields)
  end
end
