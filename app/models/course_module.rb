# == Schema Information
#
# Table name: course_modules
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  sorting_order             :integer
#  estimated_time_in_seconds :integer
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#  cme_count                 :integer          default(0)
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  subject_course_id         :integer
#  video_duration            :float            default(0.0)
#  video_count               :integer          default(0)
#  quiz_count                :integer          default(0)
#  highlight_colour          :string
#  tuition                   :boolean          default(FALSE)
#  test                      :boolean          default(FALSE)
#  revision                  :boolean          default(FALSE)
#  discourse_topic_id        :integer
#

class CourseModule < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :name, :name_url, :description,
                  :sorting_order, :estimated_time_in_seconds,
                  :active, :cme_count, :seo_description, :seo_no_index,
                  :number_of_questions, :subject_course_id, :highlight_colour,
                  :tuition, :test, :revision, :discourse_topic_id, :quiz_count,
                  :video_duration, :video_count

  # Constants

  # relationships
  belongs_to :subject_course
  has_many :course_module_elements
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :course_module_element_videos, through: :course_module_elements
  has_many :course_module_element_user_logs
  has_many :student_exam_tracks

  # validation
  validates :subject_course_id, presence: true
  validates :name, presence: true,
            uniqueness: {scope: :subject_course_id}, length: {maximum: 255}
  validates :name_url, presence: true,
            uniqueness: {scope: :subject_course_id}, length: {maximum: 255}
  validates :sorting_order, presence: true
  validates_length_of :seo_description, maximum: 255, allow_blank: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :description) }
  before_create :set_sorting_order
  before_save :set_count_fields, :sanitize_name_url
  after_update :update_parent

  # scopes
  scope :all_in_order, -> { order(:sorting_order) }
  scope :all_active, -> { where(active: true, destroyed_at: nil) }
  scope :all_tuition, -> { where(tuition: true, destroyed_at: nil) }
  scope :all_revision, -> { where(revision: true, destroyed_at: nil) }
  scope :all_test, -> { where(test: true, destroyed_at: nil) }
  scope :all_inactive, -> { where(active: false) }
  scope :with_url, lambda { |the_url| where(name_url: the_url) }

  # class methods

  # instance methods
  def array_of_sibling_ids
    self.parent.course_modules.all_active.all_in_order.map(&:id)
  end

  def active_children
    self.children.all_active.all_in_order
  end

  def category
    if self.revision
      'Revision'
    elsif self.tuition
      'Tuition'
    elsif self.test
      'Test'
    else
      ''
    end
  end

  def children
    self.course_module_elements.all
  end

  def children_available_count
    self.children.all_active.count
  end

  def completed_by_user_or_guid(user_id, session_guid)
    self.percentage_complete_by_user_or_guid(user_id, session_guid) == 100
  end

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

  def first_active_cme
    self.active_children.first
  end

  def full_name
    self.parent.name + ' > ' + self.name
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

  def parent
    self.subject_course
  end

  def percentage_complete_by_user_or_guid(user_id, session_guid)
    set = user_id ?
            self.student_exam_tracks.where(user_id: user_id).first :
            self.student_exam_tracks.where(user_id: nil, session_guid: session_guid).first
    set.try(:percentage_complete) || 0
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

  def update_video_and_quiz_counts
    estimated_time = self.course_module_elements.sum(:estimated_time_in_seconds)
    num_questions = self.course_module_elements.sum(:number_of_questions)
    quiz_count = self.course_module_elements.all_active.all_quizzes.count
    duration = self.course_module_elements.sum(:duration)
    video_count = self.course_module_elements.all_active.all_videos.count
    self.update_attributes(estimated_time_in_seconds: estimated_time, number_of_questions: num_questions, quiz_count: quiz_count, video_duration: duration, video_count: video_count)
  end

  def total_time_watched_videos
    total_seconds = CourseModuleElementUserLog.where(course_module_id: self.id).sum(:seconds_watched)
    @time_watched ||= { hours: total_seconds / 3600, minutes: (total_seconds / 60) % 60, seconds: total_seconds % 60 }
  end

  protected

  def set_count_fields
    self.estimated_time_in_seconds = self.course_module_elements.sum(:estimated_time_in_seconds)
    self.number_of_questions = self.course_module_elements.sum(:number_of_questions)
    self.quiz_count = self.course_module_elements.all_active.all_quizzes.count
    self.video_count = self.course_module_elements.all_active.all_videos.count
    self.video_duration = self.course_module_elements.sum(:duration)
    self.cme_count = children_available_count
  end

  def update_parent
    self.parent.try(:recalculate_fields)
  end

end
