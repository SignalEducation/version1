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
#  answer_array                      :string
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
  validates :quiz_question_id, presence: true
  validates :quiz_answer_id, presence: true
  validates :course_module_element_user_log_id, presence: true,
            on: :update
  validates :answer_array, presence: true, on: :update

  # callbacks
  before_validation :serialize_the_array
  before_create :calculate_score

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_correct, -> { where(correct: true) }
  scope :all_incorrect, -> { where(correct: false) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :one_month_ago, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :two_months_ago, -> { where(created_at: 2.month.ago.beginning_of_month..2.month.ago.end_of_month) }
  scope :three_months_ago, -> { where(created_at: 3.month.ago.beginning_of_month..3.month.ago.end_of_month) }
  scope :four_months_ago, -> { where(created_at: 4.month.ago.beginning_of_month..4.month.ago.end_of_month) }
  scope :five_months_ago, -> { where(created_at: 5.month.ago.beginning_of_month..5.month.ago.end_of_month) }


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
    self.score = self.correct ? 1: 0
  end

  def serialize_the_array
    self.answer_array = self.answer_array.to_s.split(',') if self.answer_array.to_s.split(',').length > 1
  end

end
