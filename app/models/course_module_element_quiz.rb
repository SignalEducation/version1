# == Schema Information
#
# Table name: course_module_element_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_element_id          :integer
#  name                              :string(255)
#  preamble                          :text
#  expected_time_in_seconds          :integer
#  time_limit_seconds                :integer
#  number_of_questions               :integer
#  question_selection_strategy       :string(255)
#  best_possible_score_first_attempt :integer
#  best_possible_score_retry         :integer
#  course_module_jumbo_quiz_id       :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#

class CourseModuleElementQuiz < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :name, :preamble,
                  :expected_time_in_seconds, :time_limit_seconds,
                  :number_of_questions, :best_possible_score_retry,
                  :course_module_jumbo_quiz_id

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :course_module_jumbo_quiz
  has_many :quiz_questions

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :preamble, presence: true
  validates :expected_time_in_seconds, presence: true
  validates :time_limit_seconds, presence: true
  validates :number_of_questions, presence: true, numericality:
            {greater_than_or_equal_to: 4, less_than_or_equal_to: 10,
             only_integer: true}
  validates :best_possible_score_first_attempt, presence: true
  validates :best_possible_score_retry, presence: true
  validates :course_module_jumbo_quiz_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods

  # instance methods
  def destroyable?
    self.quiz_questions.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
