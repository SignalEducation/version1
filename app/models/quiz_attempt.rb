# frozen_string_literal: true

# == Schema Information
#
# Table name: quiz_attempts
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  quiz_question_id   :integer
#  quiz_answer_id     :integer
#  correct            :boolean          default("false"), not null
#  course_step_log_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  score              :integer          default("0")
#  answer_array       :string(255)
#

class QuizAttempt < ApplicationRecord
  include LearnSignalModelExtras

  serialize :answer_array

  # Constants

  # relationships
  belongs_to :course_step_log, inverse_of: :quiz_attempts
  belongs_to :quiz_question
  belongs_to :quiz_answer
  belongs_to :user

  # validation
  validates :quiz_question_id, presence: true
  validates :quiz_answer_id, presence: true
  validates :course_step_log_id, presence: true, on: :update
  validates :answer_array, presence: true, on: :update

  # callbacks
  after_create :calculate_score

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_correct, -> { where(correct: true) }
  scope :all_incorrect, -> { where(correct: false) }

  # class methods

  # instance methods

  ## Misc. ##

  def answers
    answer_array ? QuizAnswer.ids_in_specific_order(answer_array.split(',')) : quiz_question.quiz_answers
  end

  def destroyable?
    true
  end

  protected

  def calculate_score
    self.correct = quiz_answer.try(:correct) || false
    self.score = correct ? 1 : 0
    save
  end
end
