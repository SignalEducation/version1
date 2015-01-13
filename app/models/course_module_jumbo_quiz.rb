# == Schema Information
#
# Table name: course_module_jumbo_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_id                  :integer
#  name                              :string(255)
#  minimum_question_count_per_quiz   :integer
#  maximum_question_count_per_quiz   :integer
#  total_number_of_questions         :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  name_url                          :string(255)
#  best_possible_score_first_attempt :integer          default(0)
#  best_possible_score_retry         :integer          default(0)
#

class CourseModuleJumboQuiz < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :course_module_id, :name, :name_url,
                  :minimum_question_count_per_quiz,
                  :maximum_question_count_per_quiz, :total_number_of_questions

  # Constants

  # relationships
  belongs_to :course_module
  has_many :course_module_element_quizzes
  has_many :course_module_element_user_logs

  # validation
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :name, presence: true
  validates :name_url, presence: true
  validates :minimum_question_count_per_quiz, presence: true,
            numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :maximum_question_count_per_quiz, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :total_number_of_questions, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_validation { squish_fields(:name) }
  before_save :sanitize_name_url
  before_save :calculate_best_possible_scores

  # scopes
  scope :all_in_order, -> { order(:course_module_id) }

  # class methods

  # instance methods
  def completed_by_user_or_guid(user_id, session_guid)
    user_id ?
            self.course_module_element_user_logs.where(user_id: user_id).count > 0 :
            self.course_module_element_user_logs.where(user_id: nil, session_guid: session_guid).count > 0
  end

  def destroyable?
    true
  end

  def name_url
    name_url_sanitizer(self.name)
  end

  def parent
    self.course_module
  end

  protected

  def calculate_best_possible_scores
    self.best_possible_score_retry = self.total_number_of_questions *
            ApplicationController::DIFFICULTY_LEVELS[-1][:score]
    self.best_possible_score_first_attempt = self.best_possible_score_retry -
            (ApplicationController::DIFFICULTY_LEVELS[-1][:score] *
            ApplicationController::DIFFICULTY_LEVELS.length)
    ApplicationController::DIFFICULTY_LEVELS.length.times do |counter|
      self.best_possible_score_first_attempt += ApplicationController::DIFFICULTY_LEVELS[counter][:score]
    end
  end

end
