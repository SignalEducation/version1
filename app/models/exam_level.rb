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
  before_save :calculate_best_possible_score
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:qualification_id) }
  scope :all_with_exam_sections_enabled, -> { where(enable_exam_sections: true) }

  # class methods
  def self.get_by_name_url(the_name_url)
    where(name_url: the_name_url).first
  end

  # instance methods
  def destroyable?
    !self.active && self.exam_sections.empty? && self.course_modules.empty? && self.student_exam_tracks.empty? && self.user_exam_level.empty?
  end

  def full_name
    self.qualification.name + ' > ' + self.name
  end

  protected

  def calculate_best_possible_score
    self.best_possible_first_attempt_score = self.course_module_element_quizzes.sum(:best_possible_score_first_attempt)
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
