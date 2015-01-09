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
#

class QuizAttempt < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :quiz_question_id, :quiz_answer_id, :correct,
                  :course_module_element_user_log_id

  # Constants

  # relationships
  belongs_to :course_module_element_user_log
  belongs_to :quiz_question
  belongs_to :quiz_answer
  belongs_to :user

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_answer_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_user_log_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:user_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

end
