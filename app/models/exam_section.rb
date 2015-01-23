# == Schema Information
#
# Table name: exam_sections
#
#  id                                :integer          not null, primary key
#  name                              :string(255)
#  name_url                          :string(255)
#  exam_level_id                     :integer
#  active                            :boolean          default(FALSE), not null
#  sorting_order                     :integer
#  best_possible_first_attempt_score :float
#  created_at                        :datetime
#  updated_at                        :datetime
#

class ExamSection < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :name, :name_url, :exam_level_id, :active, :sorting_order

  # Constants

  # relationships
  belongs_to :exam_level
  has_many :course_modules
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :student_exam_tracks

  # validation
  validates :name, presence: true
  validates :name_url, presence: true, uniqueness: true
  validates :exam_level_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true

  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_create :set_sorting_order
  before_save :calculate_best_possible_score
  before_save :sanitize_name_url

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:sorting_order, :name) }
  scope :with_url, lambda { |the_url| where(name_url: the_url) }

  # class methods

  # instance methods
  def active_children
    self.children.all_active.all_in_order
  end

  def children
    self.course_modules
  end

  def full_name
    self.exam_level.name + ' > ' + self.name
  end

  def destroyable?
    !self.active && self.course_modules.empty? && self.student_exam_tracks.empty?
  end

  def first_active_cme
    self.active_children.first.try(:first_active_cme)
  end

  def parent
    self.exam_level
  end

  def completed_by_user_or_guid(user_id, session_guid)
    self.percentage_complete_by_user_or_guid(user_id, session_guid) == 100
  end

  def percentage_complete_by_user_or_guid(user_id, session_guid)
    if self.course_module_elements.all_active.count > 0
      (self.student_exam_tracks.for_user_or_session(user_id, session_guid).sum(:count_of_cmes_completed).to_f / self.course_module_elements.all_active.count * 100).to_i
    else
      0
    end
  end

  protected

  def calculate_best_possible_score
    self.best_possible_first_attempt_score = self.course_module_element_quizzes.sum(:best_possible_score_first_attempt)
  end

end
