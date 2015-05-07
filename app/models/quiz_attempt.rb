# == Schema Information
#
# Table name: quiz_attempts
#
#  id                                :integer          not null, primary key
#  user_id                           :integer
#  quiz_question_id                  :integer
#  quiz_answer_id                    :integer
#  correct                           :boolean          default(FALSE), not null
#  course_module_element_user_log_id :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  score                             :integer          default(0)
#  answer_array                      :string(255)
#

class QuizAttempt < ActiveRecord::Base

  include LearnSignalModelExtras

  serialize :answer_array #, Array - seems to break in Rails 4.2.1

  # attr-accessible
  attr_accessible :user_id, :quiz_question_id, :quiz_answer_id, :correct,
                  :course_module_element_user_log_id, :answer_array

  # Constants

  # relationships
  belongs_to :course_module_element_user_log, inverse_of: :quiz_attempts
  belongs_to :quiz_question
  belongs_to :quiz_answer
  belongs_to :user

  # validation
  validates :user_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_answer_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_user_log_id, presence: true,
            on: :update
  validates :course_module_element_user_log_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0},
            on: :create
  validates :answer_array, presence: true, on: :update

  # callbacks
  before_validation :serialize_the_array
  before_create :calculate_score

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_correct, -> { where(correct: true) }
  scope :all_incorrect, -> { where(correct: false) }

  # class methods

  # instance methods

  def answers
    self.answer_array ?
            QuizAnswer.ids_in_specific_order(self.answer_array) :
            self.quiz_question.quiz_answers
  end

  def destroyable?
    true
  end

  protected

  def calculate_score
    self.correct = self.quiz_answer.try(:correct) || false
    self.score = self.correct ?
            ApplicationController::DIFFICULTY_LEVELS.find {|x| x[:name] == self.quiz_answer.quiz_question.difficulty_level}[:score] : 0
  end

  def serialize_the_array
    self.answer_array = self.answer_array.to_s.split(',') if self.answer_array.to_s.split(',').length > 1
  end

end
