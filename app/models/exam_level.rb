# == Schema Information
#
# Table name: exam_levels
#
#  id                                      :integer          not null, primary key
#  qualification_id                        :integer
#  name                                    :string(255)
#  name_url                                :string(255)
#  is_cpd                                  :boolean          default(FALSE), not null
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  best_possible_first_attempt_score       :float
#  created_at                              :datetime
#  updated_at                              :datetime
#  default_number_of_possible_exam_answers :integer          default(4)
#  enable_exam_sections                    :boolean          default(TRUE), not null
#

class ExamLevel < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :qualification_id, :name, :name_url, :is_cpd, :sorting_order, :active, :default_number_of_possible_exam_answers, :enable_exam_sections

  # Constants

  # relationships
  belongs_to :qualification
  has_many :exam_sections
  has_many :course_modules
  has_many :course_module_elements, through: :course_modules
  has_many :course_module_element_quizzes, through: :course_module_elements
  has_many :student_exam_tracks
  has_many :user_exam_level

  # validation
  validates :qualification_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true
  validates :sorting_order, presence: true
  validates :default_number_of_possible_exam_answers, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_validation { squish_fields(:name, :name_url) }
  before_create :set_sorting_order
  before_save :calculate_best_possible_score
  before_save :sanitize_name_url

  # scopes
  scope :all_active, -> { where(active: true) }
  scope :all_in_order, -> { order(:qualification_id, :sorting_order) }
  scope :all_with_exam_sections_enabled, -> { where(enable_exam_sections: true) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

  # instance methods
  def active_children
    self.children.all_active.all_in_order
  end

  def children
    if self.enable_exam_sections == true
      self.exam_sections.all
    else
      self.course_modules.all
    end
  end

  def destroyable?
    !self.active && self.exam_sections.empty? && self.course_modules.empty? && self.student_exam_tracks.empty? && self.user_exam_level.empty?
  end

  def first_active_cme
    self.active_children.first.try(:first_active_cme)
  end

  def full_name
    self.qualification.name + ' > ' + self.name
  end

  def parent
    self.qualification
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
