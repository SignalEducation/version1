# == Schema Information
#
# Table name: course_modules
#
#  id                        :integer          not null, primary key
#  institution_id            :integer
#  qualification_id          :integer
#  exam_level_id             :integer
#  exam_section_id           :integer
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  tutor_id                  :integer
#  sorting_order             :integer
#  estimated_time_in_seconds :integer
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#

class CourseModule < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :institution_id, :qualification_id, :exam_level_id,
                  :exam_section_id, :name, :name_url, :description,
                  :tutor_id, :sorting_order, :estimated_time_in_seconds,
                  :active

  # Constants

  # relationships
  has_many :course_module_elements
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :course_module_element_videos, through: :course_module_elements
  has_many :course_module_element_user_logs
  has_one :course_module_jumbo_quiz
  belongs_to :exam_level
  belongs_to :exam_section
  belongs_to :institution
  belongs_to :qualification
  has_many :student_exam_tracks
  belongs_to :tutor, class_name: 'User', foreign_key: :tutor_id

  # validation
  validates :institution_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_section_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true
  validates :tutor_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url, :description) }
  before_create :set_sorting_order
  before_save :calculate_estimated_time
  before_save :unify_hierarchy_ids
  before_save :sanitize_name_url

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :institution_id) }
  scope :all_active, -> { where(active: true) }
  scope :all_inactive, -> { where(active: false) }
  scope :with_url, lambda { |the_url| where(name_url: the_url) }

  # class methods

  # instance methods
  def array_of_sibling_ids
    self.parent.course_modules.all_in_order.map(&:id)
  end

  def active_children
    self.children.all_active.all_in_order
  end

  def children
    self.course_module_elements.all
  end

  def children_available_count
    self.children.all_active.count + (self.course_module_jumbo_quiz ? 1 : 0)
  end

  def completed_by_user_or_guid(user_id, session_guid)
    self.percentage_complete_by_user_or_guid(user_id, session_guid) == 100
  end

  def first_active_cme
    self.active_children.first
  end

  def percentage_complete_by_user_or_guid(user_id, session_guid)
    set = user_id ?
        self.student_exam_tracks.where(user_id: user_id).first :
        self.student_exam_tracks.where(user_id: nil, session_guid: session_guid).first
    set.try(:percentage_complete) || 0
  end

  def destroyable?
    self.course_module_elements.empty? && self.course_module_jumbo_quiz.nil? && self.course_module_element_user_logs.empty? && self.student_exam_tracks.empty?
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
    self.exam_section ? self.exam_section : self.exam_level
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

  def recalculate_estimated_time
    calculate_estimated_time
    self.save
  end

  protected

  def calculate_estimated_time
    self.estimated_time_in_seconds = self.course_module_elements.sum(:estimated_time_in_seconds)
  end

  def unify_hierarchy_ids
    if self.exam_section_id
      self.exam_level_id = self.exam_section.exam_level_id
    end
    self.qualification_id = self.exam_level.qualification_id
    self.institution_id = self.qualification.institution_id
  end

end
